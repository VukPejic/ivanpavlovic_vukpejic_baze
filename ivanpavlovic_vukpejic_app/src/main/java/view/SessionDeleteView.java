package view;

import controller.SessionDeleteController;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;
import model.Korisnik;
import model.Sesija;

public class SessionDeleteView {
    private final SessionDeleteController controller = new SessionDeleteController();
    private final TableView<Sesija> table = new TableView<>();
    private final Label statusLabel = new Label();

    public void show(Stage stage, Korisnik korisnik) {
        Label titleLabel = new Label("Brisanje sesije");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        Label userLabel = new Label("Prijavljeni istraživač: " + korisnik.getIme() + " " + korisnik.getPrezime() + " (ID: " + korisnik.getIstrazivacId() + ")");
        Label infoLabel = new Label("Sesiju može da obriše samo istraživač koji učestvuje u eksperimentu za izabranu sesiju.");
        infoLabel.setWrapText(true);

        setupTable();
        ucitajSesije();

        Button deleteButton = new Button("Obriši izabranu sesiju");
        deleteButton.setOnAction(event -> obrisiIzabranuSesiju(korisnik));

        Button refreshButton = new Button("Osveži prikaz");
        refreshButton.setOnAction(event -> ucitajSesije());

        Button backButton = new Button("Nazad na meni");
        backButton.setOnAction(event -> new MainMenuView().show(stage, korisnik));

        HBox buttons = new HBox(10, deleteButton, refreshButton, backButton);
        buttons.setAlignment(Pos.CENTER_RIGHT);

        statusLabel.setWrapText(true);
        statusLabel.setStyle("-fx-text-fill: #294e75;");

        VBox root = new VBox(14, titleLabel, userLabel, infoLabel, table, buttons, statusLabel);
        root.setPadding(new Insets(20));

        stage.setTitle("Brisanje sesije");
        stage.setScene(new Scene(root, 1100, 700));
        stage.show();
    }

    private void setupTable() {
        TableColumn<Sesija, String> idColumn = new TableColumn<>("ID sesije");
        idColumn.setCellValueFactory(data -> new SimpleStringProperty(String.valueOf(data.getValue().getSesijaId())));
        idColumn.setPrefWidth(90);

        TableColumn<Sesija, String> izvodjenjeColumn = new TableColumn<>("ID izvođenja");
        izvodjenjeColumn.setCellValueFactory(data -> new SimpleStringProperty(String.valueOf(data.getValue().getIzvodjenjeId())));
        izvodjenjeColumn.setPrefWidth(110);

        TableColumn<Sesija, String> eksperimentColumn = new TableColumn<>("Eksperiment");
        eksperimentColumn.setCellValueFactory(data -> new SimpleStringProperty(nullToDash(data.getValue().getNazivEksperimenta())));
        eksperimentColumn.setPrefWidth(360);

        TableColumn<Sesija, String> datumColumn = new TableColumn<>("Datum");
        datumColumn.setCellValueFactory(data -> new SimpleStringProperty(data.getValue().getDatum() == null ? "-" : data.getValue().getDatum().toString()));
        datumColumn.setPrefWidth(110);

        TableColumn<Sesija, String> pocetakColumn = new TableColumn<>("Početak");
        pocetakColumn.setCellValueFactory(data -> new SimpleStringProperty(data.getValue().getVremePocetka() == null ? "-" : data.getValue().getVremePocetka().toString()));
        pocetakColumn.setPrefWidth(100);

        TableColumn<Sesija, String> krajColumn = new TableColumn<>("Kraj");
        krajColumn.setCellValueFactory(data -> new SimpleStringProperty(data.getValue().getVremeZavrsetka() == null ? "-" : data.getValue().getVremeZavrsetka().toString()));
        krajColumn.setPrefWidth(100);

        TableColumn<Sesija, String> statusColumn = new TableColumn<>("Status");
        statusColumn.setCellValueFactory(data -> new SimpleStringProperty(nullToDash(data.getValue().getStatus())));
        statusColumn.setPrefWidth(140);

        table.getColumns().setAll(idColumn, izvodjenjeColumn, eksperimentColumn, datumColumn, pocetakColumn, krajColumn, statusColumn);
        table.setPrefHeight(520);
    }

    private void ucitajSesije() {
        SessionDeleteController.SessionListResult result = controller.ucitajSesije();
        table.setItems(FXCollections.observableArrayList(result.getSessions()));
        if (result.isSuccess()) {
            statusLabel.setText("Učitano sesija: " + result.getSessions().size());
        } else {
            statusLabel.setText(result.getMessage());
        }
    }

    private void obrisiIzabranuSesiju(Korisnik korisnik) {
        Sesija selected = table.getSelectionModel().getSelectedItem();
        if (selected == null) {
            statusLabel.setText("Izaberi sesiju koju želiš da obrišeš.");
            return;
        }

        SessionDeleteController.OperationResult result = controller.izbrisiSesiju(korisnik.getIstrazivacId(), selected.getSesijaId());
        statusLabel.setText(result.getMessage());
        if (result.isSuccess()) {
            ucitajSesije();
        }
    }

    private String nullToDash(String value) {
        return value == null || value.isBlank() ? "-" : value;
    }
}
