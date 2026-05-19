package model;

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
}
