# OOP JavaFX projekat

## Pokretanje

1. U phpMyAdmin importuj fajl `ivanpavlovic_vukpejic_baza.sql`.
2. Proveri `src/main/resources/db.properties` i po potrebi promeni user/password za MySQL.
3. Pokreni aplikaciju:

```bash
mvn clean javafx:run
```

## Login i registracija

- Prijava više ne koristi email, nego `username`.
- Prijava koristi MySQL funkciju `prijavi_korisnika(username, lozinka)` iz baze.
- Registracija koristi MySQL proceduru `registruj_korisnika(ime, prezime, kvalifikacije, username, lozinka)` iz baze.
- Registraciona forma traži: ime, prezime, kvalifikacije, username i lozinku.
- Lozinka se ne hash-uje u Javi za registraciju, već procedura u bazi čuva `MD5(_lozinka)`.

## Meni posle logovanja

Posle uspešne prijave korisnik bira koju formu želi da otvori:

1. Ispitivanje električnog kola
2. Unos nove šeme kola
3. Pregled eksperimenata

## Unos nove šeme

Forma za unos šeme radi kao kalkulator. String šeme se gradi u readonly polju, šema automatski počinje sa `SER(`, a korisnik dodaje komponente i veze preko dugmadi.

## Pregled eksperimenata

Pregled eksperimenata koristi dva view-a iz baze:

- `planirani_eksperimenti`
- `izradjeni_eksperimenti`

## MVC napomena

U ovoj verziji je dodat `controller` paket i prebačen je glavni programski deo iz `view` klasa:

- `AuthController` — prijava i registracija
- `MainMenuController` — navigacija iz glavnog menija
- `ExperimentsController` — učitavanje planiranih i izvršenih eksperimenata
- `CircuitTestController` — učitavanje električnih kola i upis ispitivanja
- `CircuitCreateController` — logika za kalkulator šeme i čuvanje nove šeme

`view` klase sada uglavnom prave grafički prikaz, kontrole i pozivaju controller metode.

## Izmene u ovoj verziji

- Dodata forma **Brisanje sesije**.
- Brisanje koristi proceduru iz baze: `izbrisi_sesiju(istrazivac_id, sesija_id, OUT izbrisani)`.
- Ako prijavljeni istraživač ne učestvuje u eksperimentu za izabranu sesiju, procedura vraća `0` i sesija se ne briše.
- Forma za ispitivanje kola više ne prikazuje napon kao rezultat.
- Ispitivanje kola sada upisuje `impedansa`, `snaga` i `struja` u tabelu `ispitivanje`.
- Prikaz rezultata automatski koristi osnovnu, mili ili mikro jedinicu, npr. `A`, `mA`, `µA`.
