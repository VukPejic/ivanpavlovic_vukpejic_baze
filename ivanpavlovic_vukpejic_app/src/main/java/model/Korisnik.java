package model;

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

    public String getEmail() {
        return username;
    }
}
