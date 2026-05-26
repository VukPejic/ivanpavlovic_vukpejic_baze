package model;

import database.Konekcija;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class Sesija {
    private final int sesijaId;
    private final int izvodjenjeId;
    private final String nazivEksperimenta;
    private final LocalDate datum;
    private final LocalTime vremePocetka;
    private final LocalTime vremeZavrsetka;
    private final String status;

    public Sesija(int sesijaId, int izvodjenjeId, String nazivEksperimenta, LocalDate datum, LocalTime vremePocetka, LocalTime vremeZavrsetka, String status) {
        this.sesijaId = sesijaId;
        this.izvodjenjeId = izvodjenjeId;
        this.nazivEksperimenta = nazivEksperimenta;
        this.datum = datum;
        this.vremePocetka = vremePocetka;
        this.vremeZavrsetka = vremeZavrsetka;
        this.status = status;
    }

    public int getSesijaId() {
        return sesijaId;
    }

    public int getIzvodjenjeId() {
        return izvodjenjeId;
    }

    public String getNazivEksperimenta() {
        return nazivEksperimenta;
    }

    public LocalDate getDatum() {
        return datum;
    }

    public LocalTime getVremePocetka() {
        return vremePocetka;
    }

    public LocalTime getVremeZavrsetka() {
        return vremeZavrsetka;
    }

    public String getStatus() {
        return status;
    }

    public static List<Sesija> ucitajSve() throws SQLException {
        String sql = """
                SELECT s.sesija_id,
                       s.izvodjenje_id,
                       e.naziv AS naziv_eksperimenta,
                       s.datum,
                       s.vreme_pocetka,
                       s.vreme_zavrsetka,
                       s.status
                FROM sesija s
                JOIN izvodjenje i ON i.izvodjenje_id = s.izvodjenje_id
                JOIN eksperiment e ON e.eksperiment_id = i.eksperiment_id
                ORDER BY s.datum, s.vreme_pocetka, s.sesija_id
                """;
        List<Sesija> sesije = new ArrayList<>();

        try (Connection connection = Konekcija.getInstance().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                sesije.add(mapirajSesiju(resultSet));
            }
        }

        return sesije;
    }

    public static int izbrisiPrekoProcedure(int istrazivacId, int sesijaId) throws SQLException {
        String sql = "{CALL izbrisi_sesiju(?, ?, ?)}";

        try (Connection connection = Konekcija.getInstance().getConnection();
             CallableStatement statement = connection.prepareCall(sql)) {

            statement.setInt(1, istrazivacId);
            statement.setInt(2, sesijaId);
            statement.registerOutParameter(3, Types.INTEGER);
            statement.execute();
            return statement.getInt(3);
        }
    }

    private static Sesija mapirajSesiju(ResultSet resultSet) throws SQLException {
        Date datum = resultSet.getDate("datum");
        Time vremePocetka = resultSet.getTime("vreme_pocetka");
        Time vremeZavrsetka = resultSet.getTime("vreme_zavrsetka");

        return new Sesija(resultSet.getInt("sesija_id"), resultSet.getInt("izvodjenje_id"), resultSet.getString("naziv_eksperimenta"), datum == null ? null : datum.toLocalDate(), vremePocetka == null ? null : vremePocetka.toLocalTime(), vremeZavrsetka == null ? null : vremeZavrsetka.toLocalTime(), resultSet.getString("status"));
    }
}
