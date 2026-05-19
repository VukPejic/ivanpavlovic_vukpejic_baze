package view;

import controller.AuthController;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class LoginView {
    private final AuthController authController = new AuthController();
    private TextField usernameField;
    private PasswordField passwordField;
    private Label statusLabel;

    public void show(Stage stage) {
        Label titleLabel = new Label("Prijava korisnika");
        titleLabel.setStyle("-fx-font-size: 22px; -fx-font-weight: bold;");

        usernameField = new TextField();
        usernameField.setPromptText("Unesi username");
        usernameField.setPrefWidth(300);

        passwordField = new PasswordField();
        passwordField.setPromptText("Unesi lozinku");
        passwordField.setPrefWidth(300);

        Button loginButton = new Button("Prijavi se");
        loginButton.setDefaultButton(true);
        loginButton.setMaxWidth(Double.MAX_VALUE);
        loginButton.setOnAction(event -> login(stage));

        Button registerButton = new Button("Registruj se");
        registerButton.setMaxWidth(Double.MAX_VALUE);
        registerButton.setOnAction(event -> showRegister(stage));

        HBox buttons = new HBox(10, loginButton, registerButton);
        buttons.setAlignment(Pos.CENTER_RIGHT);

        statusLabel = errorLabel();

        GridPane form = new GridPane();
        form.setHgap(10);
        form.setVgap(12);
        form.setAlignment(Pos.CENTER);
        form.add(new Label("Username:"), 0, 0);
        form.add(usernameField, 1, 0);
        form.add(new Label("Lozinka:"), 0, 1);
        form.add(passwordField, 1, 1);
        form.add(buttons, 1, 2);

        VBox root = new VBox(18, titleLabel, form, statusLabel);
        root.setPadding(new Insets(30));
        root.setAlignment(Pos.CENTER);

        stage.setTitle("Login");
        stage.setScene(new Scene(root, 540, 340));
        stage.show();
    }

    private void login(Stage stage) {
        AuthController.LoginResult result = authController.prijavi(getText(usernameField), getText(passwordField));
        if (result.isSuccess()) {
            new MainMenuView().show(stage, result.getKorisnik());
        } else {
            statusLabel.setText(result.getMessage());
            passwordField.clear();
        }
    }

    private void showRegister(Stage stage) {
        Label titleLabel = new Label("Registracija korisnika");
        titleLabel.setStyle("-fx-font-size: 22px; -fx-font-weight: bold;");

        TextField imeField = textField("Unesi ime");
        TextField prezimeField = textField("Unesi prezime");
        TextField kvalifikacijeField = textField("Unesi kvalifikacije");
        TextField usernameRegisterField = textField("Unesi username");

        PasswordField lozinkaRegisterField = new PasswordField();
        lozinkaRegisterField.setPromptText("Unesi lozinku");
        lozinkaRegisterField.setPrefWidth(320);

        Label registerStatusLabel = errorLabel();

        Button saveButton = new Button("Sačuvaj registraciju");
        saveButton.setDefaultButton(true);
        saveButton.setOnAction(event -> register(stage, imeField, prezimeField, kvalifikacijeField, usernameRegisterField, lozinkaRegisterField, registerStatusLabel));

        Button backButton = new Button("Nazad na login");
        backButton.setOnAction(event -> show(stage));

        HBox buttons = new HBox(10, saveButton, backButton);
        buttons.setAlignment(Pos.CENTER_RIGHT);

        GridPane form = new GridPane();
        form.setHgap(10);
        form.setVgap(12);
        form.setAlignment(Pos.CENTER);
        form.add(new Label("Ime:"), 0, 0);
        form.add(imeField, 1, 0);
        form.add(new Label("Prezime:"), 0, 1);
        form.add(prezimeField, 1, 1);
        form.add(new Label("Kvalifikacije:"), 0, 2);
        form.add(kvalifikacijeField, 1, 2);
        form.add(new Label("Username:"), 0, 3);
        form.add(usernameRegisterField, 1, 3);
        form.add(new Label("Lozinka:"), 0, 4);
        form.add(lozinkaRegisterField, 1, 4);
        form.add(buttons, 1, 5);

        VBox root = new VBox(18, titleLabel, form, registerStatusLabel);
        root.setPadding(new Insets(30));
        root.setAlignment(Pos.CENTER);

        stage.setTitle("Registracija");
        stage.setScene(new Scene(root, 620, 500));
        stage.show();
    }

    private void register(Stage stage,
                          TextField imeField,
                          TextField prezimeField,
                          TextField kvalifikacijeField,
                          TextField usernameRegisterField,
                          PasswordField lozinkaRegisterField,
                          Label registerStatusLabel) {
        AuthController.LoginResult result = authController.registruj(
                getText(imeField),
                getText(prezimeField),
                getText(kvalifikacijeField),
                getText(usernameRegisterField),
                getText(lozinkaRegisterField)
        );

        if (result.isSuccess()) {
            new MainMenuView().show(stage, result.getKorisnik());
        } else {
            registerStatusLabel.setText(result.getMessage());
        }
    }

    private TextField textField(String prompt) {
        TextField field = new TextField();
        field.setPromptText(prompt);
        field.setPrefWidth(320);
        return field;
    }

    private Label errorLabel() {
        Label label = new Label();
        label.setWrapText(true);
        label.setStyle("-fx-text-fill: #b00020;");
        return label;
    }

    private String getText(TextField textField) {
        return textField.getText() == null ? "" : textField.getText();
    }
}
