package view;

import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.ButtonBase;
import javafx.scene.control.Label;
import javafx.scene.control.TableView;
import javafx.scene.control.TextInputControl;
import javafx.scene.layout.Region;

/**
 * Jednostavno stilizovanje bez CSS fajla.
 * Sve je podešeno direktno iz Java koda, da projekat nema dodatni style.css.
 */
public final class Style {
    private static final String PRIMARY = "#294e75";
    private static final String BACKGROUND = "#eef3f8";
    private static final String CARD = "#ffffff";
    private static final String BORDER = "#c8d5e3";

    private Style() {
    }

    public static void apply(Scene scene) {
        if (scene == null || scene.getRoot() == null) {
            return;
        }

        scene.getRoot().setStyle("-fx-background-color: " + BACKGROUND + "; -fx-font-family: 'Segoe UI', Arial, sans-serif;");
        applyToNode(scene.getRoot());
    }

    private static void applyToNode(Node node) {
        if (node instanceof Label label) {
            styleLabel(label);
        }

        if (node instanceof ButtonBase button) {
            styleButton(button);
        }

        if (node instanceof TextInputControl input) {
            styleInput(input);
        }

        if (node instanceof TableView<?> table) {
            styleTable(table);
        }

        if (node instanceof Region region && !(node instanceof ButtonBase) && !(node instanceof TextInputControl) && !(node instanceof TableView<?>)) {
            String current = region.getStyle() == null ? "" : region.getStyle();
            if (!current.contains("-fx-background-color")) {
                region.setStyle(current + "; -fx-background-color: transparent;");
            }
        }

        if (node instanceof Parent parent) {
            for (Node child : parent.getChildrenUnmodifiable()) {
                applyToNode(child);
            }
        }
    }

    private static void styleLabel(Label label) {
        String current = label.getStyle() == null ? "" : label.getStyle();
        if (current.contains("-fx-text-fill")) {
            return;
        }
        label.setStyle(current + "; -fx-text-fill: " + PRIMARY + ";");
    }

    private static void styleButton(ButtonBase button) {
        button.setStyle("-fx-background-color: " + PRIMARY + ";"
                + " -fx-text-fill: white;"
                + " -fx-font-weight: bold;"
                + " -fx-background-radius: 8;"
                + " -fx-padding: 8 16 8 16;"
                + " -fx-cursor: hand;");
    }

    private static void styleInput(TextInputControl input) {
        input.setStyle("-fx-background-color: " + CARD + ";"
                + " -fx-border-color: " + BORDER + ";"
                + " -fx-border-radius: 7;"
                + " -fx-background-radius: 7;"
                + " -fx-padding: 7;");
    }

    private static void styleTable(TableView<?> table) {
        table.setStyle("-fx-background-color: " + CARD + ";"
                + " -fx-border-color: " + BORDER + ";"
                + " -fx-border-radius: 8;"
                + " -fx-background-radius: 8;");
    }
}
