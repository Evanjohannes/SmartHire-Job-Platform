-- JOBIFY - DETAILED DATABASE SCHEMA (MySQL)

-- Table 1: Users (Base table)
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    profile_picture_url VARCHAR(500),
    user_role ENUM('jobseeker', 'employer', 'admin') NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_role (user_role),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 2: Job Seekers (extends Users)
CREATE TABLE job_seekers (
    jobseeker_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    resume_url VARCHAR(500),
    summary TEXT,
    total_experience_years DECIMAL(3,1) DEFAULT 0,
    current_job_title VARCHAR(100),
    current_company VARCHAR(100),
    education_level ENUM('high_school', 'diploma', 'bachelor', 'master', 'phd'),
    expected_salary_min DECIMAL(10,2),
    expected_salary_max DECIMAL(10,2),
    preferred_location VARCHAR(100),
    open_to_remote BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_experience (total_experience_years),
    INDEX idx_location (preferred_location)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 3: Employers (extends Users)
CREATE TABLE employers (
    employer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    company_name VARCHAR(200) NOT NULL,
    company_description TEXT,
    industry VARCHAR(100),
    company_size ENUM('1-10', '11-50', '51-200', '201-500', '500+'),
    website_url VARCHAR(500),
    logo_url VARCHAR(500),
    verified_company BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_company_name (company_name),
    INDEX idx_industry (industry)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 4: Jobs
CREATE TABLE jobs (
    job_id INT PRIMARY KEY AUTO_INCREMENT,
    employer_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    responsibilities TEXT,
    requirements TEXT,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2),
    salary_currency VARCHAR(3) DEFAULT 'ETB',
    location VARCHAR(100),
    is_remote BOOLEAN DEFAULT FALSE,
    job_type ENUM('full_time', 'part_time', 'contract', 'internship', 'freelance') NOT NULL,
    experience_level ENUM('entry', 'mid', 'senior', 'executive') DEFAULT 'mid',
    education_required ENUM('none', 'high_school', 'diploma', 'bachelor', 'master', 'phd'),
    application_deadline DATE,
    status ENUM('draft', 'active', 'closed', 'expired') DEFAULT 'draft',
    views_count INT DEFAULT 0,
    applications_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (employer_id) REFERENCES employers(employer_id) ON DELETE CASCADE,
    INDEX idx_employer_status (employer_id, status),
    INDEX idx_location_type (location, job_type),
    INDEX idx_salary_range (min_salary, max_salary),
    FULLTEXT INDEX idx_search (title, description, requirements)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 5: Applications
CREATE TABLE applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    jobseeker_id INT NOT NULL,
    cover_letter TEXT,
    resume_url VARCHAR(500),
    status ENUM('applied', 'reviewed', 'shortlisted', 'interview', 
                'second_interview', 'hired', 'rejected', 'withdrawn') DEFAULT 'applied',
    match_score DECIMAL(5,2),  -- AI calculated match percentage
    employer_notes TEXT,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_changed_at TIMESTAMP NULL,
    
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (jobseeker_id) REFERENCES job_seekers(jobseeker_id) ON DELETE CASCADE,
    UNIQUE KEY unique_application (job_id, jobseeker_id),
    INDEX idx_status (status),
    INDEX idx_jobseeker_status (jobseeker_id, status),
    INDEX idx_job_status (job_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 6: Application Status History (Audit trail)
CREATE TABLE application_status_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by_user_id INT,  -- Who made the change
    change_reason TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by_user_id) REFERENCES users(user_id),
    INDEX idx_application (application_id),
    INDEX idx_changed_at (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 7: Interviews
CREATE TABLE interviews (
    interview_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL UNIQUE,
    interview_type ENUM('phone', 'video', 'in_person') DEFAULT 'video',
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    duration_minutes INT DEFAULT 45,
    timezone VARCHAR(50) DEFAULT 'UTC+3',
    meeting_platform ENUM('zoom', 'google_meet', 'teams', 'other'),
    meeting_link VARCHAR(500),
    meeting_id VARCHAR(100),
    meeting_password VARCHAR(100),
    status ENUM('scheduled', 'completed', 'cancelled', 'rescheduled', 'no_show'),
    employer_feedback TEXT,
    candidate_feedback TEXT,
    rating_by_employer INT CHECK (rating BETWEEN 1 AND 5),
    rating_by_candidate INT CHECK (rating BETWEEN 1 AND 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    INDEX idx_scheduled (scheduled_date, scheduled_time),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 8: Skills
CREATE TABLE skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    skill_name VARCHAR(100) UNIQUE NOT NULL,
    category ENUM('technical', 'soft', 'language', 'certification', 'tool') DEFAULT 'technical',
    description TEXT,
    
    INDEX idx_category (category),
    INDEX idx_name (skill_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 9: Job Seeker Skills (Many-to-Many)
CREATE TABLE jobseeker_skills (
    jobseeker_id INT NOT NULL,
    skill_id INT NOT NULL,
    proficiency ENUM('beginner', 'intermediate', 'advanced', 'expert') DEFAULT 'intermediate',
    years_of_experience INT DEFAULT 0,
    last_used_year INT,
    
    PRIMARY KEY (jobseeker_id, skill_id),
    FOREIGN KEY (jobseeker_id) REFERENCES job_seekers(jobseeker_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    INDEX idx_proficiency (proficiency)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 10: Job Required Skills (Many-to-Many)
CREATE TABLE job_required_skills (
    job_id INT NOT NULL,
    skill_id INT NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    importance_level ENUM('required', 'preferred', 'nice_to_have') DEFAULT 'required',
    
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 11: Messages
CREATE TABLE messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    conversation_id VARCHAR(100),  -- For grouping messages
    message_type ENUM('text', 'file', 'interview_invite', 'offer_letter') DEFAULT 'text',
    content TEXT,
    attachment_url VARCHAR(500),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sender_id) REFERENCES users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES users(user_id),
    INDEX idx_conversation (conversation_id),
    INDEX idx_sender_receiver (sender_id, receiver_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 12: Notifications
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    notification_type ENUM('application_status', 'interview_scheduled', 
                          'message_received', 'job_alert', 'system_alert', 
                          'profile_view', 'new_job_match') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    related_entity_type ENUM('job', 'application', 'interview', 'message', 'user'),
    related_entity_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    is_email_sent BOOLEAN DEFAULT FALSE,
    is_sms_sent BOOLEAN DEFAULT FALSE,
    action_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_unread (user_id, is_read),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 13: CV Templates
CREATE TABLE cv_templates (
    template_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category ENUM('modern', 'professional', 'creative', 'minimal', 'academic') DEFAULT 'professional',
    thumbnail_url VARCHAR(500),
    html_content LONGTEXT,
    css_content LONGTEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    price DECIMAL(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_premium (is_premium)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 14: User Saved CVs
CREATE TABLE user_cvs (
    cv_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    template_id INT,
    cv_name VARCHAR(100),
    cv_data JSON,  -- Stores all CV information in JSON format
    pdf_url VARCHAR(500),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES cv_templates(template_id),
    INDEX idx_user (user_id),
    UNIQUE KEY unique_default_cv (user_id, is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;