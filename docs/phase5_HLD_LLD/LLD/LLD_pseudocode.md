# KEY ALGORITHMS

# Algorithm 1: Job Search with Relevance Scoring
ALGORITHM search_jobs_with_relevance(user_id, filters, page, page_size)
    INPUT: user_id, filters dictionary, page number, results per page
    OUTPUT: sorted list of jobs with relevance scores
    
    BEGIN
        // Step 1: Base query
        query = "SELECT * FROM jobs WHERE status = 'active'"
        
        // Step 2: Apply filters
        IF filters['location']:
            query += " AND location LIKE %s"
            params.append(f"%{filters['location']}%")
        
        IF filters['min_salary']:
            query += " AND max_salary >= %s"
            params.append(filters['min_salary'])
        
        IF filters['job_type']:
            query += " AND job_type IN %s"
            params.append(tuple(filters['job_type']))
        
        // Step 3: Execute query
        jobs = execute_sql(query, params)
        
        // Step 4: Calculate relevance for each job
        user_skills = get_user_skills(user_id)
        
        FOR EACH job IN jobs:
            // Component 1: Skill match (40%)
            job_skills = extract_skills(job.description)
            skill_match = len(intersection(user_skills, job_skills)) / len(job_skills) * 40
            
            // Component 2: Location preference (30%)
            user_pref = get_user_location_pref(user_id)
            IF job.location == user_pref:
                location_score = 30
            ELSE IF job.is_remote:
                location_score = 25
            ELSE:
                location_score = 10
            
            // Component 3: Salary match (20%)
            user_exp_salary = get_user_expected_salary(user_id)
            IF job.min_salary <= user_exp_salary <= job.max_salary:
                salary_score = 20
            ELSE:
                salary_score = 10
            
            // Component 4: Experience match (10%)
            user_exp = get_user_experience(user_id)
            IF user_exp >= job.min_experience:
                exp_score = 10
            ELSE:
                exp_score = (user_exp / job.min_experience) * 10
            
            // Total score
            job.relevance_score = skill_match + location_score + salary_score + exp_score
        
        // Step 5: Sort by relevance
        sorted_jobs = sort(jobs, key=lambda j: j.relevance_score, reverse=True)
        
        // Step 6: Paginate
        start_idx = (page - 1) * page_size
        end_idx = start_idx + page_size
        paginated_jobs = sorted_jobs[start_idx:end_idx]
        
        RETURN paginated_jobs
    END


# Algorithm 2: Application Status Transition Validation
ALGORITHM validate_status_transition(current_status, new_status, user_role)
    INPUT: current status, requested new status, user role
    OUTPUT: (is_valid, error_message)
    
    BEGIN
        // Define valid transitions
        valid_transitions = {
            'applied': ['reviewed', 'rejected'],
            'reviewed': ['interview', 'rejected'],
            'interview': ['second_interview', 'hired', 'rejected'],
            'second_interview': ['hired', 'rejected'],
            'hired': [],  // Terminal state
            'rejected': []  // Terminal state
        }
        
        // Check if transition is valid
        IF new_status not in valid_transitions[current_status]:
            RETURN (False, f"Cannot transition from {current_status} to {new_status}")
        
        // Check permissions
        IF user_role == 'jobseeker':
            // Job seekers can only withdraw
            IF new_status != 'withdrawn':
                RETURN (False, "Job seekers can only withdraw applications")
        
        IF user_role == 'employer':
            // Employers cannot mark as hired without interview
            IF new_status == 'hired' and current_status not in ['interview', 'second_interview']:
                RETURN (False, "Cannot hire without interview")
        
        RETURN (True, "")
    END


# Algorithm 3: Interview Scheduling with Conflict Detection
ALGORITHM schedule_interview(application_id, proposed_time, duration)
    INPUT: application ID, proposed datetime, duration in minutes
    OUTPUT: (success, interview_object, conflict_message)
    
    BEGIN
        // Step 1: Get application details
        application = get_application(application_id)
        employer_id = application.job.employer_id
        jobseeker_id = application.jobseeker_id
        
        // Step 2: Check employer availability
        employer_interviews = get_interviews(employer_id, proposed_time.date())
        FOR EACH interview IN employer_interviews:
            IF time_overlap(interview.time, proposed_time, duration):
                RETURN (False, None, "Employer has conflicting interview")
        
        // Step 3: Check jobseeker availability
        jobseeker_interviews = get_interviews(jobseeker_id, proposed_time.date())
        FOR EACH interview IN jobseeker_interviews:
            IF time_overlap(interview.time, proposed_time, duration):
                RETURN (False, None, "Candidate has conflicting interview")
        
        // Step 4: Generate meeting link
        meeting_link = generate_meeting_link(employer_id, jobseeker_id, proposed_time)
        
        // Step 5: Create interview record
        interview_data = {
            'application_id': application_id,
            'scheduled_time': proposed_time,
            'duration': duration,
            'meeting_link': meeting_link,
            'status': 'scheduled'
        }
        
        interview = create_interview(interview_data)
        
        // Step 6: Send notifications
        send_calendar_invite(employer_id, interview)
        send_calendar_invite(jobseeker_id, interview)
        
        RETURN (True, interview, "")
    END


# Algorithm 4: HireBot AI Response Generation
ALGORITHM generate_ai_response(user_query, user_context)
    INPUT: user query text, user context (id, role, history)
    OUTPUT: AI response text
    
    BEGIN
        // Step 1: Classify query type
        query_type = classify_query(user_query)
        // Possible types: job_search, cv_help, interview_prep, general_help
        
        // Step 2: Process based on type
        SWITCH query_type:
            CASE 'job_search':
                // Extract job criteria
                criteria = extract_job_criteria(user_query)
                // Find matching jobs
                jobs = find_matching_jobs(user_context['id'], criteria)
                // Generate response
                response = format_job_suggestions(jobs)
                
            CASE 'cv_help':
                // Analyze user's CV if exists
                cv_score = analyze_cv(user_context['id'])
                // Get improvement tips
                tips = get_cv_improvement_tips(cv_score)
                response = format_cv_advice(tips)
                
            CASE 'interview_prep':
                // Get user's upcoming interviews
                interviews = get_upcoming_interviews(user_context['id'])
                // Generate practice questions
                questions = generate_interview_questions(interviews)
                response = format_interview_prep(questions)
                
            CASE 'general_help':
                // Use knowledge base
                response = query_knowledge_base(user_query)
        
        // Step 3: Add personalization
        personalized_response = personalize_response(response, user_context)
        
        RETURN personalized_response
    END