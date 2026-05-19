package controller;

import model.Database;
import model.Eksperiment;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ExperimentsController {
    public ExperimentsData ucitajEksperimente() {
        try {
            List<Eksperiment> planirani = Database.getInstance().ucitajPlaniraneEksperimente();
            List<Eksperiment> izradjeni = Database.getInstance().ucitajIzradjeneEksperimente();
            return ExperimentsData.success(planirani, izradjeni);
        } catch (SQLException exception) {
            exception.printStackTrace();
            return ExperimentsData.fail("Ne mogu da učitam eksperimente iz view-ova planirani_eksperimenti i izradjeni_eksperimenti: " + exception.getMessage());
        }
    }

    public static class ExperimentsData {
        private final boolean success;
        private final List<Eksperiment> planirani;
        private final List<Eksperiment> izradjeni;
        private final String message;

        private ExperimentsData(boolean success, List<Eksperiment> planirani, List<Eksperiment> izradjeni, String message) {
            this.success = success;
            this.planirani = planirani;
            this.izradjeni = izradjeni;
            this.message = message;
        }

        public static ExperimentsData success(List<Eksperiment> planirani, List<Eksperiment> izradjeni) {
            return new ExperimentsData(true, planirani, izradjeni, "");
        }

        public static ExperimentsData fail(String message) {
            return new ExperimentsData(false, new ArrayList<>(), new ArrayList<>(), message);
        }

        public boolean isSuccess() { return success; }
        public List<Eksperiment> getPlanirani() { return planirani; }
        public List<Eksperiment> getIzradjeni() { return izradjeni; }
        public String getMessage() { return message; }
    }
}
