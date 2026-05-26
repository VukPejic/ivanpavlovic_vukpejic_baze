package controller;

import model.Eksperiment;
import model.ElektricnoKolo;
import model.Prototip;
import model.Senzor;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EksperimentiController {
    public ExperimentsData ucitajEksperimente() {
        try {
            List<Eksperiment> planirani = Eksperiment.ucitajPlanirane();
            List<Eksperiment> izradjeni = Eksperiment.ucitajIzradjene();
            return new ExperimentsData(true, planirani, izradjeni, "");
        } catch (SQLException e) {
            return new ExperimentsData(false, new ArrayList<>(), new ArrayList<>(), "Ne mogu da učitam eksperimente.");
        }
    }

    public ExperimentDetailsResult ucitajDetaljeEksperimenta(Eksperiment eksperiment) {
        if (eksperiment == null) {
            return new ExperimentDetailsResult(false, new ArrayList<>(), new ArrayList<>(), new ArrayList<>(), "Izaberi eksperiment.");
        }

        try {
            int id = eksperiment.getId();
            List<ElektricnoKolo> kola = ElektricnoKolo.pronadjiEksperiment(id);
            List<Senzor> senzori = Senzor.pronadjiZaEksperiment(id);
            List<Prototip> prototipovi = Prototip.pronadjiZaEksperiment(id);

            return new ExperimentDetailsResult(true, kola, senzori, prototipovi, "");
        } catch (SQLException e) {
            return new ExperimentDetailsResult(false, new ArrayList<>(), new ArrayList<>(), new ArrayList<>(), "Ne mogu da učitam detalje eksperimenta.");
        }
    }

    public static class ExperimentsData {
        private final boolean success;
        private final List<Eksperiment> planirani;
        private final List<Eksperiment> izradjeni;
        private final String message;

        public ExperimentsData(boolean success, List<Eksperiment> planirani, List<Eksperiment> izradjeni, String message) {
            this.success = success;
            this.planirani = planirani;
            this.izradjeni = izradjeni;
            this.message = message;
        }

        public boolean isSuccess() {
            return success;
        }

        public List<Eksperiment> getPlanirani() {
            return planirani;
        }

        public List<Eksperiment> getIzradjeni() {
            return izradjeni;
        }

        public String getMessage() {
            return message;
        }
    }

    public static class ExperimentDetailsResult {
        private final boolean success;
        private final List<ElektricnoKolo> kola;
        private final List<Senzor> senzori;
        private final List<Prototip> prototipovi;
        private final String message;

        public ExperimentDetailsResult(boolean success, List<ElektricnoKolo> kola, List<Senzor> senzori, List<Prototip> prototipovi, String message) {
            this.success = success;
            this.kola = kola;
            this.senzori = senzori;
            this.prototipovi = prototipovi;
            this.message = message;
        }

        public boolean isSuccess() {
            return success;
        }

        public List<ElektricnoKolo> getKola() {
            return kola;
        }

        public ElektricnoKolo getKolo() {
            if (kola.isEmpty()) {
                return null;
            }
            return kola.get(0);
        }

        public List<Senzor> getSenzori() {
            return senzori;
        }

        public List<Prototip> getPrototipovi() {
            return prototipovi;
        }

        public String getMessage() {
            return message;
        }
    }
}
