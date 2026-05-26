package database;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Učitava podešavanja za bazu iz fajla src/main/resources/database.cfg.
 */
public class Config {
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/ivanpavlovic_vukpejic_baza?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";

    private final String url;
    private final String user;
    private final String password;

    public Config() {
        Properties properties = new Properties();

        try (InputStream inputStream = getClass().getResourceAsStream("/database.cfg")) {
            if (inputStream != null) {
                properties.load(inputStream);
            }
        } catch (IOException exception) {
            System.err.println("Ne mogu da pročitam database.cfg: " + exception.getMessage());
        }

        this.url = properties.getProperty("url", DEFAULT_URL);
        this.user = properties.getProperty("user", DEFAULT_USER);
        this.password = properties.getProperty("password", DEFAULT_PASSWORD);
    }

    public String getUrl() {
        return url;
    }

    public String getUser() {
        return user;
    }

    public String getPassword() {
        return password;
    }
}
