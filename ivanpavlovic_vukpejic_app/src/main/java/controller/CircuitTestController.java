package controller;

import model.Database;
import model.ElektricnoKolo;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CircuitTestController {
    public CircuitListResult ucitajKola() {
        try {
            List<ElektricnoKolo> kola = Database.getInstance().ucitajElektricnaKola();
            if (kola.isEmpty()) {
                return CircuitListResult.fail(kola, "U bazi nema kola u tabeli elektricno_kolo.");
            }
            return CircuitListResult.success(kola);
        } catch (SQLException exception) {
            exception.printStackTrace();
            return CircuitListResult.fail(new ArrayList<>(), "Ne mogu da učitam kola iz baze: " + exception.getMessage());
        }
    }

    public OperationResult sacuvajIspitivanje(int elektricnoKoloId, double impedansa, double snaga, double struja) {
        try {
            Database.getInstance().sacuvajIspitivanje(elektricnoKoloId, impedansa, snaga, struja);
            return OperationResult.success("Kolo je nacrtano, rezultat je izračunat i upisan u tabelu ispitivanje.");
        } catch (SQLException exception) {
            exception.printStackTrace();
            return OperationResult.fail("Rezultat je izračunat, ali nije upisan u bazu: " + exception.getMessage());
        }
    }

    public static class CircuitListResult {
        private final boolean success;
        private final List<ElektricnoKolo> circuits;
        private final String message;
        private CircuitListResult(boolean success, List<ElektricnoKolo> circuits, String message) {
            this.success = success;
            this.circuits = circuits;
            this.message = message;
        }
        public static CircuitListResult success(List<ElektricnoKolo> circuits) { return new CircuitListResult(true, circuits, ""); }
        public static CircuitListResult fail(List<ElektricnoKolo> circuits, String message) { return new CircuitListResult(false, circuits, message); }
        public boolean isSuccess() { return success; }
        public List<ElektricnoKolo> getCircuits() { return circuits; }
        public String getMessage() { return message; }
    }

    public static class OperationResult {
        private final boolean success;
        private final String message;
        private OperationResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
        public static OperationResult success(String message) { return new OperationResult(true, message); }
        public static OperationResult fail(String message) { return new OperationResult(false, message); }
        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }
}
