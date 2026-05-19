package model;

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

    public int getId() { return id; }
    public String getNaziv() { return naziv; }
    public String getCiljevi() { return ciljevi; }
    public String getTeorijskiOkvir() { return teorijskiOkvir; }
    public String getStatus() { return status; }

    public String getNazivSaId() {
        return id + " - " + naziv;
    }
}
