package model;

import java.io.IOException;
import java.io.InputStream;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Properties;

public class Database {
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/ivanpavlovic_vukpejic_baza?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";

    private static Database instance;

    private final String url;
    private final String user;
    private final String password;

    private Database() {
        Properties properties = loadProperties();
        this.url = properties.getProperty("db.url", DEFAULT_URL);
        this.user = properties.getProperty("db.user", DEFAULT_USER);
        this.password = properties.getProperty("db.password", DEFAULT_PASSWORD);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ignored) {
            // Maven dependency mysql-connector-j učitava drajver automatski.
        }
    }

    public static Database getInstance() {
        if (instance == null) {
            instance = new Database();
        }
        return instance;
    }

    private Properties loadProperties() {
        Properties properties = new Properties();
        try (InputStream inputStream = getClass().getResourceAsStream("/db.properties")) {
            if (inputStream != null) {
                properties.load(inputStream);
            }
        } catch (IOException e) {
            System.err.println("Ne mogu da pročitam db.properties: " + e.getMessage());
        }
        return properties;
    }

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }

    public Optional<Korisnik> login(String username, String lozinka) throws SQLException {
        String functionSql = "SELECT prijavi_korisnika(?, ?) AS uspesna_prijava";

        try (Connection connection = getConnection();
             PreparedStatement functionStatement = connection.prepareStatement(functionSql)) {

            functionStatement.setString(1, username);
            functionStatement.setString(2, lozinka);

            boolean uspesnaPrijava = false;
            try (ResultSet resultSet = functionStatement.executeQuery()) {
                if (resultSet.next()) {
                    uspesnaPrijava = resultSet.getBoolean("uspesna_prijava");
                }
            }

            if (!uspesnaPrijava) {
                return Optional.empty();
            }

            return ucitajKorisnikaPoUsername(connection, username);
        }
    }

    public Korisnik registrujKorisnika(String ime, String prezime, String kvalifikacije, String username, String lozinka) throws SQLException {
        try (Connection connection = getConnection()) {
            if (usernamePostoji(connection, username)) {
                throw new SQLIntegrityConstraintViolationException("Korisnik sa ovim username-om već postoji.");
            }

            try (CallableStatement callableStatement = connection.prepareCall("{CALL registruj_korisnika(?, ?, ?, ?, ?)}")) {
                callableStatement.setString(1, ime);
                callableStatement.setString(2, prezime);
                callableStatement.setString(3, kvalifikacije);
                callableStatement.setString(4, username);
                callableStatement.setString(5, lozinka);
                callableStatement.execute();
            }

            return ucitajKorisnikaPoUsername(connection, username)
                    .orElseThrow(() -> new SQLException("Registracija nije uspela: korisnik nije pronađen posle poziva procedure."));
        }
    }

    public List<ElektricnoKolo> ucitajElektricnaKola() throws SQLException {
        String sql = "SELECT elektricno_kolo_id, naziv, sema_kola FROM elektricno_kolo ORDER BY elektricno_kolo_id";
        List<ElektricnoKolo> kola = new ArrayList<>();

        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {
                kola.add(new ElektricnoKolo(
                        resultSet.getInt("elektricno_kolo_id"),
                        resultSet.getString("naziv"),
                        resultSet.getString("sema_kola")
                ));
            }
        }

        return kola;
    }


    public ElektricnoKolo sacuvajElektricnoKolo(String naziv, String semaKola) throws SQLException {
        String sql = "INSERT INTO elektricno_kolo (sema_kola, naziv) VALUES (?, ?)";

        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            preparedStatement.setString(1, semaKola);
            preparedStatement.setString(2, naziv);
            preparedStatement.executeUpdate();

            try (ResultSet generatedKeys = preparedStatement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return new ElektricnoKolo(generatedKeys.getInt(1), naziv, semaKola);
                }
            }
        }

        throw new SQLException("Nije moguće dobiti ID novog električnog kola.");
    }


    public List<Eksperiment> ucitajPlaniraneEksperimente() throws SQLException {
        return ucitajEksperimenteIzViewa("planirani_eksperimenti");
    }

    public List<Eksperiment> ucitajIzradjeneEksperimente() throws SQLException {
        return ucitajEksperimenteIzViewa("izradjeni_eksperimenti");
    }

    private List<Eksperiment> ucitajEksperimenteIzViewa(String viewName) throws SQLException {
        String sql = "SELECT naziv, ciljevi, teorijski_okvir FROM " + viewName + " ORDER BY naziv";
        List<Eksperiment> eksperimenti = new ArrayList<>();

        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {
                eksperimenti.add(new Eksperiment(
                        resultSet.getString("naziv"),
                        resultSet.getString("ciljevi"),
                        resultSet.getString("teorijski_okvir")
                ));
            }
        }

        return eksperimenti;
    }


    public List<Eksperiment> ucitajSveEksperimente() throws SQLException {
        String sql = "SELECT eksperiment_id, naziv, ciljevi, teorijski_okvir, status FROM eksperiment ORDER BY eksperiment_id";
        List<Eksperiment> eksperimenti = new ArrayList<>();

        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {
                eksperimenti.add(new Eksperiment(
                        resultSet.getInt("eksperiment_id"),
                        resultSet.getString("naziv"),
                        resultSet.getString("ciljevi"),
                        resultSet.getString("teorijski_okvir"),
                        resultSet.getString("status")
                ));
            }
        }

        return eksperimenti;
    }

    public void promeniStatusEksperimenta(int eksperimentId, String noviStatus) throws SQLException {
        String sql = "UPDATE eksperiment SET status = ? WHERE eksperiment_id = ?";

        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, noviStatus);
            preparedStatement.setInt(2, eksperimentId);

            int updatedRows = preparedStatement.executeUpdate();
            if (updatedRows == 0) {
                throw new SQLException("Eksperiment sa izabranim ID-em nije pronađen.");
            }
        }
    }

    public void sacuvajIspitivanje(int elektricnoKoloId, double impedansa, double snaga, double struja) throws SQLException {
        String sql = "INSERT INTO ispitivanje (elektricno_kolo_id, impedansa, snaga, struja, datum_pocetka, status) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setInt(1, elektricnoKoloId);
            preparedStatement.setDouble(2, impedansa);
            preparedStatement.setDouble(3, snaga);
            preparedStatement.setDouble(4, struja);
            preparedStatement.setDate(5, java.sql.Date.valueOf(LocalDate.now()));
            preparedStatement.setString(6, "zavrseno");
            preparedStatement.executeUpdate();
        }
    }

    public List<Sesija> ucitajSesije() throws SQLException {
        String sql = """
                SELECT s.sesija_id, s.izvodjenje_id, e.naziv AS naziv_eksperimenta,
                       s.datum, s.vreme_pocetka, s.vreme_zavrsetka, s.status
                FROM sesija s
                JOIN izvodjenje i ON i.izvodjenje_id = s.izvodjenje_id
                JOIN eksperiment e ON e.eksperiment_id = i.eksperiment_id
                ORDER BY s.datum, s.vreme_pocetka, s.sesija_id
                """;
        List<Sesija> sesije = new ArrayList<>();

        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {
                java.sql.Date datum = resultSet.getDate("datum");
                java.sql.Time vremePocetka = resultSet.getTime("vreme_pocetka");
                java.sql.Time vremeZavrsetka = resultSet.getTime("vreme_zavrsetka");
                sesije.add(new Sesija(
                        resultSet.getInt("sesija_id"),
                        resultSet.getInt("izvodjenje_id"),
                        resultSet.getString("naziv_eksperimenta"),
                        datum == null ? null : datum.toLocalDate(),
                        vremePocetka == null ? null : vremePocetka.toLocalTime(),
                        vremeZavrsetka == null ? null : vremeZavrsetka.toLocalTime(),
                        resultSet.getString("status")
                ));
            }
        }

        return sesije;
    }

    public int izbrisiSesiju(int istrazivacId, int sesijaId) throws SQLException {
        try (Connection connection = getConnection();
             CallableStatement callableStatement = connection.prepareCall("{CALL izbrisi_sesiju(?, ?, ?)}")) {

            callableStatement.setInt(1, istrazivacId);
            callableStatement.setInt(2, sesijaId);
            callableStatement.registerOutParameter(3, Types.INTEGER);
            callableStatement.execute();
            return callableStatement.getInt(3);
        }
    }


    private boolean usernamePostoji(Connection connection, String username) throws SQLException {
        String sql = "SELECT 1 FROM korisnik WHERE username = ? LIMIT 1";

        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setString(1, username);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private Optional<Korisnik> ucitajKorisnikaPoUsername(Connection connection, String username) throws SQLException {
        String sql = """
                SELECT k.korisnik_id, k.istrazivac_id, k.username, i.ime, i.prezime
                FROM korisnik k
                JOIN istrazivac i ON i.istrazivac_id = k.istrazivac_id
                WHERE k.username = ?
                LIMIT 1
                """;

        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setString(1, username);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapKorisnik(resultSet));
                }
            }
        }

        return Optional.empty();
    }

    private Korisnik mapKorisnik(ResultSet resultSet) throws SQLException {
        return new Korisnik(
                resultSet.getInt("korisnik_id"),
                resultSet.getInt("istrazivac_id"),
                resultSet.getString("ime"),
                resultSet.getString("prezime"),
                resultSet.getString("username")
        );
    }

}
