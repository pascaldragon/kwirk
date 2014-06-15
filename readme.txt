        ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
        º     The Quest of Kwirk's Castle    PC-Version by Joe M.      º
        ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

        Dieses Programm wurde nicht fr kommerziellen Einsatz
        geschrieben, sondern lediglich dazu, ein wenig Abwechslung in
        den meiát trockenen EDV-Alltag zu bringen (und vielleicht auch,
        um meine Fa. JME Engineering etwas bekannt zu machen).

        Kwirk ist vollst„ndig in Turbo-Pascal implementiert.
        Sollte das Programm hier oder dort noch einige Fehler aufweisen,
        so bitte ich zu bedenken, daá es sich hier um Public-Domain-
        Software handelt, die mit dem geringsm”glichen Kosten- und
        Zeitaufwand erstellt wurde (Entwicklungszeit ca. 2 Wochen) und
        lediglich zu Freizeitvertreib und Vergngen, nicht fr professi-
        onellen Einsatz dienen soll.


        Ziel des Spieles ist es, jeweils die Treppe (bzw. Fahne) oder
        den „uáeren Spielfeldrand eines Raumes zu erreichen.

        Mit den Cursortasten wird Kwirk bewegt. Sind mehrere Kwirks im
        Raum, so k”nnen Sie mit der Entertaste zwischen diesen
        umschalten.

        Schieben Sie die Kisten vollst„ndig ins Wasser um sowohl das
        Wasser alsauch die Kiste zu beseitigen.

        Nach Drcken der Backspacetaste wird der aktuelle Raum in seinen
        ursprnglichen Zustand zurckversetzt.

        Mit der Tabulatortaste k”nnen Sie einen Raum berspringen.

        Mit [Esc] gelangen Sie ins Auswahlmen zurck, mit [F3] beenden
        Sie das Programm.

        Geben Sie von der Dos-Kommandozeile   Kwirk ?   ein um weitere
        Informationen zu erhalten.


        Erstellen eigener R„tzel:

        Die Dateien mit der Extension .Maz (von Maze) enthalten die
        R„tzel. Es handelt sich hierbei um reine Textdateien.

        Die erste Zeile einer R„tzeldatei enth„lt den Namen des R„tzels
        (in eckigen Klammern eingeschlossen, max. 32 Zeichen).

        Die anschlieáend aufgefhrten R„ume sind jeweils durch eine in
        eckigen Klammern eingeschlossene Zeile voneinander getrennt.
        Innerhalb der Eckigen Klammern steht der Name des folgenden
        Raumes. Ein R„tzel kann maximal 50 R„ume enthalten.

        Beschreibung der R„ume:

          W          - Wand
          P          - Wasser (Pftze)
          Z          - Ziel (Treppe)
          J          - Jump (an dieser Stelle springt der
                             Kwirk vor Freude in die Luft)
          K > ^ < V  - Kwirk Ausgangsposition (maximal 10 pro Raum)


          ² B                         - kleine Kiste

          Ç¶ Ç×¶ Ç××¶ BBBB            - waagerechte Kisten

          Ñ Ñ Ñ B                     - senkrechte Kisten
          Ï Ø Ø B
            Ï Ø B
              Ï B

          Ú¿ ÚÜ¿ Ú¿ ÚÜÜÜ¿ ÚÜÜÜ¿ BBBBB - groáe Kisten
          ÀÙ ÀßÙ ÞÝ ÀßßßÙ ÞÛÛÛÝ BBBBB
                 ÀÙ       ÀßßßÙ BBBBB

          Die Beschreibung von Kisten durch ein oder mehrere B ist
          nur m”glich, wenn die Kisten nicht eng beieinander stehen,
          da das Programm ansonsten nicht in der Lage ist
          festzustellen, welches B zu welcher Kiste geh”rt.


          Î            - Drehpunkt fr 4-flglige Tr

          Ì Ê ¹ Ë      - Drehpunkte fr 3-flglige Tren

          » É È ¼ º Í  - Drehpunkte fr 2-flglige Tren

          Ã Á ´ Â      - Drehpunkte fr 1-flglige Tren

           Ò           - Trflgel
          Æ µ
           Ð

          Beispiele fr Tren:
             Ò    Ò         Ò
             º   ÆÎµ   Â   ÆÊµ   Éµ   ÆÍµ
             Ð    Ð    Ð         Ð

          oder auch (nur m”glich, wenn die Tren nicht zu eng
                     beieinander stehen):
             D    D         D
             *   D*D   *   D*D   *D   D*D
             D    D    D         D


          Wenn in einem Raum bereits in der Ausgangsposition eine
          Kiste oder eine Tr zum Teil ber einer Wasserpftze stehen
          soll, so muá dieser Raum in der Datei 2-fach nebeneinander
          dargestellt werden (getrennt durch das | Zeichen).
          Aus der rechten Abbildung des Raumes wird dann nur das
          Wasser interpretiert (siehe auch Datei GoingUp1.Maz - Floor5).


        ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
        º  viel Spaá beim R„tzeln                              Joe M.  º
        ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
