# ERROR HANDLING & VALIDATIONS

# 1. Input Validations
class InputValidator:
    
    @staticmethod
    def validate_email(email: str) -> Tuple[bool, str]:
        """Validate email format"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(pattern, email):
            return False, "Invalid email format"
        return True, ""
    
    @staticmethod
    def validate_password(password: str) -> Tuple[bool, List[str]]:
        """Validate password strength"""
        errors = []
        
        if len(password) < 8:
            errors.append("Password must be at least 8 characters")
        
        if not any(char.isdigit() for char in password):
            errors.append("Password must contain at least one number")
        
        if not any(char.isupper() for char in password):
            errors.append("Password must contain at least one uppercase letter")
        
        if not any(char.islower() for char in password):
            errors.append("Password must contain at least one lowercase letter")
        
        return len(errors) == 0, errors
    
    @staticmethod
    def validate_job_data(job_data: dict) -> Tuple[bool, dict]:
        """Validate job posting data"""
        errors = {}
        
        # Title validation
        if not job_data.get('title') or len(job_data['title'].strip()) < 5:
            errors['title'] = "Title must be at least 5 characters"
        
        if len(job_data.get('title', '')) > 200:
            errors['title'] = "Title cannot exceed 200 characters"
        
        # Description validation
        if not job_data.get('description') or len(job_data['description'].strip()) < 50:
            errors['description'] = "Description must be at least 50 characters"
        
        if len(job_data.get('description', '')) > 5000:
            errors['description'] = "Description cannot exceed 5000 characters"
        
        # Salary validation
        min_salary = job_data.get('min_salary')
        max_salary = job_data.get('max_salary')
        
        if min_salary is not None and max_salary is not None:
            if min_salary > max_salary:
                errors['salary'] = "Minimum salary cannot be greater than maximum salary"
            
            if min_salary < 0 or max_salary < 0:
                errors['salary'] = "Salary cannot be negative"
        
        # Deadline validation
        deadline = job_data.get('application_deadline')
        if deadline:
            try:
                deadline_date = datetime.strptime(deadline, '%Y-%m-%d').date()
                if deadline_date < date.today():
                    errors['deadline'] = "Deadline cannot be in the past"
                if deadline_date > date.today() + timedelta(days=365):
                    errors['deadline'] = "Deadline cannot be more than 1 year in future"
            except ValueError:
                errors['deadline'] = "Invalid date format (YYYY-MM-DD required)"
        
        return len(errors) == 0, errors


# 2. Business Rule Validations
class BusinessRuleValidator:
    
    @staticmethod
    def validate_job_application(jobseeker_id: int, job_id: int) -> Tuple[bool, str]:
        """Validate if jobseeker can apply for job"""
        
        # Check if job exists and is active
        job = Job.query.get(job_id)
        if not job:
            return False, "Job not found"
        
        if job.status != 'active':
            return False, "Job is not currently accepting applications"
        
        # Check if deadline passed
        if job.application_deadline and job.application_deadline < date.today():
            return False, "Application deadline has passed"
        
        # Check if already applied
        existing_application = Application.query.filter_by(
            jobseeker_id=jobseeker_id, 
            job_id=job_id
        ).first()
        
        if existing_application:
            return False, "You have already applied for this job"
        
        # Check if profile is complete
        jobseeker = JobSeeker.query.get(jobseeker_id)
        if not jobseeker.resume_url:
            return False, "Please upload your resume before applying"
        
        return True, ""


# 3. Error Response Structure
class ErrorResponse:
    """Standard error response format"""
    
    @staticmethod
    def create_error_response(error_code: str, message: str, details: dict = None) -> dict:
        """Create standardized error response"""
        response = {
            "success": False,
            "error": {
                "code": error_code,
                "message": message,
                "timestamp": datetime.utcnow().isoformat(),
                "request_id": str(uuid.uuid4())
            }
        }
        
        if details:
            response["error"]["details"] = details
        
        return response
    
    # Common error codes
    ERROR_CODES = {
        # Authentication errors
        "AUTH_001": "Invalid credentials",
        "AUTH_002": "Account not verified",
        "AUTH_003": "Session expired",
        "AUTH_004": "Insufficient permissions",
        
        # Validation errors
        "VAL_001": "Required field missing",
        "VAL_002": "Invalid data format",
        "VAL_003": "Value out of range",
        "VAL_004": "Duplicate entry found",
        
        # Business errors
        "BUS_001": "Job not found",
        "BUS_002": "Application deadline passed",
        "BUS_003": "Already applied",
        "BUS_004": "Profile incomplete",
        "BUS_005": "Invalid status transition",
        
        # System errors
        "SYS_001": "Database connection failed",
        "SYS_002": "External service unavailable",
        "SYS_003": "File upload failed",
        "SYS_004": "Rate limit exceeded",
    }


# 4. Exception Handling
class JobifyException(Exception):
    """Base exception for Jobify application"""
    
    def __init__(self, error_code: str, message: str = None, details: dict = None):
        self.error_code = error_code
        self.message = message or ErrorResponse.ERROR_CODES.get(error_code, "Unknown error")
        self.details = details or {}
        super().__init__(self.message)


class ValidationError(JobifyException):
    """Raised when input validation fails"""
    pass


class BusinessRuleError(JobifyException):
    """Raised when business rules are violated"""
    pass


class AuthenticationError(JobifyException):
    """Raised for authentication/authorization failures"""
    pass


# 5. Global Error Handler (Flask example)
@app.errorhandler(JobifyException)
def handle_jobify_exception(error):
    """Handle Jobify exceptions globally"""
    response = ErrorResponse.create_error_response(
        error_code=error.error_code,
        message=error.message,
        details=error.details
    )
    
    # Map error codes to HTTP status codes
    status_map = {
        'AUTH_': 401,  # Unauthorized
        'VAL_': 400,   # Bad Request
        'BUS_': 409,   # Conflict
        'SYS_': 500,   # Internal Server Error
    }
    
    status_code = 400  # Default
    for prefix, code in status_map.items():
        if error.error_code.startswith(prefix):
            status_code = code
            break
    
    return jsonify(response), status_code


@app.errorhandler(Exception)
def handle_generic_exception(error):
    """Handle unexpected exceptions"""
    # Log the error for debugging
    app.logger.error(f"Unexpected error: {str(error)}", exc_info=True)
    
    # Return generic error to user
    response = ErrorResponse.create_error_response(
        error_code="SYS_000",
        message="An unexpected error occurred. Please try again later."
    )
    
    return jsonify(response), 500