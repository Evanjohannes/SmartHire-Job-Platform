import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

public class UserTest {

    @Test
    void testUserCreation() {
        User user = new User("John Doe", "john@example.com", "JOB_SEEKER");

        assertEquals("John Doe", user.getName());
        assertEquals("john@example.com", user.getEmail());
        assertEquals("JOB_SEEKER", user.getRole());
    }

    @Test
    void testSetters() {
        User user = new User();
        user.setName("Alice");
        user.setEmail("alice@mail.com");

        assertEquals("Alice", user.getName());
        assertEquals("alice@mail.com", user.getEmail());
    }
}
