package model;

import java.time.LocalDate;
import java.time.LocalTime;

public class Sesija {
    private final int sesijaId;
    private final int izvodjenjeId;
    private final String nazivEksperimenta;
    private final LocalDate datum;
    private final LocalTime vremePocetka;
    private final LocalTime vremeZavrsetka;
    private final String status;

    public Sesija(int sesijaId, int izvodjenjeId, String nazivEksperimenta, LocalDate datum,
                  LocalTime vremePocetka, LocalTime vremeZavrsetka, String status) {
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
}
