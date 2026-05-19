package view;

import controller.CircuitTestController;
import javafx.collections.FXCollections;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.control.*;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.stage.Stage;
import javafx.util.StringConverter;
import model.ElektricnoKolo;
import model.Korisnik;

import java.util.*;

public class CircuitView {
    private final CircuitTestController controller = new CircuitTestController();
    private final Label statusLabel = new Label("Izaberi kolo iz baze, unesi napon/frekvenciju i klikni na dugme.");
    private final Label currentResultLabel = new Label("Struja: -");
    private final Label powerResultLabel = new Label("Snaga: -");
    private final Label impedanceResultLabel = new Label("Impedansa: -");
    private final TextField voltageField = new TextField("12");
    private final TextField frequencyField = new TextField("50");
    private final TextArea legendArea = new TextArea();
    private final Canvas circuitCanvas = new Canvas(980, 520);
    private ComboBox<ElektricnoKolo> nameComboBox;
    private ComboBox<ElektricnoKolo> schemeComboBox;
    private List<ElektricnoKolo> circuits = new ArrayList<>();
    private boolean syncingComboBoxes = false;

    public void show(Stage stage, Korisnik korisnik) {
        Label titleLabel = new Label("Ispitivanje električnog kola");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        Label userLabel = new Label("Prijavljeni korisnik: " + korisnik.getIme() + " " + korisnik.getPrezime() + " (" + korisnik.getUsername() + ")");

        ucitajKolaIzBaze();

        nameComboBox = new ComboBox<>(FXCollections.observableArrayList(circuits));
        schemeComboBox = new ComboBox<>(FXCollections.observableArrayList(circuits));

        nameComboBox.setConverter(new StringConverter<>() {
            @Override
            public String toString(ElektricnoKolo kolo) {
                return kolo == null ? "" : kolo.getNazivSaId();
            }

            @Override
            public ElektricnoKolo fromString(String string) {
                return null;
            }
        });

        schemeComboBox.setConverter(new StringConverter<>() {
            @Override
            public String toString(ElektricnoKolo kolo) {
                return kolo == null ? "" : kolo.getSemaKola();
            }

            @Override
            public ElektricnoKolo fromString(String string) {
                return null;
            }
        });

        nameComboBox.setPrefWidth(280);
        schemeComboBox.setPrefWidth(650);

        if (!circuits.isEmpty()) {
            nameComboBox.getSelectionModel().selectFirst();
            schemeComboBox.getSelectionModel().selectFirst();
        }

        nameComboBox.setOnAction(event -> syncComboBoxSelection(nameComboBox.getValue(), schemeComboBox));
        schemeComboBox.setOnAction(event -> syncComboBoxSelection(schemeComboBox.getValue(), nameComboBox));

        voltageField.setPrefWidth(120);
        frequencyField.setPrefWidth(120);

        Button testButton = new Button("Nacrtaj i izračunaj");
        testButton.setDefaultButton(true);
        testButton.setOnAction(event -> drawCalculateAndSave());

        Button logoutButton = new Button("Odjavi se");
        logoutButton.setOnAction(event -> new LoginView().show(stage));

        GridPane form = new GridPane();
        form.setHgap(12);
        form.setVgap(10);
        form.setPadding(new Insets(10));
        form.add(new Label("Naziv kola iz baze:"), 0, 0);
        form.add(nameComboBox, 1, 0);
        form.add(new Label("Šema kola iz baze:"), 2, 0);
        form.add(schemeComboBox, 3, 0);
        form.add(new Label("Napon izvora U [V]:"), 0, 1);
        form.add(voltageField, 1, 1);
        form.add(new Label("Frekvencija f [Hz]:"), 2, 1);
        form.add(frequencyField, 3, 1);

        HBox buttons = new HBox(10, testButton, logoutButton);
        buttons.setAlignment(Pos.CENTER_RIGHT);

        statusLabel.setWrapText(true);
        statusLabel.setStyle("-fx-font-size: 14px;");

        VBox top = new VBox(10, titleLabel, userLabel, form, buttons, statusLabel);
        top.setPadding(new Insets(15));

        ScrollPane canvasScrollPane = new ScrollPane(circuitCanvas);
        canvasScrollPane.setFitToWidth(false);
        canvasScrollPane.setFitToHeight(false);
        canvasScrollPane.setPannable(true);
        canvasScrollPane.setStyle("-fx-background: white; -fx-background-color: white;");

        legendArea.setEditable(false);
        legendArea.setWrapText(true);
        legendArea.setPrefRowCount(8);
        legendArea.setStyle("-fx-font-family: 'Consolas', 'Courier New', monospace; -fx-font-size: 14px;");
        legendArea.setText("Ovde će biti prikazane oznake i vrednosti komponenti.");

        VBox centerBox = new VBox(10, canvasScrollPane, legendArea);
        centerBox.setPadding(new Insets(0, 15, 15, 15));

        Label resultTitle = new Label("Rezultati");
        resultTitle.setStyle("-fx-font-size: 18px; -fx-font-weight: bold;");
        VBox resultsBox = new VBox(14, resultTitle, currentResultLabel, powerResultLabel, impedanceResultLabel);
        resultsBox.setPadding(new Insets(15));
        resultsBox.setPrefWidth(260);
        resultsBox.setStyle("-fx-border-color: #cccccc; -fx-border-width: 0 0 0 1; -fx-background-color: #fafafa;");

        BorderPane root = new BorderPane();
        root.setTop(top);
        root.setCenter(centerBox);
        root.setRight(resultsBox);

        Scene scene = new Scene(root, 1320, 830);
        stage.setTitle("Ispitivanje električnog kola");
        stage.setScene(scene);
        stage.show();

        clearCanvasMessage();
    }

