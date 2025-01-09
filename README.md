Working on a pygame GUI for a prolog agent.
NLE is being used as an interface between nethack and prolog.
The logic of the agent is in Prolog, while the environment and GUI are in python.
The Docker file is no longer needed to run the dependecies since a Swi-prolog update.

The game is instantiated on the python side, the game object is passed onto the prolog when the agent is picked. 
To make an action, the agent invokes a python method from within prolog, using the game object it received. 
This way, the game monad calls the prolog agent that is itself a monad, that makes calls to methods inside the game object, when the prolog process ends, control is naturally passed onto the python process. 

Prolog:
- Astar will probably be subbed for a more reliable algorithm. - The sabe objective lists keep being re-added when explicitly stated not to
- Issues with items obstructing objectives have been mitigated but not completly solved
- Instead of tacking actions based on unreliable visual queues, the agent now takes decisions based on the feedback provided by the messages.  (ex: knowing if a kicked door opened)
- using messages as atoms has produced more streamlined code for the protocol part. 
- Not currently pushing boulders around... it's complicated... 
- Healing and eating from inventory needs to be worked on
- enhance decision making overall

Python:
- Nethack can be played as either a Human or Prolog Agent
- There's a Leaderboard that contains highscores recorded both from human players and the prolog agent. 
- The Joystick and Buttons work with the inputs of the game for both the human players and the prolog agent.
- The game has SFX and Background Music


Python 3.12 and the latest version of SWI are needed to run the project.
A python requirements.txt is included
Project runs from: *interface.py*

*will be changed in the future to be more sane*

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
|Neanderthal| 369   |  380   |  +11    |
|High Elf  | -     |  381   |  -  |
|Attendant | 370   |  382   |  +12    |
|Apprentice| 380   |  392   |  +12  |
