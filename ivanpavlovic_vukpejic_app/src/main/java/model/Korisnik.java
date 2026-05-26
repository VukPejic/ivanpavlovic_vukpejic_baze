package model;

import database.Konekcija;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.Optional;

public class Korisnik {
    private final int korisnikId;
    private final int istrazivacId;
    private final String ime;
    private final String prezime;
    private final String username;

    public Korisnik(int korisnikId, int istrazivacId, String ime, String prezime, String username) {
        this.korisnikId = korisnikId;
        this.istrazivacId = istrazivacId;
        this.ime = ime;
        this.prezime = prezime;
        this.username = username;
    }

    public int getKorisnikId() {
        return korisnikId;
    }

    public int getIstrazivacId() {
        return istrazivacId;
    }

    public String getIme() {
        return ime;
    }

    public String getPrezime() {
        return prezime;
    }

    public String getUsername() {
        return username;
    }

    public static Optional<Korisnik> prijavi(String username, String lozinka) throws SQLException {
        try (Connection connection = Konekcija.getInstance().getConnection()) {
            if (!proveriLoginPrekoFunkcije(connection, username, lozinka)) {
                return Optional.empty();
            }

            return pronadjiPoUsername(connection, username);
        }
    }

    public static Korisnik registruj(String ime, String prezime, String kvalifikacije, String username, String lozinka) throws SQLException {
        try (Connection connection = Konekcija.getInstance().getConnection()) {
            if (usernamePostoji(connection, username)) {
                throw new SQLIntegrityConstraintViolationException("Korisnik sa ovim username-om već postoji.");
            }

            pozoviProceduruZaRegistraciju(connection, ime, prezime, kvalifikacije, username, lozinka);

            return pronadjiPoUsername(connection, username).orElseThrow(() -> new SQLException("Korisnik nije pronađen posle registracije."));
        }
    }

    private static boolean proveriLoginPrekoFunkcije(Connection connection, String username, String lozinka) throws SQLException {
        String sql = "SELECT prijavi_korisnika(?, ?) AS uspesna_prijava";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username);
            statement.setString(2, lozinka);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() && resultSet.getBoolean("uspesna_prijava");
            }
        }
    }

    private static void pozoviProceduruZaRegistraciju(Connection connection, String ime, String prezime, String kvalifikacije, String username, String lozinka) throws SQLException {
        String sql = "{CALL registruj_korisnika(?, ?, ?, ?, ?)}";

        try (CallableStatement statement = connection.prepareCall(sql)) {
            statement.setString(1, ime);
            statement.setString(2, prezime);
            statement.setString(3, kvalifikacije);
            statement.setString(4, username);
            statement.setString(5, lozinka);
            statement.execute();
        }
    }

    private static boolean usernamePostoji(Connection connection, String username) throws SQLException {
        String sql = "SELECT 1 FROM korisnik WHERE username = ? LIMIT 1";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private static Optional<Korisnik> pronadjiPoUsername(Connection connection, String username) throws SQLException {
        String sql = """
                SELECT k.korisnik_id, k.istrazivac_id, k.username, i.ime, i.prezime
                FROM korisnik k
                JOIN istrazivac i ON i.istrazivac_id = k.istrazivac_id
                WHERE k.username = ?
                LIMIT 1
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapirajKorisnika(resultSet));
                }
            }
        }

        return Optional.empty();
    }

    private static Korisnik mapirajKorisnika(ResultSet resultSet) throws SQLException {
        return new Korisnik(resultSet.getInt("korisnik_id"), resultSet.getInt("istrazivac_id"), resultSet.getString("ime"), resultSet.getString("prezime"), resultSet.getString("username"));
    }
}
