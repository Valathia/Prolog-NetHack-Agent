import pygame
#import pygame.locals
#import gym - in the docker container the gym library is asked to be explicitly installed, after that it will interfere with the nle namespace and will not recognize it's gym's env's
import numpy as np
import janus_swi as janus
import interface
janus.consult('./main.pl',module='main')

global CLOCK
CLOCK = pygame.time.Clock


KEY_MAP = {
    0: 'enter',
    7: '[1]',
    3: '[2]',
    6: '[3]',
    4: '[4]',
    2: '[6]',
    8: '[7]',
    1: '[8]',
    5: '[9]',
    9: 'up',
    10: 'down',
    11: 'w',
    12: 'o',
    13: 'k',
    14: 's',
    15: 'e',
    16: 'backspace',
    17: 'i',
    18: 'q',
    19: '[+]'
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
def output_text(text:str,var,game:interface.Game):
    if type(var) != str:
        text += str(var)
        game.graphics.output_text(text)
    else:
        game.graphics.output_text(text + var)


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

def step(env,num,game:interface.Game):
    
    #step_res = env.step(num)
    key_name = KEY_MAP[num]
    step_res = game.prolog_move(key_name)
    
    #game.graphics.update_graphics(env,0)

    if step_res == False:
        game.game_over()

    return step_res

