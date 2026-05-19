package model;

import java.time.LocalDate;

public class Ispitivanje {
    private final int ispitivanjeId;
    private final int elektricnoKoloId;
    private final String nazivKola;
    private final double napon;
    private final double snaga;
    private final double struja;
    private final LocalDate datumPocetka;
    private final String status;

    public Ispitivanje(int ispitivanjeId,
                       int elektricnoKoloId,
                       String nazivKola,
                       double napon,
                       double snaga,
                       double struja,
                       LocalDate datumPocetka,
                       String status) {
        this.ispitivanjeId = ispitivanjeId;
        this.elektricnoKoloId = elektricnoKoloId;
        this.nazivKola = nazivKola;
        this.napon = napon;
        this.snaga = snaga;
        this.struja = struja;
        this.datumPocetka = datumPocetka;
        this.status = status;
    }

    public int getIspitivanjeId() {
        return ispitivanjeId;
    }

    public int getElektricnoKoloId() {
        return elektricnoKoloId;
    }

    public String getNazivKola() {
        return nazivKola;
    }

    public double getNapon() {
        return napon;
    }

    public double getSnaga() {
        return snaga;
    }

    public double getStruja() {
        return struja;
    }

    public LocalDate getDatumPocetka() {
        return datumPocetka;
    }

    public String getStatus() {
        return status;
    }
}
