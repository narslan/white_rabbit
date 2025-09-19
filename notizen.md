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

Ideen für „buntere“ Metriken

CPU-Auslastung pro Scheduler

mit :erlang.statistics(:runtime) und :erlang.statistics(:wall_clock)

daraus eine kleine Formel für % CPU

das schwankt natürlicherweise schon etwas.

Nachrichten in der Prozess-Mailbox

Nimm einen Demo-GenServer, der zufällig Nachrichten verarbeitet.

Process.info(pid, :message_queue_len) schwankt dynamisch.

Simulation / Dummy-Last

bau einen Worker-Prozess, der in Schleifen irgendwas rechnet (z.B. Fibonacci, Sortieren, Random-Noise).

dessen Reduktionen (:reductions aus Process.info/2) hochlaufen.

WhiteRabbit als Timeseries-Benchmark

starte eine Routine, die jede Sekunde 100–1000 Events in WhiteRabbit schreibt.

Messe Durchsatz + Latenz.

dann zeigt die Chart richtige „Zacken“.

Noise-Generator (nur fürs Demo)

wenn du gar nichts messen willst, kannst du einfach

val = 50 + :rand.normal() * 10


erzeugen – sieht aus wie echte Messdaten.