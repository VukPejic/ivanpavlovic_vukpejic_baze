package controller;

import model.Database;
import model.Sesija;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SessionDeleteController {
    public SessionListResult ucitajSesije() {
        try {
            return SessionListResult.success(Database.getInstance().ucitajSesije());
        } catch (SQLException exception) {
            exception.printStackTrace();
            return SessionListResult.fail(new ArrayList<>(), "Ne mogu da učitam sesije iz baze: " + exception.getMessage());
        }
    }

    public OperationResult izbrisiSesiju(int istrazivacId, int sesijaId) {
        try {
            int izbrisani = Database.getInstance().izbrisiSesiju(istrazivacId, sesijaId);
            if (izbrisani > 0) {
                return OperationResult.success("Sesija je uspešno obrisana.");
            }
            return OperationResult.fail("Sesija nije obrisana. Brisanje je dozvoljeno samo istraživačima koji učestvuju u eksperimentu na toj sesiji.");
        } catch (SQLException exception) {
            exception.printStackTrace();
            return OperationResult.fail("Greška pri brisanju sesije: " + exception.getMessage());
        }
    }

    public static class SessionListResult {
        private final boolean success;
        private final List<Sesija> sessions;
        private final String message;

        private SessionListResult(boolean success, List<Sesija> sessions, String message) {
            this.success = success;
            this.sessions = sessions;
            this.message = message;
        }

        public static SessionListResult success(List<Sesija> sessions) {
            return new SessionListResult(true, sessions, "");
        }

        public static SessionListResult fail(List<Sesija> sessions, String message) {
            return new SessionListResult(false, sessions, message);
        }

        public boolean isSuccess() {
            return success;
        }

        public List<Sesija> getSessions() {
            return sessions;
        }

        public String getMessage() {
            return message;
        }
    }

    public static class OperationResult {
        private final boolean success;
        private final String message;

        private OperationResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static OperationResult success(String message) {
            return new OperationResult(true, message);
        }

        public static OperationResult fail(String message) {
            return new OperationResult(false, message);
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }
    }
}
