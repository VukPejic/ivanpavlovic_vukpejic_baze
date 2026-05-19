package view;

import controller.ExperimentsController;
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
import model.Eksperiment;
import model.Korisnik;

public class ExperimentsView {
    private final ExperimentsController controller = new ExperimentsController();
    private final TableView<Eksperiment> plannedTable = new TableView<>();
    private final TableView<Eksperiment> completedTable = new TableView<>();
    private final Label statusLabel = new Label();
    private final Label plannedCountLabel = new Label("Planirani: 0");
    private final Label completedCountLabel = new Label("Izvršeni: 0");

    public void show(Stage stage, Korisnik korisnik) {
        Label titleLabel = new Label("Pregled planiranih i izvršenih eksperimenata");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        Label userLabel = new Label("Prijavljeni korisnik: " + korisnik.getIme() + " " + korisnik.getPrezime() + " (" + korisnik.getUsername() + ")");

        Button refreshButton = new Button("Osveži prikaz");
        refreshButton.setOnAction(event -> loadExperiments());

        Button backButton = new Button("Nazad na meni");
        backButton.setOnAction(event -> new MainMenuView().show(stage, korisnik));

        HBox controls = new HBox(10, refreshButton, backButton, plannedCountLabel, completedCountLabel);
        controls.setAlignment(Pos.CENTER_LEFT);

        setupTable(plannedTable);
        setupTable(completedTable);

        SplitPane splitPane = new SplitPane(createTableBox("Planirani eksperimenti", plannedTable), createTableBox("Izvršeni eksperimenti", completedTable));
        splitPane.setDividerPositions(0.5);
        VBox.setVgrow(splitPane, Priority.ALWAYS);

        statusLabel.setWrapText(true);
        statusLabel.setStyle("-fx-text-fill: #b00020;");

        VBox root = new VBox(12, titleLabel, userLabel, controls, splitPane, statusLabel);
        root.setPadding(new Insets(18));

        stage.setTitle("Pregled eksperimenata");
        stage.setScene(new Scene(root, 1240, 760));
        stage.show();

        loadExperiments();
    }

    private VBox createTableBox(String title, TableView<Eksperiment> tableView) {
        Label titleLabel = new Label(title);
        titleLabel.setStyle("-fx-font-size: 18px; -fx-font-weight: bold;");
        VBox box = new VBox(8, titleLabel, tableView);
        box.setPadding(new Insets(10));
        VBox.setVgrow(tableView, Priority.ALWAYS);
        return box;
    }

    private void setupTable(TableView<Eksperiment> tableView) {
        tableView.setColumnResizePolicy(TableView.CONSTRAINED_RESIZE_POLICY);
        tableView.getColumns().setAll(column("Naziv", "naziv", 180), column("Ciljevi", "ciljevi", 260), column("Teorijski okvir", "teorijskiOkvir", 300));
    }

    private TableColumn<Eksperiment, String> column(String title, String property, double width) {
        TableColumn<Eksperiment, String> column = new TableColumn<>(title);
        column.setCellValueFactory(new PropertyValueFactory<>(property));
        column.setPrefWidth(width);
        return column;
    }

    private void loadExperiments() {
        ExperimentsController.ExperimentsData data = controller.ucitajEksperimente();
        plannedTable.setItems(FXCollections.observableArrayList(data.getPlanirani()));
        completedTable.setItems(FXCollections.observableArrayList(data.getIzradjeni()));
        plannedCountLabel.setText("Planirani: " + data.getPlanirani().size());
        completedCountLabel.setText("Izvršeni: " + data.getIzradjeni().size());
        statusLabel.setText(data.isSuccess() ? "" : data.getMessage());
    }
}
