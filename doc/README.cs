Postup tvorby české difonové databáze
=====================================

Difonová databáze byla připravována postupem popsaným ve festvoxové dokumentaci
dostupné na http://www.festvox.org/download.html .  Předpokládá se obeznámenost
s touto dokumentací, tento dokument poskytuje pouze doplňující informace a
některé konkrétní zkušenosti.

Následující body popisují jednotlivé části práce v přibližně chronologickém
pořadí.

* Příprava seznamu slov k nahrávání.

Vše ohledně tohoto bodu se nachází v adresáři doc/recording/ .

* Provedení nahrávky.

Nahrávka byla provedena v nahrávacím studiu za účasti fonetiků, kteří dohlíželi
na správnou výslovnost (s ohledem na požadavky difonové databáze) mluvčího.
Nahrávací pokyny pro mluvčího se nachází v souboru
doc/recording/README.speaker.cs .

* Úvodní zpracování nahrávky.

Výsledná nahrávka byla z nahrávacího studia dodána ve dvou WAV souborech jako
stereo se samplovací frekvencí 44100 Hz.  Prvním krokem tedy bylo převedení
nahrávky na mono a spojení obou částí.  Toho lze snadno dosáhnout programem
sox:

  $ sox part1.wav -c part1-mono.wav
  $ sox part2.wav -c part2-mono.wav
  $ params='-t raw -r 44100 -w -s'
  $ { sox part1-mono.wav $params - ; sox part2-mono.wav $params - } |
    sox $params - recording.wav

Soubor recording.wav byl následně rozdělen na WAV soubory obsahující jednotlivá
slova s pomocí funkce Splitter programu Fvoxedit.  Protože pořadí slov
v nahrávce bylo na řadě míst přeházené oproti seznamu slov recording/words,
bylo nutné provést ruční přiřazení souborů odpovídajícím difonům.  To bylo
provedeno s pomocí emacsového prográmku tools/assign.el.  Při té příležitosti
byly také opraveny chyby v automatickém rozdělení nahrávky na jednotlivá slova,
byly odstraněny nepoužitelné části nahrávky a byly odstraněny nadbytečné zvuky
(jako třeba odkašlání).  Slova, která byla pouze chybně vyslovena, avšak jinak
představují použitelný materiál, byla zachována.

Výsledné .wav soubory se nachází v adresáři wav/.

* Kontrola difonů.

Bylo zkontrolováno, že nahrávka (po vyřazení chybných částí) obsahuje všechny
difony ze seznamu doc/recording/diphones a že neobsahuje (vlivem chyb při
zpracování) žádné jiné difony.

Při té příležitosti bylo zjištěno, že vlivem chyb v souboru doc/recording/words
nahrávka neobsahuje difony n-f, n-g a n-k.  Ty byly později doplněny jako
aliasy do souboru dic/phdiph.est, spolu s aliasy pro difony obsahující dlouhé
samohlásky, viz soubor etc/phaliases.

Byl vygenerován difon #-# do souboru recording/ph0000.wav:

  $ dd if=/dev/zero of=ph0000.wav bs=2000 count=1
  $ sox -s -b -r 1000 ph0000.raw -s -w -r 44100 ph0000.wav

* Vytvoření diphonového indexu.

Podle festvoxové dokumentace byly s pomocí festvoxových nástrojů vytvořeny a
naplněny adresáře prompt-wav/, prompt-lab/, prompt-ceb/, lab/ a cep/ a následně
soubor dic/phdiph.est.  Uvedené adresáře jsou kromě lab/ již dále nepotřebné a
je možné je smazat.

Protože automatické rozdělení souborů na fonémy dopadlo zcela neuspokojivě,
bylo provedeno ruční rozdělení s pomocí nástroje Fvoxedit.

Do souboru dic/phdiph.est byly doplněny výše zmíněné difonové aliasy ze souboru
etc/phaliases.

* Ořezání nahraných souborů

Ze zvukových souborů v adresáři wav/ byly s pomocí skriptu tools/remsilence.scm
odstraněny úvodní a koncové tiché části, pro zmenšení celé nahrávky.  Skript
využívá informací ze souborů v adresáři lab/ a předpokládá, že hranice poslední
pauzy je umístěna přesně na konci zvukového souboru.

* Vyhledání pitchmarks.

Provedeno podle festvoxové dokumentace, včetně korekce skriptem make_pm_fix.

* Normalizace.

Vzhledem k tomu, že intenzita jednotlivých slov v nahrávce byla znatelně
rozdílná, bylo nutné provést jejich normalizaci.  Byl tedy aplikován festvoxový
skript find_powerfacts pro vygenerování potřebných informací.  Pokud nebudete
chtít dále využívat informace o rozdělení slov na jednotlivé fonémy, je možné
po tomto kroku smazat adresář lab/.

* Vygenerování LPC parametrů.

Provedeno skriptem tools/make_lpc, převzatým z Festvoxu.  Vzhledem k vyšší
samplovací frekvenci nahrávky byl parametr -lpc_order zvýšen na 46, dle
doporučení z festvoxové dokumentace.

* Definice jazykového souboru.

Pro nový hlas byl vytvořen definiční soubor festvox/czech_ph.scm pro
festival-czech.

Pomocí skriptu tools/phonelen.scm byl z obsahu souborů v adresáři lab/
vygenerován seznam délek jednotlivých hlásek.  Protože hlas voice_czech_ph je
v tuto chvíli jediný svobodný český festivalový hlas, byly tyto délky použity
přímo v czech.scm.  Ostatní hlasy, pokud pro ně tyto délky nejsou vhodné, mohou
definovat vlastní délky hlásek ve svých definičních souborech.  Skript
tools/phonelen.scm obsahuje na začátku konfigurační proměnnou *length-factor*
určující koeficient, kterým se spočtené délky hlásek násobí (například proto,
že mluvčí namluvil slova kvůli důrazu na zřetelnou výslovnost nepřirozeně
pomalu).

* Testování a opravy databáze.

S ohledem na kvalitu výsledného hlasu lze měnit následující parametry:

- Hranice difonů.

- Pitchmarks.

- Výběr konkrétního souboru difonu z více výskytů téhož difonu v databázi.

- Určení intenzity použitých vzorků (soubor etc/powfacts).

- Intonační pravidla ve festival-czech.

- Výšku hlasu a její variabilitu v proměnné czech-int-simple-params*.

Při testování hlasu může být vhodné nastavit hodnotu proměnné czech-randomize
na nil.

* Odkazy

voice-czech-ph: http://cvs.freebsoft.org/repository/voice-czech-ph
festival_czech: http://www.freebsoft.org/festival-czech
fvoxedit: http://cvs.freebsoft.org/repository/fvoxedit


Local Variables:
mode: outline
End:
