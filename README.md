# NEWS APP - Nachrichten-Tool

## Übersicht

Die NEWS AI App ist eine umfassende Nachrichtenplattform, die Benutzern aktuelle und relevante Nachrichten basierend auf ihren Interessen bietet. Mit moderner Benutzerverwaltung, anpassbaren Präferenzen, KI-gestützten Zusammenfassungen und Favoritenfunktionen hebt sich diese App durch eine benutzerfreundliche Erfahrung und leistungsstarke Funktionen hervor.

## Hauptfunktionen (Must Have)

### Benutzerregistrierung und -anmeldung

- **E-Mail/Passwort-Authentifizierung** mit Firebase Authentication.
- **Validierung der Eingabedaten**:
  - Überprüfung auf gültige E-Mail-Adressen (z. B. abcd@xxx.xxx).
  - Überprüfung der Passwortstärke (mindestens 6 Zeichen).
- **Passwort-Reset**:
  - Möglichkeit, das Passwort per E-Mail-Reset-Link zurückzusetzen.

### Interessenverwaltung

- **Oberfläche zur Auswahl von Interessensgebieten** (z. B. Gaming, Politik, Sport, Technologie, Gesundheit).
- **Speicherung und Aktualisierung** der Präferenzen in Firebase Firestore.
- Möglichkeit für Benutzer, ihre Präferenzen jederzeit in den Einstellungen anzupassen.
- **Nur bei der Registrierung angezeigt.**

### Nachrichtenabruf

- **Abrufen von Nachrichtenartikeln** von News API basierend auf den Benutzerpräferenzen.
- **Aktualisierung der Artikelliste**:
  - Beim Start der App und bei manueller Aktualisierung (Pull-to-Refresh).
  - Aktualisierung bei Änderungen der Präferenzen.
- **Möglichkeit für Web-Ansicht** des Artikels.
- **Fehlerbehandlung**:
  - Umgang mit Netzwerkfehlern und Anzeige entsprechender Meldungen.

### AI-Agent

- **Zusammenfassung von Artikeln**:
  - Einsatz eines LLMs zur Generierung von Zusammenfassungen der Artikel.
  - Anzeige eines Ladeindikators während die Zusammenfassung erstellt wird.
- **Einstellbare LLMs in den Einstellungen**:
  - Auswahl zwischen Gemini 1.5 Flash und OpenAI.

### Benutzeroberfläche

- **Login-Screen**:
  - Benutzerfreundliches Design für Anmeldung und Registrierung.
- **Präferenzen-Screen**:
  - Oberfläche zur Auswahl und Anpassung von Interessensgebieten.
- **Nachrichten-Screen**:
  - Anzeige der Artikelliste mit Titel, Datum, Quelle, Kategorie und Beschreibung.
  - Implementierung einer Navigation zu Favoriten und Einstellungen über eine Bottom Navigation Bar.
- **Responsive Design** für eine optimale Benutzererfahrung auf verschiedenen Geräten.

### Favoritenfunktion

- Möglichkeit für Benutzer, **Artikel als Favoriten** zu markieren.
- **Speicherung der Favoriten** in Firebase Firestore unter dem Benutzerprofil.
- Zugriff auf die Favoritenliste über die Navigation.

### Einstellungen

- Anpassung der Interessensgebiete.
- Abmeldung aus der App.
- Passwort ändern.
- Konto löschen.

## Nice-to-Have-Anforderungen

### Suchfunktion

- Artikeln anhand von **Schlüsselwörtern oder Phrasen** suchen.

### Teilen von Artikeln

- Artikel über soziale Medien, E-Mail oder Messaging-Apps teilen.
- **Share-Buttons direkt in der Artikelansicht.**

### Mehrsprachige Unterstützung

- Benutzeroberfläche auf **Deutsch/Englisch/Arabisch/Bulgarisch**.
- Übersetzung von Artikeln auf die genannten Sprachen mithilfe von LLM.

### Artikelbilder anzeigen

- Anzeige von **Vorschaubildern** der Artikel in der Detailansicht.

### Text-To-Speech

- **Text-To-Speech** für die Zusammenfassung von Artikeln.

### Kontoeinstellungen

- Möglichkeit zum **Löschen von Konten** innerhalb der Einstellungen.
- Möglichkeit zum **Ändern von Passwörtern** innerhalb der Einstellungen.

## Installation

### Voraussetzungen

- Flutter SDK.
- Android Studio oder ein bevorzugter Code-Editor.
- Ein Konto bei [NewsAPI](https://newsapi.org).
- Ein Konto bei [Gemini](https://gemini.com).

### Schritte

1. **Repository klonen**:
   ```bash
   git clone https://github.com/MohannadAlturk/news_app.git
   ```
2. **Abhängigkeiten installieren**:
   ```bash
   flutter pub get
   ```
3. **API-Schlüssel konfigurieren**:
   - Erstellen Sie eine Datei namens `.env` im Stammverzeichnis des Projekts und fügen Sie folgende Schlüssel hinzu:
     ```env
     NEWS_API_KEY=IhrNewsAPIKey
     GEMINI_API_KEY=IhrGeminiAPIKey
     ```
   **Hinweis**: Ersetzen Sie `IhrNewsAPIKey` und `IhrGeminiAPIKey` durch Ihre tatsächlichen API-Schlüssel.

4. **App starten**:
   ```bash
   flutter run
   ```

**Für die APK-Builds** sind die API-Schlüssel bereits eingebettet und können ohne zusätzliche Konfiguration ausgeführt werden.

## Weitere Informationen

- [Flutter-Dokumentation](https://docs.flutter.dev)
- [NewsAPI-Dokumentation](https://newsapi.org/docs)
- [Gemini API Dokumentation](https://docs.gemini.com)

Bei Fragen oder Problemen können Sie ein Issue im Repository öffnen.

