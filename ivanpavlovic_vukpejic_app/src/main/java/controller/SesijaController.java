package controller;

import model.Sesija;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SesijaController {
    public SessionListResult ucitajSesije() {
        try {
            List<Sesija> sesije = Sesija.ucitajSve();
            return new SessionListResult(true, sesije, "");
        } catch (SQLException e) {
            return new SessionListResult(false, new ArrayList<>(), "Ne mogu da učitam sesije.");
        }
    }

    public OperationResult izbrisiSesiju(int istrazivacId, int sesijaId) {
        try {
            int brojObrisanih = Sesija.izbrisiPrekoProcedure(istrazivacId, sesijaId);

            if (brojObrisanih > 0) {
                return new OperationResult(true, "Sesija je obrisana.");
            }

            return new OperationResult(false, "Ne možeš da obrišeš ovu sesiju.");
        } catch (SQLException e) {
            return new OperationResult(false, "Greška pri brisanju sesije.");
        }
    }

    public static class SessionListResult {
        private final boolean success;
        private final List<Sesija> sessions;
        private final String message;

        public SessionListResult(boolean success, List<Sesija> sessions, String message) {
            this.success = success;
            this.sessions = sessions;
            this.message = message;
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

        public OperationResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }
    }
}
