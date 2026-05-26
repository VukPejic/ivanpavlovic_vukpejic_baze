package model;

import database.Konekcija;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ElektricnoKolo {
    private final int id;
    private final String naziv;
    private final String semaKola;

    public ElektricnoKolo(int id, String naziv, String semaKola) {
        this.id = id;
        this.naziv = naziv;
        this.semaKola = semaKola;
    }

    public int getId() {
        return id;
    }

    public String getNaziv() {
        return naziv;
    }

    public String getSemaKola() {
        return semaKola;
    }

    public String getNazivSaId() {
        return id + " - " + naziv;
    }

    public static List<ElektricnoKolo> pronadjiEksperiment(int eksperimentId) throws SQLException {
        String sql = """
                SELECT elektricno_kolo_id, naziv, sema_kola
                FROM eksperiment_sva_kola
                WHERE eksperiment_id = ?
                ORDER BY elektricno_kolo_id
                """;

        List<ElektricnoKolo> kola = new ArrayList<>();

        try (Connection connection = Konekcija.getInstance().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, eksperimentId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    kola.add(new ElektricnoKolo(resultSet.getInt("elektricno_kolo_id"), resultSet.getString("naziv"), resultSet.getString("sema_kola")));
                }
            }
        }

        return kola;
    }
}
