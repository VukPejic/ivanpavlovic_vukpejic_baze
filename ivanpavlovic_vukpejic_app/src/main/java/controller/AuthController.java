package controller;

import model.Korisnik;

import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.SQLException;
import java.util.Optional;

public class AuthController {
    public LoginResult prijavi(String username, String lozinka) {
        username = srediTekst(username);

        if (username.isEmpty() || lozinka == null || lozinka.isEmpty()) {
            return new LoginResult(false, null, "Unesi username i lozinku.");
        }

        try {
            Optional<Korisnik> korisnik = Korisnik.prijavi(username, lozinka);

            if (korisnik.isPresent()) {
                return new LoginResult(true, korisnik.get(), "");
            }

            return new LoginResult(false, null, "Pogrešan username ili lozinka.");
        } catch (SQLException e) {
            return new LoginResult(false, null, "Greška pri povezivanju sa bazom.");
        }
    }

    public LoginResult registruj(String ime, String prezime, String kvalifikacije, String username, String lozinka) {
        ime = srediTekst(ime);
        prezime = srediTekst(prezime);
        kvalifikacije = srediTekst(kvalifikacije);
        username = srediTekst(username);

        if (ime.isEmpty() || prezime.isEmpty() || kvalifikacije.isEmpty() || username.isEmpty() || lozinka == null || lozinka.isEmpty()) {
            return new LoginResult(false, null, "Popuni sva polja za registraciju.");
        }

        try {
            Korisnik korisnik = Korisnik.registruj(ime, prezime, kvalifikacije, username, lozinka);
            return new LoginResult(true, korisnik, "");
        } catch (SQLIntegrityConstraintViolationException e) {
            return new LoginResult(false, null, "Korisnik sa ovim username-om već postoji.");
        } catch (SQLException e) {
            return new LoginResult(false, null, "Greška pri registraciji korisnika.");
        }
    }

    private String srediTekst(String tekst) {
        if (tekst == null) {
            return "";
        }
        return tekst.trim();
    }

    public static class LoginResult {
        private final boolean success;
        private final Korisnik korisnik;
        private final String message;

        public LoginResult(boolean success, Korisnik korisnik, String message) {
            this.success = success;
            this.korisnik = korisnik;
            this.message = message;
        }

        public boolean isSuccess() {
            return success;
        }

        public Korisnik getKorisnik() {
            return korisnik;
        }

        public String getMessage() {
            return message;
        }
    }
}
