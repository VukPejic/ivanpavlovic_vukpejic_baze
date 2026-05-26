package view;

import controller.EksperimentiController;
import javafx.collections.FXCollections;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.stage.Stage;
import model.Eksperiment;
import model.ElektricnoKolo;
import model.Korisnik;
import model.Prototip;
import model.Senzor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class ExperimentsView {
    private final EksperimentiController controller = new EksperimentiController();
    private final TableView<Eksperiment> plannedTable = new TableView<>();
    private final TableView<Eksperiment> completedTable = new TableView<>();
    private final Label statusLabel = new Label();
    private final Label plannedCountLabel = new Label("Planirani: 0");
    private final Label completedCountLabel = new Label("Izvršeni: 0");
    private final Label selectedCircuitLabel = new Label("Izaberi eksperiment da se prikaže povezano kolo.");
    private static final double CIRCUIT_VIEW_WIDTH = 720;
    private static final double CIRCUIT_VIEW_HEIGHT = 470;
    private final Canvas circuitCanvas = new Canvas(CIRCUIT_VIEW_WIDTH, CIRCUIT_VIEW_HEIGHT);
    private final TableView<Senzor> sensorsTable = new TableView<>();
    private final TableView<Prototip> prototypesTable = new TableView<>();

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
        setupSelectionListeners();
        setupSensorsTable();
        setupPrototypesTable();

        SplitPane tablesPane = new SplitPane(
                createTableBox("Planirani eksperimenti", plannedTable),
                createTableBox("Izvršeni eksperimenti", completedTable)
        );
        tablesPane.setDividerPositions(0.5);
        tablesPane.setPrefHeight(310);
        tablesPane.setMinHeight(290);

        selectedCircuitLabel.setStyle("-fx-font-size: 16px; -fx-font-weight: bold;");

        ScrollPane circuitScrollPane = new ScrollPane(circuitCanvas);
        circuitScrollPane.setFitToWidth(false);
        circuitScrollPane.setFitToHeight(false);
        circuitScrollPane.setPannable(true);
        circuitScrollPane.setStyle("-fx-background: white; -fx-background-color: white;");
        circuitScrollPane.setPrefSize(CIRCUIT_VIEW_WIDTH + 25, CIRCUIT_VIEW_HEIGHT + 25);
        circuitScrollPane.setMinSize(660, 430);
        HBox.setHgrow(circuitScrollPane, Priority.ALWAYS);

        VBox sensorPrototypeBox = new VBox(10, createSensorBox(), createPrototypeBox());
        sensorPrototypeBox.setPrefWidth(590);
        sensorPrototypeBox.setMinWidth(550);
        sensorPrototypeBox.setMaxWidth(650);

        VBox circuitBox = new VBox(8, selectedCircuitLabel, circuitScrollPane);
        circuitBox.setPrefWidth(CIRCUIT_VIEW_WIDTH + 40);
        HBox.setHgrow(circuitBox, Priority.ALWAYS);

        HBox detailsAndCircuit = new HBox(12, sensorPrototypeBox, circuitBox);
        detailsAndCircuit.setAlignment(Pos.TOP_LEFT);
        VBox.setVgrow(detailsAndCircuit, Priority.ALWAYS);

        statusLabel.setWrapText(true);
        statusLabel.setStyle("-fx-text-fill: #b00020;");

        VBox root = new VBox(12, titleLabel, userLabel, controls, tablesPane, detailsAndCircuit, statusLabel);
        root.setPadding(new Insets(18));

        stage.setTitle("Pregled eksperimenata");
        Scene scene = new Scene(root, 1400, 920);
        Style.apply(scene);
        stage.setScene(scene);
        stage.show();

        clearCanvas("Izaberi eksperiment iz jedne od tabela da se nacrta povezano električno kolo.");
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

    private VBox createSensorBox() {
        Label titleLabel = new Label("Senzori povezani sa eksperimentom");
        titleLabel.setStyle("-fx-font-size: 16px; -fx-font-weight: bold;");
        sensorsTable.setPrefHeight(155);
        sensorsTable.setMinHeight(130);
        VBox box = new VBox(8, titleLabel, sensorsTable);
        box.setPadding(new Insets(10));
        VBox.setVgrow(sensorsTable, Priority.ALWAYS);
        return box;
    }

    private VBox createPrototypeBox() {
        Label titleLabel = new Label("Prototipovi povezani sa eksperimentom");
        titleLabel.setStyle("-fx-font-size: 16px; -fx-font-weight: bold;");
        prototypesTable.setPrefHeight(155);
        prototypesTable.setMinHeight(130);
        VBox box = new VBox(8, titleLabel, prototypesTable);
        box.setPadding(new Insets(10));
        VBox.setVgrow(prototypesTable, Priority.ALWAYS);
        return box;
    }

    private void setupSensorsTable() {
        sensorsTable.setColumnResizePolicy(TableView.CONSTRAINED_RESIZE_POLICY);
        sensorsTable.getColumns().setAll(
                sensorColumnInt("ID", "id", 70),
                sensorColumn("Naziv", "naziv", 210),
                sensorColumn("Opis", "opis", 360),
                sensorColumn("Izvor", "izvor", 130)
        );
    }

    private void setupPrototypesTable() {
        prototypesTable.setColumnResizePolicy(TableView.CONSTRAINED_RESIZE_POLICY);
        prototypesTable.getColumns().setAll(
                prototypeColumnInt("ID", "id", 70),
                prototypeColumn("Naziv", "naziv", 230),
                prototypeColumn("Opis", "opis", 390),
                prototypeColumn("Izvor", "izvor", 130)
        );
    }

    private void setupTable(TableView<Eksperiment> tableView) {
        tableView.setColumnResizePolicy(TableView.CONSTRAINED_RESIZE_POLICY);
        tableView.getColumns().setAll(
                columnInt("ID", "id", 70),
                column("Naziv", "naziv", 220),
                column("Ciljevi", "ciljevi", 300),
                column("Teorijski okvir", "teorijskiOkvir", 320)
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

    private TableColumn<Senzor, String> sensorColumn(String title, String property, double width) {
        TableColumn<Senzor, String> column = new TableColumn<>(title);
        column.setCellValueFactory(new PropertyValueFactory<>(property));
        column.setPrefWidth(width);
        return column;
    }

    private TableColumn<Senzor, Integer> sensorColumnInt(String title, String property, double width) {
        TableColumn<Senzor, Integer> column = new TableColumn<>(title);
        column.setCellValueFactory(new PropertyValueFactory<>(property));
        column.setPrefWidth(width);
        return column;
    }

    private TableColumn<Prototip, String> prototypeColumn(String title, String property, double width) {
        TableColumn<Prototip, String> column = new TableColumn<>(title);
        column.setCellValueFactory(new PropertyValueFactory<>(property));
        column.setPrefWidth(width);
        return column;
    }

    private TableColumn<Prototip, Integer> prototypeColumnInt(String title, String property, double width) {
        TableColumn<Prototip, Integer> column = new TableColumn<>(title);
        column.setCellValueFactory(new PropertyValueFactory<>(property));
        column.setPrefWidth(width);
        return column;
    }

    private void setupSelectionListeners() {
        plannedTable.getSelectionModel().selectedItemProperty().addListener((observable, oldValue, selected) -> {
            if (selected != null) {
                completedTable.getSelectionModel().clearSelection();
                loadAndDrawCircuit(selected);
            }
        });

        completedTable.getSelectionModel().selectedItemProperty().addListener((observable, oldValue, selected) -> {
            if (selected != null) {
                plannedTable.getSelectionModel().clearSelection();
                loadAndDrawCircuit(selected);
            }
        });
    }

    private void loadExperiments() {
        EksperimentiController.ExperimentsData data = controller.ucitajEksperimente();
        plannedTable.setItems(FXCollections.observableArrayList(data.getPlanirani()));
        completedTable.setItems(FXCollections.observableArrayList(data.getIzradjeni()));
        plannedCountLabel.setText("Planirani: " + data.getPlanirani().size());
        completedCountLabel.setText("Izvršeni: " + data.getIzradjeni().size());
        statusLabel.setText(data.isSuccess() ? "" : data.getMessage());
        selectedCircuitLabel.setText("Izaberi eksperiment da se prikaže povezano kolo.");
        clearCanvas("Izaberi eksperiment iz jedne od tabela da se nacrta povezano električno kolo.");
        sensorsTable.setItems(FXCollections.observableArrayList());
        prototypesTable.setItems(FXCollections.observableArrayList());
    }

    private void loadAndDrawCircuit(Eksperiment eksperiment) {
        EksperimentiController.ExperimentDetailsResult result = controller.ucitajDetaljeEksperimenta(eksperiment);

        sensorsTable.setItems(FXCollections.observableArrayList(result.getSenzori()));
        prototypesTable.setItems(FXCollections.observableArrayList(result.getPrototipovi()));

        if (!result.isSuccess()) {
            selectedCircuitLabel.setText("Eksperiment: " + eksperiment.getNaziv());
            clearCanvas(result.getMessage());
            statusLabel.setText(result.getMessage());
            return;
        }

        List<ElektricnoKolo> kola = result.getKola();
        selectedCircuitLabel.setText("Eksperiment: " + eksperiment.getNaziv()
                + " | Kola: " + kola.size()
                + " | Senzori: " + result.getSenzori().size()
                + " | Prototipovi: " + result.getPrototipovi().size());
        statusLabel.setText("");

        if (kola.isEmpty()) {
            clearCanvas("Za ovaj eksperiment nema povezanog električnog kola, ali su prikazani senzori i prototipovi.");
        } else {
            drawCircuits(kola);
        }
    }

    private void clearCanvas(String message) {
        GraphicsContext gc = circuitCanvas.getGraphicsContext2D();
        gc.setFill(Color.WHITE);
        gc.fillRect(0, 0, circuitCanvas.getWidth(), circuitCanvas.getHeight());
        gc.setFill(Color.web("#294e75"));
        gc.setFont(Font.font("Arial", 14));
        gc.fillText(message, 20, 45);
    }

    private void drawCircuits(List<ElektricnoKolo> kola) {
        try {
            List<CircuitDrawing> drawings = new ArrayList<>();

            for (ElektricnoKolo kolo : kola) {
                CircuitElement root = new SchemeParser(kolo.getSemaKola()).parse();
                root.assignNames(new ComponentNamer());
                LayoutInfo layout = root.measure();
                drawings.add(new CircuitDrawing(kolo, root, layout));
            }

            double canvasWidth = CIRCUIT_VIEW_WIDTH;
            double canvasHeight = Math.max(CIRCUIT_VIEW_HEIGHT, CIRCUIT_VIEW_HEIGHT * drawings.size());
            circuitCanvas.setWidth(canvasWidth);
            circuitCanvas.setHeight(canvasHeight);

            GraphicsContext gc = circuitCanvas.getGraphicsContext2D();
            gc.setFill(Color.WHITE);
            gc.fillRect(0, 0, canvasWidth, canvasHeight);

            double margin = 35;
            double terminalSpace = 45;

            for (int i = 0; i < drawings.size(); i++) {
                CircuitDrawing drawing = drawings.get(i);
                double slotTop = i * CIRCUIT_VIEW_HEIGHT;
                double originalCircuitWidth = margin * 2 + terminalSpace * 2 + drawing.layout.width;
                double originalCircuitHeight = 42 + drawing.layout.height + 45;
                double scale = Math.min(
                        (CIRCUIT_VIEW_WIDTH - 24) / originalCircuitWidth,
                        (CIRCUIT_VIEW_HEIGHT - 24) / originalCircuitHeight
                );
                scale = Math.min(1.12, Math.max(0.45, scale));

                gc.save();
                gc.translate(12, slotTop + 12);
                gc.scale(scale, scale);
                gc.setStroke(Color.web("#294e75"));
                gc.setFill(Color.web("#294e75"));
                gc.setLineWidth(2.4);
                drawSingleCircuit(gc, drawing, margin, terminalSpace, 12);
                gc.restore();

                if (i < drawings.size() - 1) {
                    gc.setStroke(Color.web("#d6e1ec"));
                    gc.setLineWidth(1.2);
                    gc.strokeLine(15, slotTop + CIRCUIT_VIEW_HEIGHT - 2, CIRCUIT_VIEW_WIDTH - 15, slotTop + CIRCUIT_VIEW_HEIGHT - 2);
                }
            }
        } catch (Exception exception) {
            clearCanvas("Greška pri crtanju kola: " + exception.getMessage());
        }
    }

    private void drawSingleCircuit(GraphicsContext gc,
                                   CircuitDrawing drawing,
                                   double margin,
                                   double terminalSpace,
                                   double topY) {
        gc.setFont(Font.font("Arial", 15));
        gc.setFill(Color.web("#294e75"));
        gc.fillText("Električno kolo: " + drawing.kolo.getNazivSaId(), margin, topY);

        double startX = margin + terminalSpace;
        double startY = topY + 32;
        double leftTerminalX = margin;
        double rightTerminalX = margin + terminalSpace + drawing.layout.width + terminalSpace;
        double entryY = startY + drawing.layout.entryY;

        drawTerminal(gc, leftTerminalX, entryY);
        gc.strokeLine(leftTerminalX + 9, entryY, startX, entryY);
        drawing.root.draw(gc, startX, startY);
        gc.strokeLine(startX + drawing.layout.width, startY + drawing.layout.exitY, rightTerminalX - 9, startY + drawing.layout.exitY);
        drawTerminal(gc, rightTerminalX, startY + drawing.layout.exitY);

        gc.setFont(Font.font("Arial", 12));
        gc.setFill(Color.web("#294e75"));
        String legend = String.join("   ", drawing.root.legendLines());
        if (legend.length() > 140) {
            legend = legend.substring(0, 140) + "...";
        }
        gc.fillText("Oznake: " + legend, margin, startY + drawing.layout.height + 24);
    }

    private void drawTerminal(GraphicsContext gc, double x, double y) {
        gc.setFill(Color.WHITE);
        gc.setStroke(Color.web("#294e75"));
        gc.fillOval(x - 9, y - 9, 18, 18);
        gc.strokeOval(x - 9, y - 9, 18, 18);
    }

    private enum ElementType {
        R, L, C, SER, PAR
    }

    private static class LayoutInfo {
        private final double width;
        private final double height;
        private final double entryY;
        private final double exitY;

        private LayoutInfo(double width, double height, double entryY, double exitY) {
            this.width = width;
            this.height = height;
            this.entryY = entryY;
            this.exitY = exitY;
        }
    }

    private static class CircuitElement {
        private static final double COMPONENT_WIDTH = 82;
        private static final double COMPONENT_HEIGHT = 32;
        private static final double SERIES_GAP = 18;
        private static final double PARALLEL_MARGIN = 32;
        private static final double PARALLEL_GAP = 18;
        private static final double PARALLEL_PADDING = 16;

        private final ElementType type;
        private final String valueText;
        private final List<CircuitElement> children;
        private String name;

        private CircuitElement(ElementType type, String valueText, List<CircuitElement> children) {
            this.type = type;
            this.valueText = valueText;
            this.children = children;
        }

        private static CircuitElement component(ElementType type, String valueText) {
            return new CircuitElement(type, valueText, List.of());
        }

        private static CircuitElement group(ElementType type, List<CircuitElement> children) {
            return new CircuitElement(type, "", children);
        }

        private void assignNames(ComponentNamer namer) {
            if (type == ElementType.R || type == ElementType.L || type == ElementType.C) {
                name = namer.next(type);
                return;
            }
            for (CircuitElement child : children) {
                child.assignNames(namer);
            }
        }

        private List<String> legendLines() {
            List<String> lines = new ArrayList<>();
            collectLegend(lines);
            return lines;
        }

        private void collectLegend(List<String> lines) {
            if (type == ElementType.R || type == ElementType.L || type == ElementType.C) {
                lines.add(name + "=" + valueText);
                return;
            }
            for (CircuitElement child : children) {
                child.collectLegend(lines);
            }
        }

        private LayoutInfo measure() {
            if (type == ElementType.R || type == ElementType.L || type == ElementType.C) {
                return new LayoutInfo(COMPONENT_WIDTH, COMPONENT_HEIGHT, COMPONENT_HEIGHT / 2, COMPONENT_HEIGHT / 2);
            }

            if (type == ElementType.SER) {
                double width = 0;
                double height = 0;

                for (CircuitElement child : children) {
                    LayoutInfo childLayout = child.measure();
                    width += childLayout.width;
                    height = Math.max(height, childLayout.height);
                }

                if (!children.isEmpty()) {
                    width += SERIES_GAP * (children.size() - 1);
                }

                return new LayoutInfo(width, height, height / 2, height / 2);
            }

            double maxWidth = 0;
            double totalHeight = 0;

            for (CircuitElement child : children) {
                LayoutInfo childLayout = child.measure();
                maxWidth = Math.max(maxWidth, childLayout.width);
                totalHeight += childLayout.height;
            }

            if (!children.isEmpty()) {
                totalHeight += PARALLEL_GAP * (children.size() - 1);
            }

            double width = maxWidth + PARALLEL_MARGIN * 2;
            double height = totalHeight + PARALLEL_PADDING * 2;
            return new LayoutInfo(width, height, height / 2, height / 2);
        }

        private void draw(GraphicsContext gc, double x, double y) {
            if (type == ElementType.R || type == ElementType.L || type == ElementType.C) {
                drawComponent(gc, x, y);
            } else if (type == ElementType.SER) {
                drawSeries(gc, x, y);
            } else {
                drawParallel(gc, x, y);
            }
        }

        private void drawComponent(GraphicsContext gc, double x, double y) {
            double centerY = y + COMPONENT_HEIGHT / 2;
            gc.strokeLine(x, centerY, x + 12, centerY);
            gc.strokeLine(x + COMPONENT_WIDTH - 12, centerY, x + COMPONENT_WIDTH, centerY);
            gc.setFill(Color.WHITE);
            gc.fillRoundRect(x + 10, y + 3, COMPONENT_WIDTH - 20, COMPONENT_HEIGHT - 6, 12, 12);
            gc.strokeRoundRect(x + 10, y + 3, COMPONENT_WIDTH - 20, COMPONENT_HEIGHT - 6, 12, 12);
            gc.setFill(Color.web("#294e75"));
            gc.setFont(Font.font("Arial", 13));
            gc.fillText(name, x + COMPONENT_WIDTH / 2 - 10, y + COMPONENT_HEIGHT / 2 + 5);
        }

        private void drawSeries(GraphicsContext gc, double x, double y) {
            LayoutInfo layout = measure();
            double centerY = y + layout.height / 2;
            double currentX = x;
            double previousRightX = x;

            for (int i = 0; i < children.size(); i++) {
                CircuitElement child = children.get(i);
                LayoutInfo childLayout = child.measure();
                double childY = y + (layout.height - childLayout.height) / 2;

                if (i > 0) {
                    gc.strokeLine(previousRightX, centerY, currentX, centerY);
                }

                child.draw(gc, currentX, childY);
                previousRightX = currentX + childLayout.width;
                currentX = previousRightX + SERIES_GAP;
            }
        }

        private void drawParallel(GraphicsContext gc, double x, double y) {
            LayoutInfo layout = measure();
            double leftBusX = x + PARALLEL_MARGIN;
            double rightBusX = x + layout.width - PARALLEL_MARGIN;
            double centerY = y + layout.height / 2;

            List<LayoutInfo> childLayouts = new ArrayList<>();
            List<Double> childYPositions = new ArrayList<>();
            double currentY = y + PARALLEL_PADDING;

            for (CircuitElement child : children) {
                LayoutInfo childLayout = child.measure();
                childLayouts.add(childLayout);
                childYPositions.add(currentY);
                currentY += childLayout.height + PARALLEL_GAP;
            }

            if (children.isEmpty()) {
                return;
            }

            double firstCenterY = childYPositions.get(0) + childLayouts.get(0).height / 2;
            double lastCenterY = childYPositions.get(childYPositions.size() - 1) + childLayouts.get(childLayouts.size() - 1).height / 2;

            gc.strokeLine(x, centerY, leftBusX, centerY);
            gc.strokeLine(rightBusX, centerY, x + layout.width, centerY);
            gc.strokeLine(leftBusX, firstCenterY, leftBusX, lastCenterY);
            gc.strokeLine(rightBusX, firstCenterY, rightBusX, lastCenterY);

            for (int i = 0; i < children.size(); i++) {
                CircuitElement child = children.get(i);
                LayoutInfo childLayout = childLayouts.get(i);
                double childY = childYPositions.get(i);
                double branchCenterY = childY + childLayout.height / 2;
                double childX = leftBusX + (rightBusX - leftBusX - childLayout.width) / 2;

                gc.strokeLine(leftBusX, branchCenterY, childX, branchCenterY);
                child.draw(gc, childX, childY);
                gc.strokeLine(childX + childLayout.width, branchCenterY, rightBusX, branchCenterY);
            }
        }
    }

    private static class CircuitDrawing {
        private final ElektricnoKolo kolo;
        private final CircuitElement root;
        private final LayoutInfo layout;

        private CircuitDrawing(ElektricnoKolo kolo, CircuitElement root, LayoutInfo layout) {
            this.kolo = kolo;
            this.root = root;
            this.layout = layout;
        }
    }

    private static class ComponentNamer {
        private final Map<ElementType, Integer> counters = new HashMap<>();

        private String next(ElementType type) {
            int number = counters.getOrDefault(type, 0) + 1;
            counters.put(type, number);
            return type.name() + number;
        }
    }

    private static class SchemeParser {
        private final String text;
        private int position = 0;

        private SchemeParser(String text) {
            this.text = text == null ? "" : text.trim();
        }

        private CircuitElement parse() {
            CircuitElement element = parseElement();
            skipWhitespace();
            if (position != text.length()) {
                throw new IllegalArgumentException("Neočekivan tekst u šemi: " + text.substring(position));
            }
            return element;
        }

        private CircuitElement parseElement() {
            skipWhitespace();
            String name = readName().toUpperCase(Locale.ROOT);
            expect('(');

            if (name.equals("R") || name.equals("L") || name.equals("C")) {
                String value = readUntilClosingParenthesis();
                return CircuitElement.component(ElementType.valueOf(name), value);
            }

            if (!name.equals("SER") && !name.equals("PAR")) {
                throw new IllegalArgumentException("Nepoznat tip veze/komponente: " + name);
            }

            List<CircuitElement> children = new ArrayList<>();
            while (true) {
                children.add(parseElement());
                skipWhitespace();
                if (peek() == ',') {
                    position++;
                    continue;
                }
                if (peek() == ')') {
                    position++;
                    break;
                }
                throw new IllegalArgumentException("Očekivan je zarez ili zatvorena zagrada.");
            }

            return CircuitElement.group(ElementType.valueOf(name), children);
        }

        private String readName() {
            skipWhitespace();
            int start = position;
            while (position < text.length() && Character.isLetter(text.charAt(position))) {
                position++;
            }
            if (start == position) {
                throw new IllegalArgumentException("Očekivan je naziv elementa.");
            }
            return text.substring(start, position);
        }

        private String readUntilClosingParenthesis() {
            int start = position;
            while (position < text.length() && text.charAt(position) != ')') {
                position++;
            }
            if (position >= text.length()) {
                throw new IllegalArgumentException("Nedostaje zatvorena zagrada.");
            }
            String value = text.substring(start, position).trim();
            position++;
            return value;
        }

        private void expect(char expected) {
            skipWhitespace();
            if (position >= text.length() || text.charAt(position) != expected) {
                throw new IllegalArgumentException("Očekivan znak: " + expected);
            }
            position++;
        }

        private char peek() {
            skipWhitespace();
            if (position >= text.length()) {
                return '\0';
            }
            return text.charAt(position);
        }

        private void skipWhitespace() {
            while (position < text.length() && Character.isWhitespace(text.charAt(position))) {
                position++;
            }
        }
    }
}
