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

        Button experimentsButton = menuButton("Pregled eksperimenata");
        experimentsButton.setOnAction(event -> controller.otvoriPregledEksperimenata(stage, korisnik));

        Button statusButton = menuButton("Promena statusa eksperimenta");
        statusButton.setOnAction(event -> controller.otvoriPromenuStatusaEksperimenta(stage, korisnik));

        Button deleteSessionButton = menuButton("Brisanje sesije");
        deleteSessionButton.setOnAction(event -> controller.otvoriBrisanjeSesije(stage, korisnik));

        Button logoutButton = menuButton("Odjavi se");
        logoutButton.setOnAction(event -> controller.odjaviSe(stage));

        VBox root = new VBox(18, titleLabel, userLabel, experimentsButton, statusButton, deleteSessionButton, logoutButton);
        root.setAlignment(Pos.CENTER);
        root.setPadding(new Insets(30));

        stage.setTitle("Meni");
        Scene scene = new Scene(root, 560, 460);
        Style.apply(scene);
        stage.setScene(scene);
        stage.show();
    }

    private Button menuButton(String text) {
        Button button = new Button(text);
        button.setPrefWidth(320);
        return button;
    }
}
