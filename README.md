# WhiteRabbit

WhiteRabbit is a time series database in Elixir.

# Plan + Roadmap 
Datenmodellierung (wie speichere ich Zeitstempel + Werte effizient?)  

Indexing (z. B. nach Zeitintervallen)

Kompression (optional, aber spannend)

Abfragen (Aggregationen wie avg, min, max, count)

Nebenläufigkeit (GenServer/ETS/Agent oder sogar Sharding mit mehreren Prozessen)

insert/2 -> (timestamp, value) speichern

query/2 -> Werte in einem Zeitbereich abrufen

Erweiterungen:

Aggregationen (avg, sum, min, max) über Zeitintervalle

Retention-Policy: Alte Daten automatisch löschen

Downsampling: z. B. pro Minute einen Durchschnittswert speichern

Tags/Labels (wie Prometheus) → kleine Dimensionen (z. B. „sensor=temperature, location=room1“)