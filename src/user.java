package Package1;


/**
 * @author user
 * @version 1.0
 * @created 23-Dec-2025 3:47:55 AM
 */
public class user {

	public user(String username, String email, String userType){
		if (username == null || username.trim().isEmpty()) {
			throw new IllegalArgumentException("Username cannot be empty");
		}
		if (email == null || !email.contains("@")) {
			throw new IllegalArgumentException("Invalid email format");
		}
		this.username = username;
		this.email = email;
		this.userType = userType;
		this.createdAt = new java.util.Date();
	}
	public boolean canApplyForJob() {
		if (!"job_seeker".equals(userType)) {
			return false;
		}
		return hasCompleteProfile();
	}
	public boolean hasCompleteProfile() {
		if ("job_seeker".equals(userType)) {
			return (skills != null && !skills.isEmpty()) &&
					(resume != null && !resume.isEmpty()) &&
					(email != null && !email.isEmpty());
		} else {
			return (company != null && !company.isEmpty()) &&
					(bio != null && !bio.isEmpty());
		}
	}

}