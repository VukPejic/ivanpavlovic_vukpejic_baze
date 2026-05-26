package controller;

import javafx.stage.Stage;
import model.Korisnik;
import view.ExperimentStatusView;
import view.ExperimentsView;
import view.LoginView;
import view.SessionDeleteView;

public class MainMenuController {
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