    private void clearCanvasMessage() {
        GraphicsContext gc = circuitCanvas.getGraphicsContext2D();
        gc.setFill(Color.WHITE);
        gc.fillRect(0, 0, circuitCanvas.getWidth(), circuitCanvas.getHeight());
        gc.setFill(Color.web("#294e75"));
        gc.setFont(Font.font("Arial", 18));
        gc.fillText("Kolo će ovde biti nacrtano na način sličan električnoj šemi.", 40, 60);
    }

    private void ucitajKolaIzBaze() {
        CircuitTestController.CircuitListResult result = controller.ucitajKola();
        circuits = result.getCircuits();
        if (!result.isSuccess()) {
            statusLabel.setText(result.getMessage());
        }
    }

    private void syncComboBoxSelection(ElektricnoKolo selected, ComboBox<ElektricnoKolo> target) {
        if (syncingComboBoxes || selected == null) {
            return;
        }
        syncingComboBoxes = true;
        target.getSelectionModel().select(selected);
        syncingComboBoxes = false;
    }

    private void drawCalculateAndSave() {
        ElektricnoKolo circuit = nameComboBox.getValue();
        if (circuit == null) {
            statusLabel.setText("Nije izabrano kolo.");
            return;
        }

        double voltage;
        double frequency;
        try {
            voltage = parsePositiveDouble(voltageField.getText(), "napon");
            frequency = parsePositiveDouble(frequencyField.getText(), "frekvenciju");
        } catch (IllegalArgumentException exception) {
            statusLabel.setText(exception.getMessage());
            return;
        }

        try {
            CircuitElement rootElement = new SchemeParser(circuit.getSemaKola()).parse();
            ComponentNamer namer = new ComponentNamer();
            rootElement.assignNames(namer);

            Complex impedance = rootElement.impedance(frequency);
            double impedanceAbs = impedance.abs();
            if (impedanceAbs == 0 || Double.isNaN(impedanceAbs) || Double.isInfinite(impedanceAbs)) {
                throw new IllegalArgumentException("Impedansa kola nije ispravna za zadatu frekvenciju.");
            }

            double current = voltage / impedanceAbs;
            double activePower = current * current * impedance.re;
            if (activePower < 0) {
                activePower = Math.abs(activePower);
            }

            drawCircuit(rootElement, circuit.getNazivSaId());
            showLegend(rootElement);

            currentResultLabel.setText("Struja: " + formatWithPrefix(current, "A"));
            powerResultLabel.setText("Snaga: " + formatWithPrefix(activePower, "W"));
            impedanceResultLabel.setText("Impedansa: " + formatWithPrefix(impedanceAbs, "Ω"));

            CircuitTestController.OperationResult saveResult = controller.sacuvajIspitivanje(circuit.getId(), impedanceAbs, activePower, current);
            statusLabel.setText(saveResult.getMessage());
        } catch (Exception exception) {
            statusLabel.setText("Greška pri ispitivanju kola: " + exception.getMessage());
        }
    }

