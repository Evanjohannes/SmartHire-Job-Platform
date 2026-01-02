package Package1;


/**
 * @author user
 * @version 1.0
 * @created 23-Dec-2025 3:47:46 AM
 */
public class jobApplication {

	public static final String STATUS_APPLIED = "applied";
	public static final String STATUS_REVIEWED = "reviewed";
	public static final String STATUS_INTERVIEW = "interview";
	public static final String STATUS_HIRED = "hired";
	public static final String STATUS_REJECTED = "rejected";

	public JobApplication(User applicant, Job job, String coverLetter) {
		this.applicant = applicant;
		this.job = job;
		this.coverLetter = coverLetter;
		this.status = STATUS_APPLIED;
		this.appliedAt = new java.util.Date();
		this.updatedAt = new java.util.Date();
	}

	public boolean updateStatus(String newStatus) {
		if (isValidStatusTransition(this.status, newStatus)) {
			this.status = newStatus;
			this.updatedAt = new java.util.Date();
			return true;
		}
		return false;
	}

	private boolean isValidStatusTransition(String oldStatus, String newStatus) {
		// Define allowed transitions
		Map<String, List<String>> transitions = new HashMap<>();
		transitions.put(STATUS_APPLIED, Arrays.asList(STATUS_REVIEWED, STATUS_REJECTED));
		transitions.put(STATUS_REVIEWED, Arrays.asList(STATUS_INTERVIEW, STATUS_REJECTED));
		transitions.put(STATUS_INTERVIEW, Arrays.asList(STATUS_HIRED, STATUS_REJECTED));

		return transitions.getOrDefault(oldStatus, new ArrayList<>()).contains(newStatus);
	}
}

	public void finalize() throws Throwable {

	}

	public string get_days_since_applide()(){
		return "";
	}

	public boolean is_in_progress()(){
		return false;
	}

	public JobApplication(){

	}

	public string toString(){
		return "";
	}

	public string update_status( )(){
		return "";
	}

}