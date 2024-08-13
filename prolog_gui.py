import pygame
import pygame.locals
#import gym - in the docker container the gym library is asked to be explicitly installed, after that it will interfere with the nle namespace and will not recognize it's gym's env's
import numpy as np
import janus_swi as janus
import interface
janus.consult('./main.pl',module='main')

#constants
LIST_MAX_SIZE = 15
ACTION_LIST = []

KEY_MAP = {
    'enter': 0,
    '[1]': 7,
    '[2]': 3,
    '[3]': 6,
    '[4]': 4,
    '[6]': 2,
    '[7]': 8,
    '[8]': 1,
    '[9]': 5,
    'up': 9,
    'down': 10,
    'w' : 11,
    'o': 12,
    'k':13,
    's':14,
    'e':15,
    'backspace':16,
    'i':17,
    'q':18,
    '[+]':19
}

# NLE ACTIONS FOR REFERENCE
# 0 MiscAction.MORE
# 1 CompassDirection.N
# 2 CompassDirection.E
# 3 CompassDirection.S
# 4 CompassDirection.W
# 5 CompassDirection.NE
# 6 CompassDirection.SE
# 7 CompassDirection.SW
# 8 CompassDirection.NW    #this is also yes
# 9 MiscDirection.UP
# 10 MiscDirection.DOWN
# 11 MiscDirection.WAIT
# 12 Command.OPEN
# 13 Command.KICK
# 14 Command.SEARCH
# 15 Command.EAT
# 16 Command.ESC
# 17 Command.INVENTORY
# 18 Command.QUAFF
# 19 Command.PICKUP

#output text received from prolog
def output_text(text):
    if len(ACTION_LIST) == LIST_MAX_SIZE:
        ACTION_LIST.pop(0)
    
    ACTION_LIST.append(text)

    interface.print_action_list(ACTION_LIST)
    pygame.display.update()


#is currently printing to console
def display_inv(env):
    inv_strs_index = env._observation_keys.index("inv_strs")
    inv_letters_index = env._observation_keys.index("inv_letters")
    inv_strs = env.last_observation[inv_strs_index]
    inv_letters = env.last_observation[inv_letters_index]

    for letter, line in zip(inv_letters, inv_strs):
        if np.all(line == 0):
            break
        print(letter.tobytes().decode("utf-8"), line.tobytes().decode("utf-8"))

#step function that plays into the env and updates the graphic display (used by prolog)
def step(env,num):
    
    step_res = env.step(num)

    if step_res[2]:
        #pygame.mixer.music.stop()
        #pygame.mixer.Sound.play(interface.gameover_sound)
        interface.game_over()

    interface.update_graphics(env,ACTION_LIST)

    return step_res