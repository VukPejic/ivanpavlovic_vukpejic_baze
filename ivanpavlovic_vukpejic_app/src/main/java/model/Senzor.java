package model;

import database.Konekcija;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Senzor {
    private final int id;
    private final String naziv;
    private final String opis;
    private final String izvor;

    public Senzor(int id, String naziv, String opis, String izvor) {
        this.id = id;
        this.naziv = naziv;
        this.opis = opis;
        this.izvor = izvor;
    }

    public int getId() {
        return id;
    }

    public String getNaziv() {
        return naziv;
    }

    public String getOpis() {
        return opis;
    }

    public String getIzvor() {
        return izvor;
    }

    public static List<Senzor> pronadjiZaEksperiment(int eksperimentId) throws SQLException {
        String sql = """
                SELECT senzor_id, naziv, opis, izvor
                FROM eksperiment_svi_senzori
                WHERE eksperiment_id = ?
                ORDER BY naziv, senzor_id
                """;

        List<Senzor> senzori = new ArrayList<>();

        try (Connection connection = Konekcija.getInstance().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, eksperimentId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    senzori.add(new Senzor(resultSet.getInt("senzor_id"), resultSet.getString("naziv"), resultSet.getString("opis"), resultSet.getString("izvor")));
                }
            }
        }

        return senzori;
    }
}
