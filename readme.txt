        ��������������������������������������������������������������ͻ
        �     The Quest of Kwirk's Castle    PC-Version by Joe M.      �
        ��������������������������������������������������������������ͼ

        Dieses Programm wurde nicht f�r kommerziellen Einsatz
        geschrieben, sondern lediglich dazu, ein wenig Abwechslung in
        den mei�t trockenen EDV-Alltag zu bringen (und vielleicht auch,
        um meine Fa. JME Engineering etwas bekannt zu machen).

        Kwirk ist vollst�ndig in Turbo-Pascal implementiert.
        Sollte das Programm hier oder dort noch einige Fehler aufweisen,
        so bitte ich zu bedenken, da� es sich hier um Public-Domain-
        Software handelt, die mit dem geringsm�glichen Kosten- und
        Zeitaufwand erstellt wurde (Entwicklungszeit ca. 2 Wochen) und
        lediglich zu Freizeitvertreib und Vergn�gen, nicht f�r professi-
        onellen Einsatz dienen soll.


        Ziel des Spieles ist es, jeweils die Treppe (bzw. Fahne) oder
        den �u�eren Spielfeldrand eines Raumes zu erreichen.

        Mit den Cursortasten wird Kwirk bewegt. Sind mehrere Kwirks im
        Raum, so k�nnen Sie mit der Entertaste zwischen diesen
        umschalten.

        Schieben Sie die Kisten vollst�ndig ins Wasser um sowohl das
        Wasser alsauch die Kiste zu beseitigen.

        Nach Dr�cken der Backspacetaste wird der aktuelle Raum in seinen
        urspr�nglichen Zustand zur�ckversetzt.

        Mit der Tabulatortaste k�nnen Sie einen Raum �berspringen.

        Mit [Esc] gelangen Sie ins Auswahlmen� zur�ck, mit [F3] beenden
        Sie das Programm.

        Geben Sie von der Dos-Kommandozeile   Kwirk ?   ein um weitere
        Informationen zu erhalten.


        Erstellen eigener R�tzel:

        Die Dateien mit der Extension .Maz (von Maze) enthalten die
        R�tzel. Es handelt sich hierbei um reine Textdateien.

        Die erste Zeile einer R�tzeldatei enth�lt den Namen des R�tzels
        (in eckigen Klammern eingeschlossen, max. 32 Zeichen).

        Die anschlie�end aufgef�hrten R�ume sind jeweils durch eine in
        eckigen Klammern eingeschlossene Zeile voneinander getrennt.
        Innerhalb der Eckigen Klammern steht der Name des folgenden
        Raumes. Ein R�tzel kann maximal 50 R�ume enthalten.

        Beschreibung der R�ume:

          W          - Wand
          P          - Wasser (Pf�tze)
          Z          - Ziel (Treppe)
          J          - Jump (an dieser Stelle springt der
                             Kwirk vor Freude in die Luft)
          K > ^ < V  - Kwirk Ausgangsposition (maximal 10 pro Raum)


          � B                         - kleine Kiste

          Ƕ �׶ ��׶ BBBB            - waagerechte Kisten

          � � � B                     - senkrechte Kisten
          � � � B
            � � B
              � B

          ڿ �ܿ ڿ ���ܿ ���ܿ BBBBB - gro�e Kisten
          �� ��� �� ����� ����� BBBBB
                 ��       ����� BBBBB

          Die Beschreibung von Kisten durch ein oder mehrere B ist
          nur m�glich, wenn die Kisten nicht eng beieinander stehen,
          da das Programm ansonsten nicht in der Lage ist
          festzustellen, welches B zu welcher Kiste geh�rt.


          �            - Drehpunkt f�r 4-fl�glige T�r

          � � � �      - Drehpunkte f�r 3-fl�glige T�ren

          � � � � � �  - Drehpunkte f�r 2-fl�glige T�ren

          � � � �      - Drehpunkte f�r 1-fl�glige T�ren

           �           - T�rfl�gel
          � �
           �

          Beispiele f�r T�ren:
             �    �         �
             �   �ε   �   �ʵ   ɵ   �͵
             �    �    �         �

          oder auch (nur m�glich, wenn die T�ren nicht zu eng
                     beieinander stehen):
             D    D         D
             *   D*D   *   D*D   *D   D*D
             D    D    D         D


          Wenn in einem Raum bereits in der Ausgangsposition eine
          Kiste oder eine T�r zum Teil �ber einer Wasserpf�tze stehen
          soll, so mu� dieser Raum in der Datei 2-fach nebeneinander
          dargestellt werden (getrennt durch das | Zeichen).
          Aus der rechten Abbildung des Raumes wird dann nur das
          Wasser interpretiert (siehe auch Datei GoingUp1.Maz - Floor5).


        ��������������������������������������������������������������ͻ
        �  viel Spa� beim R�tzeln                              Joe M.  �
        ��������������������������������������������������������������ͼ