    private void drawCircuit(CircuitElement rootElement, String title) {
        LayoutInfo layout = rootElement.measure();
        double margin = 60;
        double leftTerminalSpace = 60;
        double rightTerminalSpace = 60;
        double topTitleSpace = 60;
        double width = Math.max(980, margin * 2 + leftTerminalSpace + layout.width + rightTerminalSpace);
        double height = Math.max(520, topTitleSpace + margin + layout.height + margin);

        circuitCanvas.setWidth(width);
        circuitCanvas.setHeight(height);

        GraphicsContext gc = circuitCanvas.getGraphicsContext2D();
        gc.setFill(Color.WHITE);
        gc.fillRect(0, 0, width, height);

        gc.setStroke(Color.web("#294e75"));
        gc.setFill(Color.web("#294e75"));
        gc.setLineWidth(3);
        gc.setFont(Font.font("Arial", 20));
        gc.fillText(title, 40, 35);

        double startX = margin + leftTerminalSpace;
        double startY = topTitleSpace + margin;
        double entryY = startY + layout.entryY;
        double leftTerminalX = margin;
        double rightTerminalX = margin + leftTerminalSpace + layout.width + rightTerminalSpace;

        drawTerminal(gc, leftTerminalX, entryY);
        gc.strokeLine(leftTerminalX + 12, entryY, startX, entryY);

        rootElement.draw(gc, startX, startY);

        double exitY = startY + layout.exitY;
        gc.strokeLine(startX + layout.width, exitY, rightTerminalX - 12, exitY);
        drawTerminal(gc, rightTerminalX, exitY);
    }

    private void showLegend(CircuitElement rootElement) {
        StringBuilder builder = new StringBuilder();
        builder.append("Oznake komponenti:\n");
        for (String line : rootElement.legendLines()) {
            builder.append(line).append("\n");
        }
        legendArea.setText(builder.toString());
    }

    private void drawTerminal(GraphicsContext gc, double x, double y) {
        gc.setFill(Color.WHITE);
        gc.setStroke(Color.web("#294e75"));
        gc.fillOval(x - 12, y - 12, 24, 24);
        gc.strokeOval(x - 12, y - 12, 24, 24);
    }

    private String formatWithPrefix(double value, String unit) {
        double abs = Math.abs(value);
        if (abs > 0 && abs < 0.001) {
            return String.format(Locale.US, "%.4f µ%s", value * 1_000_000.0, unit);
        }
        if (abs > 0 && abs < 1) {
            return String.format(Locale.US, "%.4f m%s", value * 1_000.0, unit);
        }
        return String.format(Locale.US, "%.4f %s", value, unit);
    }

