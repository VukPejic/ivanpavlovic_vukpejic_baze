package controller;

import model.Database;
import model.Eksperiment;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ExperimentStatusController {
    public ExperimentsLoadResult ucitajEksperimente() {
        try {
            return ExperimentsLoadResult.success(Database.getInstance().ucitajSveEksperimente());
        } catch (SQLException exception) {
            exception.printStackTrace();
            return ExperimentsLoadResult.fail("Ne mogu da učitam eksperimente iz tabele eksperiment: " + exception.getMessage());
        }
    }

    public StatusChangeResult promeniStatus(Eksperiment eksperiment, String noviStatus) {
        if (eksperiment == null) {
            return StatusChangeResult.fail("Izaberi eksperiment kome menjaš status.");
        }
        if (noviStatus == null || noviStatus.trim().isEmpty()) {
            return StatusChangeResult.fail("Izaberi novi status.");
        }

        try {
            Database.getInstance().promeniStatusEksperimenta(eksperiment.getId(), noviStatus.trim());
            return StatusChangeResult.success("Status eksperimenta je promenjen na: " + noviStatus.trim());
        } catch (SQLException exception) {
            exception.printStackTrace();
            return StatusChangeResult.fail("Greška pri promeni statusa: " + exception.getMessage());
        }
    }

    public static class ExperimentsLoadResult {
        private final boolean success;
        private final List<Eksperiment> eksperimenti;
        private final String message;

        private ExperimentsLoadResult(boolean success, List<Eksperiment> eksperimenti, String message) {
            this.success = success;
            this.eksperimenti = eksperimenti;
            this.message = message;
        }

        public static ExperimentsLoadResult success(List<Eksperiment> eksperimenti) {
            return new ExperimentsLoadResult(true, eksperimenti, "");
        }

        public static ExperimentsLoadResult fail(String message) {
            return new ExperimentsLoadResult(false, new ArrayList<>(), message);
        }

        public boolean isSuccess() { return success; }
        public List<Eksperiment> getEksperimenti() { return eksperimenti; }
        public String getMessage() { return message; }
    }

    public static class StatusChangeResult {
        private final boolean success;
        private final String message;

        private StatusChangeResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static StatusChangeResult success(String message) { return new StatusChangeResult(true, message); }
        public static StatusChangeResult fail(String message) { return new StatusChangeResult(false, message); }
        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
