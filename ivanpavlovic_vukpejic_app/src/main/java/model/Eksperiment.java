package model;

import database.Konekcija;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Eksperiment {
    private final int id;
    private final String naziv;
    private final String ciljevi;
    private final String teorijskiOkvir;
    private final String status;

    public Eksperiment(String naziv, String ciljevi, String teorijskiOkvir) {
        this(0, naziv, ciljevi, teorijskiOkvir, "");
    }

    public Eksperiment(int id, String naziv, String ciljevi, String teorijskiOkvir, String status) {
        this.id = id;
        this.naziv = naziv;
        this.ciljevi = ciljevi;
        this.teorijskiOkvir = teorijskiOkvir;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public String getNaziv() {
        return naziv;
    }

    public String getCiljevi() {
        return ciljevi;
    }

    public String getTeorijskiOkvir() {
        return teorijskiOkvir;
    }

    public String getStatus() {
        return status;
    }

    public String getNazivSaId() {
        return id + " - " + naziv;
    }

    public static List<Eksperiment> ucitajPlanirane() throws SQLException {
        return ucitajIzViewa("planirani_eksperimenti", "planiran");
    }

    public static List<Eksperiment> ucitajIzradjene() throws SQLException {
        return ucitajIzViewa("izradjeni_eksperimenti", "zavrsen");
    }

    public static List<Eksperiment> ucitajSve() throws SQLException {
        String sql = """
                SELECT eksperiment_id, naziv, ciljevi, teorijski_okvir, status
                FROM eksperiment
                ORDER BY eksperiment_id
                """;
        List<Eksperiment> eksperimenti = new ArrayList<>();

        try (Connection connection = Konekcija.getInstance().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                eksperimenti.add(mapirajEksperiment(resultSet));
            }
        }

        return eksperimenti;
    }

    public static void promeniStatus(int eksperimentId, String noviStatus) throws SQLException {
        String sql = "UPDATE eksperiment SET status = ? WHERE eksperiment_id = ?";

        try (Connection connection = Konekcija.getInstance().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, noviStatus);
            statement.setInt(2, eksperimentId);

            int brojIzmenjenihRedova = statement.executeUpdate();
            if (brojIzmenjenihRedova == 0) {
                throw new SQLException("Eksperiment sa izabranim ID-em nije pronađen.");
            }
        }
    }

    private static List<Eksperiment> ucitajIzViewa(String nazivViewa, String status) throws SQLException {
        String sql = """
                SELECT e.eksperiment_id, v.naziv, v.ciljevi, v.teorijski_okvir, e.status
                FROM %s v
                JOIN eksperiment e
                    ON e.naziv = v.naziv
                   AND e.ciljevi = v.ciljevi
                   AND e.teorijski_okvir = v.teorijski_okvir
                   AND e.status = ?
                ORDER BY v.naziv
                """.formatted(nazivViewa);

        List<Eksperiment> eksperimenti = new ArrayList<>();

        try (Connection connection = Konekcija.getInstance().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, status);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    eksperimenti.add(mapirajEksperiment(resultSet));
                }
            }
        }

        return eksperimenti;
    }

    private static Eksperiment mapirajEksperiment(ResultSet resultSet) throws SQLException {
        return new Eksperiment(resultSet.getInt("eksperiment_id"), resultSet.getString("naziv"), resultSet.getString("ciljevi"), resultSet.getString("teorijski_okvir"), resultSet.getString("status"));
    }
}
