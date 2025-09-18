🏗️ Datenstruktur (erste Idee)

Wir wollen drei Dinge speichern:

Series (Zeitreihen) → jede Serie hat einen Namen oder Key (z. B. "cpu_usage", "temperature")

Points (Datenpunkte) → (timestamp, value)

Indexierung nach Zeit → effizient range-queries machen (from..to)

ETS-Tabellen-Layout

Series Registry

Tabelle: :series

Key: Name (Atom oder String)

Value: Metadaten (z. B. Unit, Tags)

{:series, "cpu_usage", %{unit: "%", tags: %{host: "server1"}}}


Points Table

Tabelle: :points

Key: {series, timestamp}

Value: Wert

{:points, {"cpu_usage", 1695000000}, 87.5}
{:points, {"cpu_usage", 1695000300}, 92.1}


👉 Vorteil:

ETS unterstützt schnelle lookup, select, match_object.

Abfragen nach {series, ts} oder Zeitintervallen sind easy.