    private double parsePositiveDouble(String text, String fieldName) {
        try {
            double value = Double.parseDouble(text.trim().replace(',', '.'));
            if (value <= 0) {
                throw new IllegalArgumentException("Unesi pozitivan broj za " + fieldName + ".");
            }
            return value;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("Unesi ispravan broj za " + fieldName + ".");
        }
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
        private static final double COMPONENT_WIDTH = 110;
        private static final double COMPONENT_HEIGHT = 42;
        private static final double SERIES_GAP = 30;
        private static final double PARALLEL_SIDE_MARGIN = 40;
        private static final double PARALLEL_BRANCH_GAP = 32;
        private static final double PARALLEL_TOP_BOTTOM_PADDING = 24;

        private final ElementType type;
        private final String rawLabel;
        private final double value;
        private final List<CircuitElement> children;
        private String displayName;

        private CircuitElement(ElementType type, String rawLabel, double value, List<CircuitElement> children) {
            this.type = type;
            this.rawLabel = rawLabel;
            this.value = value;
            this.children = children;
        }

        private static CircuitElement component(ElementType type, String label, double value) {
            return new CircuitElement(type, label, value, List.of());
        }

        private static CircuitElement group(ElementType type, List<CircuitElement> children) {
            return new CircuitElement(type, type.name(), 0, children);
        }

        private void assignNames(ComponentNamer namer) {
            if (type == ElementType.R || type == ElementType.L || type == ElementType.C) {
                displayName = namer.next(type);
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
                lines.add(displayName + " = " + rawLabel);
                return;
            }
            for (CircuitElement child : children) {
                child.collectLegend(lines);
            }
        }

        private LayoutInfo measure() {
            if (type == ElementType.R || type == ElementType.L || type == ElementType.C) {
                return new LayoutInfo(COMPONENT_WIDTH, COMPONENT_HEIGHT, COMPONENT_HEIGHT / 2.0, COMPONENT_HEIGHT / 2.0);
            }

            if (type == ElementType.SER) {
                double width = 0;
                double height = 0;
                List<LayoutInfo> childLayouts = new ArrayList<>();
                for (CircuitElement child : children) {
                    LayoutInfo childLayout = child.measure();
                    childLayouts.add(childLayout);
                    width += childLayout.width;
                    height = Math.max(height, childLayout.height);
                }
                if (!children.isEmpty()) {
                    width += SERIES_GAP * (children.size() - 1);
                }
                return new LayoutInfo(width, height, height / 2.0, height / 2.0);
            }

            double maxChildWidth = 0;
            double totalChildHeight = 0;
            for (CircuitElement child : children) {
                LayoutInfo childLayout = child.measure();
                maxChildWidth = Math.max(maxChildWidth, childLayout.width);
                totalChildHeight += childLayout.height;
            }
            if (!children.isEmpty()) {
                totalChildHeight += PARALLEL_BRANCH_GAP * (children.size() - 1);
            }
            double width = maxChildWidth + 2 * PARALLEL_SIDE_MARGIN;
            double height = totalChildHeight + 2 * PARALLEL_TOP_BOTTOM_PADDING;
            return new LayoutInfo(width, height, height / 2.0, height / 2.0);
        }

        private void draw(GraphicsContext gc, double x, double y) {
            switch (type) {
                case R, L, C -> drawComponent(gc, x, y, displayName);
                case SER -> drawSeries(gc, x, y);
                case PAR -> drawParallel(gc, x, y);
            }
        }

        private void drawComponent(GraphicsContext gc, double x, double y, String name) {
            double cy = y + COMPONENT_HEIGHT / 2.0;
            gc.strokeLine(x, cy, x + 12, cy);
            gc.strokeLine(x + COMPONENT_WIDTH - 12, cy, x + COMPONENT_WIDTH, cy);
            gc.setFill(Color.WHITE);
            gc.fillRoundRect(x + 12, y + 3, COMPONENT_WIDTH - 24, COMPONENT_HEIGHT - 6, 16, 16);
            gc.strokeRoundRect(x + 12, y + 3, COMPONENT_WIDTH - 24, COMPONENT_HEIGHT - 6, 16, 16);
            gc.setFont(Font.font("Arial", 16));
            gc.setFill(Color.web("#294e75"));
            drawCenteredText(gc, name, x + COMPONENT_WIDTH / 2.0, y + COMPONENT_HEIGHT / 2.0 + 6);
        }

        private void drawSeries(GraphicsContext gc, double x, double y) {
            LayoutInfo layout = measure();
            double centerY = y + layout.height / 2.0;
            double currentX = x;
            double previousRightX = -1;

            for (int i = 0; i < children.size(); i++) {
                CircuitElement child = children.get(i);
                LayoutInfo childLayout = child.measure();
                double childY = y + (layout.height - childLayout.height) / 2.0;

                if (i > 0) {
                    gc.strokeLine(previousRightX, centerY, currentX, centerY);
                }

                child.draw(gc, currentX, childY);
                previousRightX = currentX + childLayout.width;
                currentX += childLayout.width + SERIES_GAP;
            }
        }

        private void drawParallel(GraphicsContext gc, double x, double y) {
            LayoutInfo layout = measure();
            double leftBusX = x + PARALLEL_SIDE_MARGIN;
            double rightBusX = x + layout.width - PARALLEL_SIDE_MARGIN;
            double topY = y + PARALLEL_TOP_BOTTOM_PADDING;
            double currentY = topY;
            List<LayoutInfo> childLayouts = new ArrayList<>();
            List<Double> childYs = new ArrayList<>();

            for (CircuitElement child : children) {
                LayoutInfo childLayout = child.measure();
                childLayouts.add(childLayout);
                childYs.add(currentY);
                currentY += childLayout.height + PARALLEL_BRANCH_GAP;
            }
            double bottomY = currentY - PARALLEL_BRANCH_GAP;

            if (!children.isEmpty()) {
                double firstCenterY = childYs.get(0) + childLayouts.get(0).height / 2.0;
                double lastCenterY = childYs.get(childYs.size() - 1) + childLayouts.get(childLayouts.size() - 1).height / 2.0;
                gc.strokeLine(x, y + layout.height / 2.0, leftBusX, y + layout.height / 2.0);
                gc.strokeLine(rightBusX, y + layout.height / 2.0, x + layout.width, y + layout.height / 2.0);
                gc.strokeLine(leftBusX, firstCenterY, leftBusX, lastCenterY);
                gc.strokeLine(rightBusX, firstCenterY, rightBusX, lastCenterY);

                for (int i = 0; i < children.size(); i++) {
                    CircuitElement child = children.get(i);
                    LayoutInfo childLayout = childLayouts.get(i);
                    double childY = childYs.get(i);
                    double centerY = childY + childLayout.height / 2.0;
                    double childX = leftBusX + (rightBusX - leftBusX - childLayout.width) / 2.0;

                    gc.strokeLine(leftBusX, centerY, childX, centerY);
                    child.draw(gc, childX, childY);
                    gc.strokeLine(childX + childLayout.width, centerY, rightBusX, centerY);
                }
            }
        }

        private Complex impedance(double frequency) {
            double omega = 2.0 * Math.PI * frequency;
            return switch (type) {
                case R -> Complex.real(value);
                case L -> Complex.imaginary(omega * value);
                case C -> Complex.imaginary(-1.0 / (omega * value));
                case SER -> {
                    Complex sum = Complex.real(0);
                    for (CircuitElement child : children) {
                        sum = sum.add(child.impedance(frequency));
                    }
                    yield sum;
                }
                case PAR -> {
                    Complex admittance = Complex.real(0);
                    for (CircuitElement child : children) {
                        admittance = admittance.add(child.impedance(frequency).inverse());
                    }
                    yield admittance.inverse();
                }
            };
        }
    }

