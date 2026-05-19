package view;

import controller.MainMenuController;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;
import model.Korisnik;

public class MainMenuView {
    private final MainMenuController controller = new MainMenuController();

    public void show(Stage stage, Korisnik korisnik) {
        Label titleLabel = new Label("Izbor forme");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        Label userLabel = new Label("Prijavljeni korisnik: " + korisnik.getIme() + " " + korisnik.getPrezime() + " (" + korisnik.getUsername() + ")");

        Button testButton = menuButton("Ispitivanje električnog kola");
        testButton.setOnAction(event -> controller.otvoriIspitivanje(stage, korisnik));

        Button createButton = menuButton("Unos nove šeme kola");
        createButton.setOnAction(event -> controller.otvoriUnosSeme(stage, korisnik));

        Button experimentsButton = menuButton("Pregled eksperimenata");
        experimentsButton.setOnAction(event -> controller.otvoriPregledEksperimenata(stage, korisnik));

        Button statusButton = menuButton("Promena statusa eksperimenta");
        statusButton.setOnAction(event -> controller.otvoriPromenuStatusaEksperimenta(stage, korisnik));

        Button deleteSessionButton = menuButton("Brisanje sesije");
        deleteSessionButton.setOnAction(event -> controller.otvoriBrisanjeSesije(stage, korisnik));

        Button logoutButton = menuButton("Odjavi se");
        logoutButton.setOnAction(event -> controller.odjaviSe(stage));

        VBox root = new VBox(18, titleLabel, userLabel, testButton, createButton, experimentsButton, statusButton, deleteSessionButton, logoutButton);
        root.setAlignment(Pos.CENTER);
        root.setPadding(new Insets(30));

        stage.setTitle("Meni");
        stage.setScene(new Scene(root, 580, 560));
        stage.show();
    }

    private Button menuButton(String text) {
        Button button = new Button(text);
        button.setPrefWidth(320);
        return button;
    }
}
