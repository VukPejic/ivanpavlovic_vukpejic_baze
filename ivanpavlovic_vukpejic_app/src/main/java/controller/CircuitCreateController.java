package controller;

import model.Database;
import model.ElektricnoKolo;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class CircuitCreateController {
    public static final String INITIAL_SCHEME = "SER(";

    public OperationResult addComponent(String currentScheme, String type, String value, String unit) {
        if (isBlank(value)) {
            return OperationResult.fail(currentScheme, "Prvo ukucaj vrednost komponente dugmadima 0-9.");
        }
        if (value.endsWith(".")) {
            return OperationResult.fail(currentScheme, "Vrednost komponente ne sme da se završava tačkom.");
        }
        try {
            double numericValue = Double.parseDouble(value);
            if (numericValue <= 0) {
                return OperationResult.fail(currentScheme, "Vrednost komponente mora biti pozitivan broj.");
            }
        } catch (NumberFormatException exception) {
            return OperationResult.fail(currentScheme, "Vrednost komponente nije ispravan broj.");
        }
        if (!unitMatchesType(type, unit)) {
            return OperationResult.fail(currentScheme, "Izabrana jedinica ne odgovara komponenti " + type + ".");
        }
        return OperationResult.success(appendToken(currentScheme, type + "(" + value + unit + ")"), "Dodata komponenta " + type + ".");
    }

    public OperationResult addGroup(String currentScheme, String groupType) {
        return OperationResult.success(appendToken(currentScheme, groupType + "("), "Započeta je " + ("SER".equals(groupType) ? "redna" : "paralelna") + " veza.");
    }

    public OperationResult appendComma(String scheme) {
        if (openParenthesesCount(scheme) == 0) {
            return OperationResult.fail(scheme, "Šema je već zatvorena. Dodaj komponentu ili obriši poslednju zagradu.");
        }
        if (scheme.endsWith("(") || scheme.endsWith(",")) {
            return OperationResult.fail(scheme, "Zarez ne može odmah posle otvorene zagrade ili drugog zareza.");
        }
        return OperationResult.success(scheme + ",", "Dodat je zarez.");
    }

    public OperationResult closeGroup(String scheme) {
        if (scheme.endsWith("(") || scheme.endsWith(",")) {
            return OperationResult.fail(scheme, "Ne možeš zatvoriti praznu vezu ili vezu koja se završava zarezom.");
        }
        if (openParenthesesCount(scheme) <= 0) {
            return OperationResult.success(scheme, "Nema otvorenih zagrada za zatvaranje.");
        }
        return OperationResult.success(scheme + ")", "Zatvorena je veza.");
    }

    public String backspaceScheme(String scheme) {
        if (scheme == null || scheme.length() <= INITIAL_SCHEME.length()) {
            return INITIAL_SCHEME;
        }
        return scheme.substring(0, scheme.length() - 1);
    }

    public String resetScheme() {
        return INITIAL_SCHEME;
    }

    public OperationResult completeParentheses(String scheme) {
        if (scheme.endsWith("(") || scheme.endsWith(",")) {
            return OperationResult.fail(scheme, "Pre dovršavanja zagrada dodaj komponentu ili obriši višak.");
        }
        return OperationResult.success(completeScheme(scheme), "Zagrade su dovršene.");
    }

    public SaveResult saveScheme(String name, String rawScheme) {
        if (isBlank(name)) {
            return SaveResult.fail(rawScheme, "Unesi naziv nove šeme.");
        }
        if (rawScheme.equals(INITIAL_SCHEME) || rawScheme.endsWith("(") || rawScheme.endsWith(",")) {
            return SaveResult.fail(rawScheme, "Šema nije završena. Dodaj komponentu i dovrši zagrade.");
        }
        String scheme = completeScheme(rawScheme);
        try {
            new SchemeParser(scheme).parse();
            ElektricnoKolo saved = Database.getInstance().sacuvajElektricnoKolo(name.trim(), scheme);
            return SaveResult.success(scheme, "Nova šema je upisana u bazu: " + saved.getNaziv());
        } catch (SQLException exception) {
            exception.printStackTrace();
            return SaveResult.fail(rawScheme, "Greška pri upisu nove šeme u bazu: " + exception.getMessage());
        } catch (RuntimeException exception) {
            return SaveResult.fail(rawScheme, "Šema nije ispravna: " + exception.getMessage());
        }
    }

    public String completeScheme(String scheme) {
        int open = openParenthesesCount(scheme);
        StringBuilder builder = new StringBuilder(scheme);
        for (int i = 0; i < open; i++) {
            builder.append(')');
        }
        return builder.toString();
    }

    private String appendToken(String scheme, String token) {
        if (openParenthesesCount(scheme) == 0 && scheme.startsWith(INITIAL_SCHEME) && scheme.endsWith(")")) {
            scheme = scheme.substring(0, scheme.length() - 1);
        }
        if (scheme.endsWith(")")) {
            scheme += ",";
        }
        return scheme + token;
    }

    public int openParenthesesCount(String scheme) {
        int count = 0;
        for (int i = 0; i < scheme.length(); i++) {
            char ch = scheme.charAt(i);
            if (ch == '(') count++;
            if (ch == ')') count--;
        }
        return count;
    }

    private boolean unitMatchesType(String type, String unit) {
        if ("R".equals(type)) return unit.equals("Ω") || unit.equals("kΩ") || unit.equals("MΩ");
        if ("L".equals(type)) return unit.equals("H") || unit.equals("mH") || unit.equals("µH");
        return unit.equals("F") || unit.equals("mF") || unit.equals("µF") || unit.equals("nF") || unit.equals("pF");
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public static class OperationResult {
        private final boolean success;
        private final String scheme;
        private final String message;
        private OperationResult(boolean success, String scheme, String message) {
            this.success = success;
            this.scheme = scheme;
            this.message = message;
        }
        public static OperationResult success(String scheme, String message) { return new OperationResult(true, scheme, message); }
        public static OperationResult fail(String scheme, String message) { return new OperationResult(false, scheme, message); }
        public boolean isSuccess() { return success; }
        public String getScheme() { return scheme; }
        public String getMessage() { return message; }
    }

    public static class SaveResult extends OperationResult {
        private SaveResult(boolean success, String scheme, String message) { super(success, scheme, message); }
        public static SaveResult success(String scheme, String message) { return new SaveResult(true, scheme, message); }
        public static SaveResult fail(String scheme, String message) { return new SaveResult(false, scheme, message); }
    }

    private enum ElementType { R, L, C, SER, PAR }

    private static class CircuitElement {
        private final ElementType type;
        private final String rawLabel;
        private final List<CircuitElement> children;
        private CircuitElement(ElementType type, String rawLabel, List<CircuitElement> children) {
            this.type = type;
            this.rawLabel = rawLabel;
            this.children = children;
        }
        private static CircuitElement component(ElementType type, String label) { return new CircuitElement(type, label, List.of()); }
        private static CircuitElement group(ElementType type, List<CircuitElement> children) { return new CircuitElement(type, type.name(), children); }
    }

    private static class SchemeParser {
        private final String text;
        private int position = 0;
        private SchemeParser(String text) { this.text = text == null ? "" : text.trim(); }
        private CircuitElement parse() {
            CircuitElement element = parseElement();
            skipWhitespace();
            if (position != text.length()) throw new IllegalArgumentException("Neočekivan tekst u šemi: " + text.substring(position));
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
            if (!name.equals("SER") && !name.equals("PAR")) throw new IllegalArgumentException("Nepoznat tip u šemi: " + name);
            List<CircuitElement> children = new ArrayList<>();
            while (true) {
                skipWhitespace();
                if (peek() == ')') { position++; break; }
                children.add(parseElement());
                skipWhitespace();
                if (peek() == ',') { position++; continue; }
                if (peek() == ')') { position++; break; }
                throw new IllegalArgumentException("Očekivan je zarez ili zatvorena zagrada u šemi.");
            }
            if (children.isEmpty()) throw new IllegalArgumentException("Veza " + name + " mora imati bar jednu komponentu.");
            return CircuitElement.group(ElementType.valueOf(name), children);
        }
        private String readName() {
            skipWhitespace();
            int start = position;
            while (position < text.length() && Character.isLetter(text.charAt(position))) position++;
            if (start == position) throw new IllegalArgumentException("Očekivan je naziv elementa u šemi.");
            return text.substring(start, position);
        }
        private String readUntilClosingParenthesis() {
            int start = position;
            while (position < text.length() && text.charAt(position) != ')') position++;
            if (position >= text.length()) throw new IllegalArgumentException("Nedostaje zatvorena zagrada u šemi.");
            String value = text.substring(start, position).trim();
            if (value.isBlank()) throw new IllegalArgumentException("Komponenta nema vrednost.");
            position++;
            return value;
        }
        private void expect(char expected) {
            skipWhitespace();
            if (position >= text.length() || text.charAt(position) != expected) throw new IllegalArgumentException("Očekivan znak: " + expected);
            position++;
        }
        private char peek() {
            skipWhitespace();
            if (position >= text.length()) return '\0';
            return text.charAt(position);
        }
        private void skipWhitespace() {
            while (position < text.length() && Character.isWhitespace(text.charAt(position))) position++;
        }
    }
}