    private static void drawCenteredText(GraphicsContext gc, String text, double centerX, double baselineY) {
        double approxWidth = text.length() * 4.2;
        gc.fillText(text, centerX - approxWidth, baselineY);
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
                String valueText = readUntilClosingParenthesis();
                ElementType type = ElementType.valueOf(name);
                return CircuitElement.component(type, valueText, parseComponentValue(type, valueText));
            }

            if (!name.equals("SER") && !name.equals("PAR")) {
                throw new IllegalArgumentException("Nepoznat tip u šemi: " + name);
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
                throw new IllegalArgumentException("Očekivan je zarez ili zatvorena zagrada u šemi.");
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
                throw new IllegalArgumentException("Očekivan je naziv elementa u šemi.");
            }
            return text.substring(start, position);
        }

        private String readUntilClosingParenthesis() {
            int start = position;
            while (position < text.length() && text.charAt(position) != ')') {
                position++;
            }
            if (position >= text.length()) {
                throw new IllegalArgumentException("Nedostaje zatvorena zagrada u šemi.");
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

        private double parseComponentValue(ElementType type, String rawValue) {
            String normalized = rawValue.trim()
                    .replace(" ", "")
                    .replace("μ", "µ")
                    .replace("ohm", "Ω")
                    .replace("Ohm", "Ω");

            int index = 0;
            while (index < normalized.length()
                    && (Character.isDigit(normalized.charAt(index)) || normalized.charAt(index) == '.' || normalized.charAt(index) == ',')) {
                index++;
            }
            if (index == 0) {
                throw new IllegalArgumentException("Neispravna vrednost komponente: " + rawValue);
            }

            double number = Double.parseDouble(normalized.substring(0, index).replace(',', '.'));
            String unit = normalized.substring(index);

            return switch (type) {
                case R -> number * resistanceMultiplier(unit);
                case L -> number * inductanceMultiplier(unit);
                case C -> number * capacitanceMultiplier(unit);
                default -> throw new IllegalArgumentException("Vrednost može da ima samo R, L ili C komponenta.");
            };
        }

        private double resistanceMultiplier(String unit) {
            if (unit.equals("Ω") || unit.isEmpty()) return 1.0;
            if (unit.equalsIgnoreCase("kΩ")) return 1_000.0;
            if (unit.equalsIgnoreCase("MΩ")) return 1_000_000.0;
            throw new IllegalArgumentException("Nepoznata jedinica za otpornik: " + unit);
        }

        private double inductanceMultiplier(String unit) {
            if (unit.equalsIgnoreCase("H") || unit.isEmpty()) return 1.0;
            if (unit.equalsIgnoreCase("mH")) return 0.001;
            if (unit.equalsIgnoreCase("µH") || unit.equalsIgnoreCase("uH")) return 0.000001;
            throw new IllegalArgumentException("Nepoznata jedinica za kalem: " + unit);
        }

        private double capacitanceMultiplier(String unit) {
            if (unit.equalsIgnoreCase("F") || unit.isEmpty()) return 1.0;
            if (unit.equalsIgnoreCase("mF")) return 0.001;
            if (unit.equalsIgnoreCase("µF") || unit.equalsIgnoreCase("uF")) return 0.000001;
            if (unit.equalsIgnoreCase("nF")) return 0.000000001;
            if (unit.equalsIgnoreCase("pF")) return 0.000000000001;
            throw new IllegalArgumentException("Nepoznata jedinica za kondenzator: " + unit);
        }
    }

    private static class Complex {
        private final double re;
        private final double im;

        private Complex(double re, double im) {
            this.re = re;
            this.im = im;
        }

        private static Complex real(double value) {
            return new Complex(value, 0);
        }

        private static Complex imaginary(double value) {
            return new Complex(0, value);
        }

        private Complex add(Complex other) {
            return new Complex(this.re + other.re, this.im + other.im);
        }

        private Complex inverse() {
            double denominator = re * re + im * im;
            if (denominator == 0) {
                return new Complex(Double.POSITIVE_INFINITY, Double.POSITIVE_INFINITY);
            }
            return new Complex(re / denominator, -im / denominator);
        }

        private double abs() {
            return Math.hypot(re, im);
        }
    }
}
