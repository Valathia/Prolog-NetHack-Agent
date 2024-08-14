Working on a pygame GUI for a prolog agent.
NLE is being used as an interface between nethack and prolog.
The logic of the agent is in Prolog, while the environment and GUI are in python.
There's a dockerfile to run the dependencies, it's assumed it's being launched from a Mac silicon with XQuartz installed (to display pygame from the docker container)

Prolog:
- edge cases are being reviewed within the protocols
- Astar needs to move on from objectives when a path does not exist
- remove peaceful monsters/characters from the "monster roster" so that agent doesn't try to attack them
- enhance decision making overall

Python:
- Integrate Button class with image asset creation so that it can be used in the most general case.
- still missing 2 components: virtual keyboard that shows agent inputs and some metric measuring 
- needs a graphic asset to frame/display the info

Important info regarding NLE used:
https://gist.github.com/HanClinto/310bc189dcb34b9628d5151b168a34b0

Displacement of Monster Glyphs in relation to bitmap 
|Monster   |Glyph  | bitmap | Diff  |
|:---------|:-----:|:------:|:---:  |
|Giant ant | 0     |  0     |  0    |
|Hell Hound| 26    |  26    |  0    |
|Cereberus | -     |  27    |  -    |
|Gas Spore | 27    |  28    |  +1   |
|Shocking Sphere| 31    |  32    |  +1   |
|Beholder  | -     |  33    |  -    |
|Kitten    | 32    |  34    |  +2   |
|Baby Silver Dragon| 133   |  135   |  +2   |
|Baby Glistening Dragon| -     |  136   |  -    | 
|Baby Red Dragon| 134   |  137   |  +3   |     
|Silver Dragon| 142   |  145   |  +3   |
|Glistening Dragon| -     |  146   |  -    |
|Red Dragon   | 143   |  147   |  +4   |
|Jarberwok | 175   |  179   |  +4   |
|Vorpal Jaberwok| -     |  180   |  -    |
|K. Kop    | 176   |  181   |  +5   |
|Vampire Lord| 223   |  228   |  +5   |
|Vampire Mage| -     |  229   |  -    |
|Vlad the Impaler    | 224   |  230   |  +6   |
|Croesus   | 282   |  288   |  +6   |
|Charon    | -     |  289   |  -    |
|Ghost     | 283   |  290   |  +7   |
|Famine    | 310   |  317   |  +7   | 
|Mail Daemon| -     |  318   |  -    |
|Djini     | 311   |  319   |  +8   | 
|Shaman Karnov| 344   |  352   |  +8   |
|Earendil  | -     |  353   |  -    |
|Elwing    | -     |  354   |  -    |
|Hippocrates| 345   |  355   |  +10  |
|Chromatic Dragon| 357   |  367   |  +10  |
|Goblin King | -     |  368   |  -    |
|Cyclops   | 358   |  369   |  +11  |
|Neanderthal| 369   |  380   |  -    |
|High Elf  | -     |  381   |  +11  |
|Attendant | 370   |  382   |  -    |
|Apprentice| 380   |  392   |  +12  |
