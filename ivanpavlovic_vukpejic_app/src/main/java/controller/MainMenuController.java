package controller;

import javafx.stage.Stage;
import model.Korisnik;
import view.CircuitCreateView;
import view.CircuitView;
import view.ExperimentsView;
import view.ExperimentStatusView;
import view.LoginView;
import view.SessionDeleteView;

public class MainMenuController {
    public void otvoriIspitivanje(Stage stage, Korisnik korisnik) {
        new CircuitView().show(stage, korisnik);
    }

    public void otvoriUnosSeme(Stage stage, Korisnik korisnik) {
        new CircuitCreateView().show(stage, korisnik);
    }

    public void otvoriPregledEksperimenata(Stage stage, Korisnik korisnik) {
        new ExperimentsView().show(stage, korisnik);
    }

    public void otvoriPromenuStatusaEksperimenta(Stage stage, Korisnik korisnik) {
        new ExperimentStatusView().show(stage, korisnik);
    }

    public void otvoriBrisanjeSesije(Stage stage, Korisnik korisnik) {
        new SessionDeleteView().show(stage, korisnik);
    }

    public void odjaviSe(Stage stage) {
        new LoginView().show(stage);
    }
}
