package controller;

import model.Database;
import model.Korisnik;

import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.SQLException;
import java.util.Optional;

public class AuthController {
    public LoginResult prijavi(String username, String lozinka) {
        if (isBlank(username) || isBlank(lozinka)) {
            return LoginResult.fail("Unesi username i lozinku.");
        }

        try {
            Optional<Korisnik> korisnik = Database.getInstance().login(username.trim(), lozinka);
            return korisnik.map(LoginResult::success)
                    .orElseGet(() -> LoginResult.fail("Pogrešan username ili lozinka."));
        } catch (SQLException exception) {
            exception.printStackTrace();
            return LoginResult.fail("Greška pri povezivanju sa bazom. Proveri da li su XAMPP/MySQL pokrenuti i da li je baza importovana u phpMyAdmin.");
        }
    }

    public LoginResult registruj(String ime, String prezime, String kvalifikacije, String username, String lozinka) {
        if (isBlank(ime) || isBlank(prezime) || isBlank(kvalifikacije) || isBlank(username) || isBlank(lozinka)) {
            return LoginResult.fail("Popuni ime, prezime, kvalifikacije, username i lozinku.");
        }

        try {
            Korisnik korisnik = Database.getInstance().registrujKorisnika(
                    ime.trim(), prezime.trim(), kvalifikacije.trim(), username.trim(), lozinka
            );
            return LoginResult.success(korisnik);
        } catch (SQLIntegrityConstraintViolationException exception) {
            return LoginResult.fail("Korisnik sa ovim username-om već postoji.");
        } catch (SQLException exception) {
            exception.printStackTrace();
            return LoginResult.fail("Greška pri registraciji. Proveri da li su XAMPP/MySQL pokrenuti i da li je baza importovana u phpMyAdmin.");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public static class LoginResult {
        private final boolean success;
        private final Korisnik korisnik;
        private final String message;

        private LoginResult(boolean success, Korisnik korisnik, String message) {
            this.success = success;
            this.korisnik = korisnik;
            this.message = message;
        }

        public static LoginResult success(Korisnik korisnik) {
            return new LoginResult(true, korisnik, "");
        }

        public static LoginResult fail(String message) {
            return new LoginResult(false, null, message);
        }

        public boolean isSuccess() { return success; }
        public Korisnik getKorisnik() { return korisnik; }
        public String getMessage() { return message; }
    }
}
