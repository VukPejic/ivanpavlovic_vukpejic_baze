package view;

import controller.EksperimentStatusController;
import javafx.collections.FXCollections;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;
import javafx.util.StringConverter;
import model.Eksperiment;
import model.Korisnik;

public class ExperimentStatusView {
    private final EksperimentStatusController controller = new EksperimentStatusController();
    private final TableView<Eksperiment> tableView = new TableView<>();
    private final ComboBox<Eksperiment> experimentComboBox = new ComboBox<>();
    private final ComboBox<String> statusComboBox = new ComboBox<>();
    private final Label statusLabel = new Label();

    public void show(Stage stage, Korisnik korisnik) {
        Label titleLabel = new Label("Promena statusa eksperimenta");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        Label userLabel = new Label("Prijavljeni korisnik: " + korisnik.getIme() + " " + korisnik.getPrezime() + " (" + korisnik.getUsername() + ")");

        experimentComboBox.setPrefWidth(430);
        experimentComboBox.setConverter(new StringConverter<>() {
            @Override
            public String toString(Eksperiment eksperiment) {
                return eksperiment == null ? "" : eksperiment.getNazivSaId();
            }

            @Override
            public Eksperiment fromString(String string) {
                return null;
            }
        });

        statusComboBox.setItems(FXCollections.observableArrayList("planiran", "u toku", "pauziran", "zavrsen"));
        statusComboBox.setPrefWidth(160);

        Button changeButton = new Button("Promeni status");
        changeButton.setOnAction(event -> changeStatus());

        Button refreshButton = new Button("Osveži");
        refreshButton.setOnAction(event -> loadExperiments());

        Button backButton = new Button("Nazad na meni");
        backButton.setOnAction(event -> new MainMenuView().show(stage, korisnik));

        HBox controls = new HBox(10,
                new Label("Eksperiment:"), experimentComboBox,
                new Label("Novi status:"), statusComboBox,
                changeButton, refreshButton, backButton
        );
        controls.setAlignment(Pos.CENTER_LEFT);

        setupTable();
        VBox.setVgrow(tableView, Priority.ALWAYS);

        tableView.getSelectionModel().selectedItemProperty().addListener((obs, oldValue, newValue) -> {
            if (newValue != null) {
                experimentComboBox.getSelectionModel().select(newValue);
                statusComboBox.getSelectionModel().select(newValue.getStatus());
            }
        });

        statusLabel.setWrapText(true);
        statusLabel.setStyle("-fx-font-size: 14px; -fx-text-fill: #b00020;");

        VBox root = new VBox(12, titleLabel, userLabel, controls, tableView, statusLabel);
        root.setPadding(new Insets(18));

        stage.setTitle("Promena statusa eksperimenta");
        Scene scene = new Scene(root, 1220, 720);
        Style.apply(scene);
        stage.setScene(scene);
        stage.show();

        loadExperiments();
    }

    private void setupTable() {
        tableView.setColumnResizePolicy(TableView.CONSTRAINED_RESIZE_POLICY);
        tableView.getColumns().setAll(
                columnInt("ID", "id", 70),
                column("Naziv", "naziv", 220),
                column("Ciljevi", "ciljevi", 300),
                column("Teorijski okvir", "teorijskiOkvir", 320),
                column("Status", "status", 120)
        );
    }

    private TableColumn<Eksperiment, String> column(String title, String property, double width) {
        TableColumn<Eksperiment, String> column = new TableColumn<>(title);
        column.setCellValueFactory(new PropertyValueFactory<>(property));
        column.setPrefWidth(width);
        return column;
    }

    private TableColumn<Eksperiment, Integer> columnInt(String title, String property, double width) {
        TableColumn<Eksperiment, Integer> column = new TableColumn<>(title);
        column.setCellValueFactory(new PropertyValueFactory<>(property));
        column.setPrefWidth(width);
        return column;
    }

    private void loadExperiments() {
        EksperimentStatusController.ExperimentsLoadResult result = controller.ucitajEksperimente();
        tableView.setItems(FXCollections.observableArrayList(result.getEksperimenti()));
        experimentComboBox.setItems(FXCollections.observableArrayList(result.getEksperimenti()));
        if (!result.getEksperimenti().isEmpty()) {
            tableView.getSelectionModel().selectFirst();
        }
        statusLabel.setText(result.isSuccess() ? "" : result.getMessage());
    }

    private void changeStatus() {
        EksperimentStatusController.StatusChangeResult result = controller.promeniStatus(
                experimentComboBox.getValue(), statusComboBox.getValue()
        );
        statusLabel.setText(result.getMessage());
        if (result.isSuccess()) {
            loadExperiments();
        }
    }
}
