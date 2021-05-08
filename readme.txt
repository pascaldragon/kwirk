        ╔══════════════════════════════════════════════════════════════╗
        ║     The Quest of Kwirk's Castle    PC-Version by Joe M.      ║
        ╚══════════════════════════════════════════════════════════════╝

        Dieses Programm wurde nicht für kommerziellen Einsatz
        geschrieben, sondern lediglich dazu, ein wenig Abwechslung in
        den meißt trockenen EDV-Alltag zu bringen (und vielleicht auch,
        um meine Fa. JME Engineering etwas bekannt zu machen).

        Kwirk ist vollständig in Turbo-Pascal implementiert.
        Sollte das Programm hier oder dort noch einige Fehler aufweisen,
        so bitte ich zu bedenken, daß es sich hier um Public-Domain-
        Software handelt, die mit dem geringsmöglichen Kosten- und
        Zeitaufwand erstellt wurde (Entwicklungszeit ca. 2 Wochen) und
        lediglich zu Freizeitvertreib und Vergnügen, nicht für professi-
        onellen Einsatz dienen soll.


        Ziel des Spieles ist es, jeweils die Treppe (bzw. Fahne) oder
        den äußeren Spielfeldrand eines Raumes zu erreichen.

        Mit den Cursortasten wird Kwirk bewegt. Sind mehrere Kwirks im
        Raum, so können Sie mit der Entertaste zwischen diesen
        umschalten.

        Schieben Sie die Kisten vollständig ins Wasser um sowohl das
        Wasser alsauch die Kiste zu beseitigen.

        Nach Drücken der Backspacetaste wird der aktuelle Raum in seinen
        ursprünglichen Zustand zurückversetzt.

        Mit der Tabulatortaste können Sie einen Raum überspringen.

        Mit [Esc] gelangen Sie ins Auswahlmenü zurück, mit [F3] beenden
        Sie das Programm.

        Geben Sie von der Dos-Kommandozeile   Kwirk ?   ein um weitere
        Informationen zu erhalten.


        Erstellen eigener Rätzel:

        Die Dateien mit der Extension .Maz (von Maze) enthalten die
        Rätzel. Es handelt sich hierbei um reine Textdateien.

        Die erste Zeile einer Rätzeldatei enthält den Namen des Rätzels
        (in eckigen Klammern eingeschlossen, max. 32 Zeichen).

        Die anschließend aufgeführten Räume sind jeweils durch eine in
        eckigen Klammern eingeschlossene Zeile voneinander getrennt.
        Innerhalb der Eckigen Klammern steht der Name des folgenden
        Raumes. Ein Rätzel kann maximal 50 Räume enthalten.

        Beschreibung der Räume:

          W          - Wand
          P          - Wasser (Pfütze)
          Z          - Ziel (Treppe)
          J          - Jump (an dieser Stelle springt der
                             Kwirk vor Freude in die Luft)
          K > ^ < V  - Kwirk Ausgangsposition (maximal 10 pro Raum)


          ▓ B                         - kleine Kiste

          ╟╢ ╟╫╢ ╟╫╫╢ BBBB            - waagerechte Kisten

          ╤ ╤ ╤ B                     - senkrechte Kisten
          ╧ ╪ ╪ B
            ╧ ╪ B
              ╧ B

          ┌┐ ┌▄┐ ┌┐ ┌▄▄▄┐ ┌▄▄▄┐ BBBBB - große Kisten
          └┘ └▀┘ ▐▌ └▀▀▀┘ ▐███▌ BBBBB
                 └┘       └▀▀▀┘ BBBBB

          Die Beschreibung von Kisten durch ein oder mehrere B ist
          nur möglich, wenn die Kisten nicht eng beieinander stehen,
          da das Programm ansonsten nicht in der Lage ist
          festzustellen, welches B zu welcher Kiste gehört.


          ╬            - Drehpunkt für 4-flüglige Tür

          ╠ ╩ ╣ ╦      - Drehpunkte für 3-flüglige Türen

          ╗ ╔ ╚ ╝ ║ ═  - Drehpunkte für 2-flüglige Türen

          ├ ┴ ┤ ┬      - Drehpunkte für 1-flüglige Türen

           ╥           - Türflügel
          ╞ ╡
           ╨

          Beispiele für Türen:
             ╥    ╥         ╥
             ║   ╞╬╡   ┬   ╞╩╡   ╔╡   ╞═╡
             ╨    ╨    ╨         ╨

          oder auch (nur möglich, wenn die Türen nicht zu eng
                     beieinander stehen):
             D    D         D
             *   D*D   *   D*D   *D   D*D
             D    D    D         D


          Wenn in einem Raum bereits in der Ausgangsposition eine
          Kiste oder eine Tür zum Teil über einer Wasserpfütze stehen
          soll, so muß dieser Raum in der Datei 2-fach nebeneinander
          dargestellt werden (getrennt durch das | Zeichen).
          Aus der rechten Abbildung des Raumes wird dann nur das
          Wasser interpretiert (siehe auch Datei GoingUp1.Maz - Floor5).


        ╔══════════════════════════════════════════════════════════════╗
        ║  viel Spaß beim Rätzeln                              Joe M.  ║
        ╚══════════════════════════════════════════════════════════════╝
