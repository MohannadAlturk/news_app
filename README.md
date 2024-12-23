News App

Dies ist eine Flutter-basierte Nachrichtenanwendung, die aktuelle Nachrichten aus verschiedenen Kategorien wie Technologie, Unterhaltung und mehr bereitstellt.
Voraussetzungen

    Flutter SDK
    Android Studio oder ein anderer bevorzugter Code-Editor
    Ein Konto bei NewsAPI.org
    Ein Konto bei Gemini

Installation

    Repository klonen: Klonen Sie dieses Repository auf Ihr lokales System.

git clone https://github.com/MohannadAlturk/news_app.git

Abhängigkeiten installieren: Navigieren Sie in das Projektverzeichnis und führen Sie den folgenden Befehl aus, um alle benötigten Pakete zu installieren.

flutter pub get

API-Schlüssel konfigurieren: Erstellen Sie eine Datei namens .env im Stammverzeichnis des Projekts und fügen Sie Ihre API-Schlüssel wie folgt hinzu:

    NEWS_API_KEY=IhrNewsAPIKey
    GEMINI_API_KEY=IhrGeminiAPIKey

    Hinweis: Ersetzen Sie IhrNewsAPIKey und IhrGeminiAPIKey durch Ihre tatsächlichen API-Schlüssel.

Ausführung des Projekts

    In Android Studio:
        Öffnen Sie Android Studio.
        Wählen Sie "Projekt öffnen" und navigieren Sie zum geklonten Repository.
        Stellen Sie sicher, dass alle Abhängigkeiten installiert sind, indem Sie flutter pub get ausführen.
        Starten Sie den Emulator oder verbinden Sie ein physisches Gerät.
        Klicken Sie auf "Ausführen", um die Anwendung zu starten.

    Über die Kommandozeile:

    flutter run

Wichtige Hinweise

    Wenn Sie die Anwendung über Android Studio oder die Kommandozeile ausführen, stellen Sie sicher, dass die .env-Datei mit gültigen API-Schlüsseln vorhanden ist.
    Beim Erstellen einer APK für die Verteilung werden die API-Schlüssel in die Build-Datei eingebettet.
