package Package1;


/**
 * @author user
 * @version 1.0
 * @created 23-Dec-2025 3:47:45 AM
 */
public class JobAlert {

	private string id;
	private boolean is_active;
	private string job_type;
	private string keywords;
	private string location;
	public user m_user;



	public void finalize() throws Throwable {

	}

	public JobAlert(){

	}

	public boolean matches(job:job)(){
		return false;
	}

	public string toString(){
		return "";
	}

}