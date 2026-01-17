import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

public class ApplicationTest {

    @Test
    void testApplicationStatus() {
        Application app = new Application();
        app.setStatus("APPLIED");

        assertEquals("APPLIED", app.getStatus());
    }
}
