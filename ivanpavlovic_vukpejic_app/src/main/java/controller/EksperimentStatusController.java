package controller;

import model.Eksperiment;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EksperimentStatusController {
    public ExperimentsLoadResult ucitajEksperimente() {
        try {
            List<Eksperiment> eksperimenti = Eksperiment.ucitajSve();
            return new ExperimentsLoadResult(true, eksperimenti, "");
        } catch (SQLException e) {
            return new ExperimentsLoadResult(false, new ArrayList<>(), "Ne mogu da učitam eksperimente.");
        }
    }

    public StatusChangeResult promeniStatus(Eksperiment eksperiment, String noviStatus) {
        if (eksperiment == null) {
            return new StatusChangeResult(false, "Izaberi eksperiment.");
        }

        if (noviStatus == null || noviStatus.trim().isEmpty()) {
            return new StatusChangeResult(false, "Izaberi novi status.");
        }

        try {
            String status = noviStatus.trim();
            Eksperiment.promeniStatus(eksperiment.getId(), status);
            return new StatusChangeResult(true, "Status je promenjen na: " + status);
        } catch (SQLException e) {
            return new StatusChangeResult(false, "Greška pri promeni statusa.");
        }
    }

    public static class ExperimentsLoadResult {
        private final boolean success;
        private final List<Eksperiment> eksperimenti;
        private final String message;

        public ExperimentsLoadResult(boolean success, List<Eksperiment> eksperimenti, String message) {
            this.success = success;
            this.eksperimenti = eksperimenti;
            this.message = message;
        }

        public boolean isSuccess() {
            return success;
        }

        public List<Eksperiment> getEksperimenti() {
            return eksperimenti;
        }

        public String getMessage() {
            return message;
        }
    }

    public static class StatusChangeResult {
        private final boolean success;
        private final String message;

        public StatusChangeResult(boolean success, String message) {
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
