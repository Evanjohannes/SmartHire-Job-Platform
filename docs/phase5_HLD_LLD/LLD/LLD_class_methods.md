# JOBIFY - CLASS DIAGRAM

#  CORE ENTITIES 

class User:
    """
    Base user class for all system users
    """
    # Attributes
    user_id: int
    name: str
    email: str
    password_hash: str
    role: str  # 'jobseeker', 'employer', 'admin'
    created_at: datetime
    
    # Methods
    def authenticate(email: str, password: str) -> bool:
        """Verify user credentials"""
        # 1. Hash input password
        # 2. Compare with stored hash
        # 3. Return True/False
        
    def update_profile(data: dict) -> bool:
        """Update user profile information"""
        # 1. Validate input data
        # 2. Update database
        # 3. Return success status
        
    def change_password(old_pass: str, new_pass: str) -> bool:
        """Change user password with validation"""


class JobSeeker(User):
    """
    Represents a job seeking user
    """
    # Additional Attributes
    resume_path: str
    skills: List[Skill]
    experience_years: int
    education_level: str
    
    # Methods
    def search_jobs(filters: dict) -> List[Job]:
        """Search jobs based on filters"""
        # 1. Build query from filters
        # 2. Execute database query
        # 3. Return job list
        
    def apply_for_job(job_id: int, cover_letter: str) -> Application:
        """Apply for a specific job"""
        # 1. Check if job exists
        # 2. Create application record
        # 3. Upload resume if needed
        # 4. Return application object
        
    def track_applications() -> List[Application]:
        """Get all applications for this user"""


class Employer(User):
    """
    Represents an employer/company
    """
    # Additional Attributes
    company_name: str
    company_description: str
    industry: str
    website: str
    
    # Methods
    def post_job(job_data: dict) -> Job:
        """Create a new job posting"""
        # 1. Validate job data
        # 2. Create job record
        # 3. Return job object
        
    def review_applications(job_id: int) -> List[Application]:
        """Get applications for a specific job"""
        
    def schedule_interview(application_id: int, date: datetime) -> Interview:
        """Schedule interview for applicant"""


class Job:
    """
    Represents a job posting
    """
    # Attributes
    job_id: int
    title: str
    description: str
    requirements: str
    min_salary: float
    max_salary: float
    location: str
    job_type: str  # 'full_time', 'part_time', 'contract'
    status: str    # 'active', 'closed', 'draft'
    
    # Methods
    def is_active() -> bool:
        """Check if job is still accepting applications"""
        
    def update_job_details(data: dict) -> bool:
        """Update job information"""
        
    def close_job() -> bool:
        """Mark job as closed"""


class Application:
    """
    Represents a job application
    """
    # Attributes
    application_id: int
    jobseeker_id: int
    job_id: int
    status: str  # 'applied', 'reviewed', 'interview', 'hired', 'rejected'
    applied_date: datetime
    cover_letter: str
    cv_path: str
    
    # Methods
    def submit() -> bool:
        """Submit application"""
        
    def update_status(new_status: str) -> bool:
        """Update application status with validation"""
        
    def get_status_history() -> List[StatusChange]:
        """Get all status changes"""


# ========== CONTROLLERS/SERVICES ==========

class JobController:
    """
    Controls job-related operations
    """
    # Methods
    def process_job_search(filters: dict, user_id: int) -> List[Job]:
        """Process job search request"""
        # 1. Validate filters
        # 2. Query database
        # 3. Apply relevance scoring
        # 4. Return sorted results
        
    def validate_job_data(job_data: dict) -> Tuple[bool, List[str]]:
        """Validate job posting data"""
        # Returns: (is_valid, error_messages)


class ApplicationController:
    """
    Controls application processing
    """
    def process_application(jobseeker_id: int, job_id: int, cv_file: File) -> Application:
        """Process new job application"""
        # 1. Validate user can apply
        # 2. Validate job is open
        # 3. Save CV file
        # 4. Create application record
        # 5. Send notifications


class AuthService:
    """
    Handles authentication and authorization
    """
    def login(email: str, password: str) -> Tuple[bool, dict]:
        """Authenticate user"""
        # Returns: (success, user_data/token)
        
    def register(user_data: dict) -> Tuple[bool, str]:
        """Register new user"""
        # Returns: (success, message)
        
    def generate_token(user_id: int) -> str:
        """Generate JWT token"""


class NotificationService:
    """
    Handles all system notifications
    """
    def send_application_submitted(application: Application) -> bool:
        """Notify employer about new application"""
        
    def send_interview_scheduled(interview: Interview) -> bool:
        """Notify participants about interview"""
        
    def send_status_update(application: Application) -> bool:
        """Notify jobseeker about status change"""