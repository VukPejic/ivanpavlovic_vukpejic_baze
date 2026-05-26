# OOP JavaFX aplikacija za laboratorijske eksperimente

Ova aplikacija je JavaFX desktop program namenjen za rad sa bazom laboratorijskih eksperimenata. Koristi MySQL bazu `ivanpavlovic_vukpejic_baza` i omogućava korisniku da se prijavi, registruje, pregleda eksperimente, vidi opremu povezanu sa eksperimentom, promeni status eksperimenta i obriše sesiju kada ima pravo na to.

Aplikacija je organizovana po MVC principu:

```text
src/main/java
  app          - pokretanje aplikacije
  controller   - obrada događaja i povezivanje view/model sloja
  database     - čitanje konfiguracije i otvaranje konekcije
  model        - klase koje predstavljaju podatke i rade čitanje/upis iz baze
  view         - JavaFX forme i grafički prikaz
```

## Glavne mogućnosti

### Prijava korisnika

Korisnik se prijavljuje pomoću korisničkog imena i lozinke. Provera prijave se radi preko funkcije iz baze:

```sql
prijavi_korisnika(username, lozinka)
```

Aplikacija ne proverava lozinku ručno u Java kodu, već koristi logiku definisanu u bazi.

### Registracija korisnika

Registracija se radi preko procedure iz baze:

```sql
registruj_korisnika(ime, prezime, kvalifikacije, username, lozinka)
```

Forma za registraciju traži:

```text
ime
prezime
kvalifikacije
username
lozinku
```

Procedura u bazi dodaje novog istraživača i korisnika.

### Pregled eksperimenata

Forma za pregled eksperimenata prikazuje dve tabele:

```text
Planirani eksperimenti
Izvršeni eksperimenti
```

Za ove dve tabele koriste se view-ovi iz baze:

```sql
planirani_eksperimenti
izradjeni_eksperimenti
```

Kada korisnik selektuje eksperiment, aplikacija prikazuje dodatne podatke povezane sa tim eksperimentom.

### Prikaz električnih kola

Za selektovani eksperiment aplikacija prikazuje sva električna kola koja su povezana sa njim. Podaci se čitaju iz view-a:

```sql
eksperiment_sva_kola
```

Kola se crtaju grafički u JavaFX `Canvas` komponenti. Ako eksperiment ima više kola, sva kola se prikazuju u desnom delu forme, a korisnik može da skroluje kroz prikaz.

### Prikaz senzora

Za selektovani eksperiment aplikacija prikazuje sve povezane senzore. Podaci se čitaju iz view-a:

```sql
eksperiment_svi_senzori
```

Tabela prikazuje ID senzora, naziv, opis i izvor podatka.

### Prikaz prototipova

Za selektovani eksperiment aplikacija prikazuje sve povezane prototipove. Podaci se čitaju iz view-a:

```sql
eksperiment_svi_prototipi
```

Tabela prikazuje ID prototipa, naziv, opis i izvor podatka.

### Promena statusa eksperimenta

Korisnik može da izabere eksperiment i promeni njegov status. Podržani statusi su:

```text
planiran
u toku
pauziran
zavrsen
```

Promena statusa se upisuje direktno u tabelu `eksperiment`.

### Brisanje sesije

Aplikacija ima formu za brisanje sesije. Brisanje se radi preko procedure iz baze:

```sql
izbrisi_sesiju(istrazivac_id, sesija_id, OUT izbrisani)
```

Sesiju može da obriše samo istraživač koji učestvuje u eksperimentu vezanom za tu sesiju. Ako korisnik nema pravo na brisanje, procedura vraća rezultat kroz OUT parametar i aplikacija prikazuje odgovarajuću poruku.

## Podešavanje baze

Konekcija ka bazi se podešava u fajlu:

```text
src/main/resources/database.cfg
```

Primer podešavanja:

```text
url=jdbc:mysql://localhost:3306/ivanpavlovic_vukpejic_baza?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
user=root
password=
```

Pre pokretanja aplikacije potrebno je u phpMyAdmin-u importovati fajl:

```text
ivanpavlovic_vukpejic_baza.sql
```

## Pokretanje aplikacije

Preporučeno pokretanje je preko Maven-a:

```bash
mvn clean javafx:run
```

Glavna klasa za pokretanje je:

```text
app.Launcher
```

U IntelliJ IDEA ne treba pokretati pojedinačne `.java` fajlove. Projekat treba pokrenuti preko Maven konfiguracije ili preko komande `mvn clean javafx:run`.

## Preporučena podešavanja u IntelliJ IDEA

U IntelliJ-u treba podesiti JDK za projekat i modul:

```text
File -> Project Structure -> Project SDK
File -> Project Structure -> Modules -> Module SDK
```

Preporučeno je koristiti JDK 21. Nakon toga treba osvežiti Maven projekat:

```text
Desni klik na pom.xml -> Maven -> Reload project
```

## Struktura aplikacije

```text
app
  App.java
  Launcher.java
  MainKlasa.java

controller
  AuthController.java
  MainMenuController.java
  ExperimentsController.java
  ExperimentStatusController.java
  SessionDeleteController.java

database
  DatabaseConfig.java
  ConnectionFactory.java

model
  Korisnik.java
  Eksperiment.java
  Sesija.java
  ElektricnoKolo.java
  Senzor.java
  Prototip.java

view
  LoginView.java
  MainMenuView.java
  ExperimentsView.java
  ExperimentStatusView.java
  SessionDeleteView.java
  Style.java
```

## Namena aplikacije

Aplikacija služi kao desktop sistem za upravljanje laboratorijskim eksperimentima. Omogućava istraživačima da rade sa eksperimentima, prate njihov status, vide opremu koja se koristi u ispitivanju i merenju, kao i da upravljaju sesijama u skladu sa pravilima definisanim u bazi.
