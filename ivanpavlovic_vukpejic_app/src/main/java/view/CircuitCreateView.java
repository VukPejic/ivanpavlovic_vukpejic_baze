package view;

import controller.CircuitCreateController;
import javafx.collections.FXCollections;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ScrollPane;
import javafx.scene.control.TextField;
import javafx.scene.control.ComboBox;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.stage.Stage;
import model.Korisnik;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class CircuitCreateView {
    private final CircuitCreateController controller = new CircuitCreateController();
    private final TextField nameField = new TextField();
    private final TextField schemeField = new TextField(CircuitCreateController.INITIAL_SCHEME);
    private final TextField valueField = new TextField();
    private final ComboBox<String> componentComboBox = new ComboBox<>();
    private final ComboBox<String> unitComboBox = new ComboBox<>();
    private final Canvas canvas = new Canvas(980, 480);
    private final Label statusLabel = new Label("Šema uvek počinje sa SER(. Dugmadima dodaj veze i komponente, pa sačuvaj u bazu.");

    public void show(Stage stage, Korisnik korisnik) {
        Label titleLabel = new Label("Unos nove šeme električnog kola");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");
        Label userLabel = new Label("Prijavljeni korisnik: " + korisnik.getIme() + " " + korisnik.getPrezime() + " (" + korisnik.getUsername() + ")");

        nameField.setPromptText("Naziv nove šeme");
        nameField.setPrefWidth(300);

        schemeField.setEditable(false);
        schemeField.setPrefWidth(760);
        schemeField.setStyle("-fx-font-family: 'Consolas', 'Courier New', monospace; -fx-font-size: 16px;");

        valueField.setEditable(false);
        valueField.setPromptText("vrednost");
        valueField.setPrefWidth(160);
        valueField.setStyle("-fx-font-family: 'Consolas', 'Courier New', monospace; -fx-font-size: 16px;");

        componentComboBox.setItems(FXCollections.observableArrayList("R", "L", "C"));
        componentComboBox.getSelectionModel().select("R");
        componentComboBox.setPrefWidth(110);
        componentComboBox.setOnAction(event -> updateUnitsForSelectedComponent());

        unitComboBox.setPrefWidth(110);
        updateUnitsForSelectedComponent();

        GridPane form = new GridPane();
        form.setHgap(10);
        form.setVgap(10);
        form.setPadding(new Insets(10));
        form.add(new Label("Naziv:"), 0, 0);
        form.add(nameField, 1, 0);
        form.add(new Label("Šema:"), 0, 1);
        form.add(schemeField, 1, 1, 5, 1);
        form.add(new Label("Komponenta:"), 0, 2);
        form.add(componentComboBox, 1, 2);
        form.add(new Label("Vrednost:"), 2, 2);
        form.add(valueField, 3, 2);
        form.add(new Label("Jedinica:"), 4, 2);
        form.add(unitComboBox, 5, 2);

        HBox componentButtons = new HBox(10,
                button("Dodaj komponentu", event -> addSelectedComponent()),
                button("SER(", event -> addGroup("SER")),
                button("PAR(", event -> addGroup("PAR")),
                button(",", event -> appendComma()),
                button(")", event -> closeGroup())
        );
        componentButtons.setAlignment(Pos.CENTER_LEFT);

        GridPane digits = new GridPane();
        digits.setHgap(8);
        digits.setVgap(8);
        int[][] digitLayout = {{7, 8, 9}, {4, 5, 6}, {1, 2, 3}};
        for (int row = 0; row < digitLayout.length; row++) {
            for (int col = 0; col < digitLayout[row].length; col++) {
                int digit = digitLayout[row][col];
                digits.add(numberButton(String.valueOf(digit)), col, row);
            }
        }
        digits.add(numberButton("0"), 0, 3);
        digits.add(numberButton("."), 1, 3);
        digits.add(button("Obriši vrednost", event -> valueField.clear()), 2, 3);

        HBox editButtons = new HBox(10,
                button("Obriši poslednje", event -> backspaceScheme()),
                button("Reset šeme", event -> resetScheme()),
                button("Dovrši zagrade", event -> completeParentheses()),
                button("Sačuvaj šemu u bazu", event -> saveScheme()),
                button("Nazad na meni", event -> new MainMenuView().show(stage, korisnik))
        );
        editButtons.setAlignment(Pos.CENTER_RIGHT);

        statusLabel.setWrapText(true);
        statusLabel.setStyle("-fx-font-size: 14px;");

        VBox top = new VBox(10, titleLabel, userLabel, form, componentButtons, digits, editButtons, statusLabel);
        top.setPadding(new Insets(15));

        ScrollPane scrollPane = new ScrollPane(canvas);
        scrollPane.setPannable(true);
        scrollPane.setStyle("-fx-background: white; -fx-background-color: white;");

        BorderPane root = new BorderPane();
        root.setTop(top);
        root.setCenter(scrollPane);
        BorderPane.setMargin(scrollPane, new Insets(0, 15, 15, 15));

        stage.setTitle("Unos nove šeme kola");
        stage.setScene(new Scene(root, 1280, 860));
        stage.show();
        redraw();
    }

    private Button button(String text, javafx.event.EventHandler<javafx.event.ActionEvent> action) {
        Button button = new Button(text);
        button.setMinWidth(70);
        button.setOnAction(action);
        return button;
    }

    private Button numberButton(String text) {
        Button button = button(text, event -> appendValue(text));
        button.setMinWidth(70);
        button.setMinHeight(38);
        return button;
    }

    private void appendValue(String value) {
        if (".".equals(value) && valueField.getText().contains(".")) {
            return;
        }
        valueField.setText(valueField.getText() + value);
    }

    private void addSelectedComponent() {
        CircuitCreateController.OperationResult result = controller.addComponent(
                schemeField.getText(),
                componentComboBox.getValue(),
                valueField.getText(),
                unitComboBox.getValue()
        );
        schemeField.setText(result.getScheme());
        statusLabel.setText(result.getMessage());
        if (result.isSuccess()) {
            valueField.clear();
            redraw();
        }
    }

    private void updateUnitsForSelectedComponent() {
        String selectedComponent = componentComboBox.getValue();
        if ("L".equals(selectedComponent)) {
            unitComboBox.setItems(FXCollections.observableArrayList("H", "mH", "µH"));
            unitComboBox.getSelectionModel().select("H");
        } else if ("C".equals(selectedComponent)) {
            unitComboBox.setItems(FXCollections.observableArrayList("F", "mF", "µF", "nF", "pF"));
            unitComboBox.getSelectionModel().select("µF");
        } else {
            unitComboBox.setItems(FXCollections.observableArrayList("Ω", "kΩ", "MΩ"));
            unitComboBox.getSelectionModel().select("Ω");
        }
    }

    private void addGroup(String groupType) {
        CircuitCreateController.OperationResult result = controller.addGroup(schemeField.getText(), groupType);
        schemeField.setText(result.getScheme());
        statusLabel.setText(result.getMessage());
        redraw();
    }

    private void appendComma() {
        CircuitCreateController.OperationResult result = controller.appendComma(schemeField.getText());
        schemeField.setText(result.getScheme());
        statusLabel.setText(result.getMessage());
        if (result.isSuccess()) {
            redraw();
        }
    }

    private void closeGroup() {
        CircuitCreateController.OperationResult result = controller.closeGroup(schemeField.getText());
        schemeField.setText(result.getScheme());
        statusLabel.setText(result.getMessage());
        if (result.isSuccess()) {
            redraw();
        }
    }

    private void backspaceScheme() {
        schemeField.setText(controller.backspaceScheme(schemeField.getText()));
        redraw();
    }

    private void resetScheme() {
        schemeField.setText(controller.resetScheme());
        valueField.clear();
        statusLabel.setText("Šema je resetovana. Svaka nova šema počinje sa SER(.");
        redraw();
    }

    private void completeParentheses() {
        CircuitCreateController.OperationResult result = controller.completeParentheses(schemeField.getText());
        schemeField.setText(result.getScheme());
        statusLabel.setText(result.getMessage());
        if (result.isSuccess()) {
            redraw();
        }
    }

    private String completeScheme(String scheme) {
        return controller.completeScheme(scheme);
    }

    private void saveScheme() {
        CircuitCreateController.SaveResult result = controller.saveScheme(nameField.getText(), schemeField.getText());
        schemeField.setText(result.getScheme());
        statusLabel.setText(result.getMessage());
        redraw();
    }

    private void redraw() {
        GraphicsContext gc = canvas.getGraphicsContext2D();
        gc.setFill(Color.WHITE);
        gc.fillRect(0, 0, canvas.getWidth(), canvas.getHeight());
        gc.setStroke(Color.web("#294e75"));
        gc.setFill(Color.web("#294e75"));
        gc.setLineWidth(3);
        gc.setFont(Font.font("Arial", 20));
        gc.fillText("Nova šema kola", 40, 35);

        String scheme = schemeField.getText();
        if (scheme.equals(CircuitCreateController.INITIAL_SCHEME) || scheme.endsWith("(") || scheme.endsWith(",")) {
            gc.setFont(Font.font("Arial", 16));
            gc.fillText("Dodaj komponente preko dugmadi. Šema se gradi u readonly polju iznad.", 40, 75);
            return;
        }

        try {
            String previewScheme = completeScheme(scheme);
            CircuitElement root = new SchemeParser(previewScheme).parse();
            ComponentNamer namer = new ComponentNamer();
            root.assignNames(namer);
            drawCircuit(root);
        } catch (RuntimeException exception) {
            gc.setFont(Font.font("Arial", 16));
            gc.fillText("Trenutna šema još nije spremna za crtanje.", 40, 75);
        }
    }

    private void drawCircuit(CircuitElement rootElement) {
        LayoutInfo layout = rootElement.measure();
        double margin = 50;
        double leftTerminalSpace = 55;
        double rightTerminalSpace = 55;
        double topSpace = 70;
        double width = Math.max(980, margin * 2 + leftTerminalSpace + layout.width + rightTerminalSpace);
        double height = Math.max(480, topSpace + margin + layout.height + margin);
        canvas.setWidth(width);
        canvas.setHeight(height);

        GraphicsContext gc = canvas.getGraphicsContext2D();
        gc.setFill(Color.WHITE);
        gc.fillRect(0, 0, width, height);
        gc.setStroke(Color.web("#294e75"));
        gc.setFill(Color.web("#294e75"));
        gc.setLineWidth(3);
        gc.setFont(Font.font("Arial", 20));
        gc.fillText("Nova šema kola", 40, 35);

        double startX = margin + leftTerminalSpace;
        double startY = topSpace + margin;
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

    private void drawTerminal(GraphicsContext gc, double x, double y) {
        gc.setFill(Color.WHITE);
        gc.fillOval(x - 12, y - 12, 24, 24);
        gc.setStroke(Color.web("#294e75"));
        gc.strokeOval(x - 12, y - 12, 24, 24);
    }

    private enum ElementType { R, L, C, SER, PAR }

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
        private final List<CircuitElement> children;
        private String displayName;

        private CircuitElement(ElementType type, String rawLabel, List<CircuitElement> children) {
            this.type = type;
            this.rawLabel = rawLabel;
            this.children = children;
        }

        private static CircuitElement component(ElementType type, String label) {
            return new CircuitElement(type, label, List.of());
        }

        private static CircuitElement group(ElementType type, List<CircuitElement> children) {
            return new CircuitElement(type, type.name(), children);
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

        private LayoutInfo measure() {
            if (type == ElementType.R || type == ElementType.L || type == ElementType.C) {
                return new LayoutInfo(COMPONENT_WIDTH, COMPONENT_HEIGHT, COMPONENT_HEIGHT / 2.0, COMPONENT_HEIGHT / 2.0);
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
                case R, L, C -> drawComponent(gc, x, y);
                case SER -> drawSeries(gc, x, y);
                case PAR -> drawParallel(gc, x, y);
            }
        }

        private void drawComponent(GraphicsContext gc, double x, double y) {
            double cy = y + COMPONENT_HEIGHT / 2.0;
            gc.strokeLine(x, cy, x + 12, cy);
            gc.strokeLine(x + COMPONENT_WIDTH - 12, cy, x + COMPONENT_WIDTH, cy);
            gc.setFill(Color.WHITE);
            gc.fillRoundRect(x + 12, y + 3, COMPONENT_WIDTH - 24, COMPONENT_HEIGHT - 6, 16, 16);
            gc.strokeRoundRect(x + 12, y + 3, COMPONENT_WIDTH - 24, COMPONENT_HEIGHT - 6, 16, 16);
            gc.setFont(Font.font("Arial", 16));
            gc.setFill(Color.web("#294e75"));
            gc.fillText(displayName == null ? type.name() : displayName, x + 43, y + COMPONENT_HEIGHT / 2.0 + 6);
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
            double currentY = y + PARALLEL_TOP_BOTTOM_PADDING;
            List<LayoutInfo> childLayouts = new ArrayList<>();
            List<Double> childYs = new ArrayList<>();

            for (CircuitElement child : children) {
                LayoutInfo childLayout = child.measure();
                childLayouts.add(childLayout);
                childYs.add(currentY);
                currentY += childLayout.height + PARALLEL_BRANCH_GAP;
            }

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
                return CircuitElement.component(ElementType.valueOf(name), valueText);
            }

            if (!name.equals("SER") && !name.equals("PAR")) {
                throw new IllegalArgumentException("Nepoznat tip u šemi: " + name);
            }

            List<CircuitElement> children = new ArrayList<>();
            while (true) {
                skipWhitespace();
                if (peek() == ')') {
                    position++;
                    break;
                }
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

            if (children.isEmpty()) {
                throw new IllegalArgumentException("Veza " + name + " mora imati bar jednu komponentu.");
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
            if (value.isBlank()) {
                throw new IllegalArgumentException("Komponenta nema vrednost.");
            }
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
