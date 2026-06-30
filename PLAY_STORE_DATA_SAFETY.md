# Google Play – Datasikkerhed (snydeark)

Brug dette til at udfylde **Play Console → App-indhold → Datasikkerhed**.
Svarene afspejler, hvad appen faktisk gør (pr. 30. juni 2026).

## Indsamler eller deler din app brugerdata? → JA

### Placering
- **Type:** Præcis placering + Omtrentlig placering
- **Indsamles:** Ja
- **Deles:** Ja (koordinater sendes til OSRM-rutetjeneste til gåtidsberegning)
- **Formål:** App-funktionalitet
- **Påkrævet eller valgfrit:** Påkrævet for kernefunktion
- **Krypteret under overførsel:** Ja
- **Brugeren kan anmode om sletning:** Ja (data ligger lokalt; afinstallation/sletning i app fjerner dem)

### Enheds- eller andre id'er (Advertising ID)
- **Indsamles:** Ja (via Google AdMob)
- **Deles:** Ja (Google)
- **Formål:** Reklamer / marketing, Analyser
- **Påkrævet eller valgfrit:** Påkrævet i gratis version

### App-aktivitet / app-interaktioner
- Kun hvis du sender app-interaktionsdata til analyse. AdMob indsamler
  reklamemålinger — angiv under "Reklamer".

## Data der behandles, men IKKE forlader enheden (skal som regel IKKE angives som "indsamlet")
- **Bluetooth-forbindelsesstatus** – kun lokalt
- **Fysisk aktivitet / bevægelse** – kun lokalt
- **Parkeringshistorik / ignorerede placeringer** – kun lokalt

> Google's definition: data, der kun behandles på enheden og ikke sendes ud,
> tæller ikke som "indsamlet". Bluetooth, aktivitet og lokal historik forbliver
> på enheden og angives derfor ikke som indsamlet — bortset fra placering, der
> deles med OSRM.

## Sikkerhedspraksis
- **Krypteret under overførsel:** Ja
- **Brugeren kan anmode om sletning af data:** Ja

## Privatlivspolitik-URL
Du skal hoste `PRIVACY_POLICY.md` på en offentlig URL og indsætte linket i
Play Console. Nemmeste muligheder:
- GitHub Pages på dette repo, eller
- Et GitHub Gist, eller
- Råfil-link til PRIVACY_POLICY.md på `main`.

## Bemærk om annoncerings-id (Android 13+)
Appen viser AdMob-reklamer og bruger derved annonce-id. Tilføj i din Play
Console-deklaration, at appen anvender annonce-id. (google_mobile_ads tilføjer
selv `com.google.android.gms.permission.AD_ID`-tilladelsen.)
