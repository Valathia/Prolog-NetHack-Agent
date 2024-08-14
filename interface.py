import pygame, sys
import pygame.locals
import nle
import numpy as np
import janus_swi as janus
import spritesheet
janus.consult('./main.pl',module='main')

gym = nle.nle.env.gym
STAT_KEYS = [
    'X',
    'Y',
    'strg25',       # str percentage ? 3..25
    'Str',        #regular str
    'Dex',         #dexterity  
    'Con',         #constitution
    'Int',         #intelligence
    'Wis',         #wisdom
    'Char',        #charisma
    'Score',        #score
    'hp',           #hitpoints
    'maxhp',        #max_hitpoints
    'Dlvl',        #depthgit remote add origin
    'gold',         #gold
    'energy',       #energy
    'maxenergy',    #max_energy
    'AC',           #armor_class
    'monsterlvl',  #monster level, hit-dice
    'explvl',       #experience level
    'exp',          #experience points
    'T',        #time
    'hunger',       #hunger state  
    'carrying',     #carrying capacity
    'dungeon_num',  #dungeon number
    'lvl_num',      #level number
    'con_bit_mask', #condition bit mask 
    'alig'          #character alignment
]

#St:14 Dx:13 Co:12 In:11 Wi:18 Ch:7 Neutral S:4 Dlvl:1 $:0 HP:4(14) Pw:4(4) AC:4 Xp:1/1 T:43
STATS_TO_PRINT = ['Str','Dex','Con','Int','Wis','Char','Score','Dlvl','AC','T']

#constants
#F0EAD6 - eggshell collor hexcode
GLYPH_COL = 79                                                  # number of columns in glyph matrix
GLYPH_ROW = 21                                                  # number of rows in glyph matrix
SIZE = 16                                                       # bitmap sprite size 16x16
OFFSET = 40                                                     # elements per row in bitmap
WIDTH = GLYPH_COL * SIZE                                        # display width of dungeon 
HEIGHT = GLYPH_ROW * SIZE                                       # display height of dungeon
MAP_SIZE = (WIDTH, HEIGHT)      # dungeon display size as tupple

#init pygame and sound mixer  --- No sound in docker so everything pertaining sound must be commented out -- init is also being handled in main call
#pygame.init()
#pygame.mixer.init(44100, -16, 2, 2048)


SCREEN_W = 1920
SCREEN_H = 1080

SCREEN = pygame.display.set_mode((SCREEN_W, SCREEN_H))
#pygame.FULLSCREEN
#this option can be added to pygame-display.setmode, however, Xquartz does not like this and gives a memory allocation error when pygame tries to go to fullscreen

#visuals

#map sprite
ss = spritesheet.Spritesheet("assets/dawnhack_16.bmp")

#surfaces and bg
BG = pygame.image.load("assets/cropped_dungeon_door.jpg")
fog_BG = pygame.image.load("assets/fog.jpg")
glass_panel = pygame.image.load("assets/menu_panel.png")

#button assets
play_glow = pygame.image.load("assets/play_text.png")
quit_glow = pygame.image.load("assets/quit_text.png")
play_glow_small = pygame.image.load("assets/play_text_small.png")
quit_glow_small = pygame.image.load("assets/quit_text_small.png")
game_over_text = pygame.image.load("assets/gameover.png")
main_menu_text = pygame.image.load("assets/mainmenu.png")
button_shadow = pygame.image.load("assets/button_shadow.png")
glass_button = pygame.image.load("assets/glass_button.png")
glass_button_selected = pygame.image.load("assets/glass_button_selected.png")



def get_font(size):  # Returns Press-Start-2P in the desired size
    return pygame.font.Font("assets/font.ttf", size)

#Button class, handles button actions and swaps images depending no state
#Needs to be integrated with file that creates the images for text and surfaces so that it can generate the assets itself instead of them being previously generated and passed on by hand (becomes more general)
class Button():
    def __init__(self,text,width,height,pos,action,img,img_small,arg): 
        # core attributes
        self.pressed = False
        #self.hover = False  -- was being for sfx pertaining the buttons only being played once

        #top rectangle
        self.top_rect =  pygame.Rect(pos,(width,height))            # default positioning and size for the button
        self.button_df = glass_button                      # default appearance for the button
        self.button = self.button_df                       # button appearence that will be changed dinamically

        #text default properties
        self.text_colour = '#F0EAD6'                                # initially text is only text and not an image of text
        self.text = text                                       # text to be displayed
        self.text_size = 75                                         # text initial size
        #storing default surface
        self.text_surf_df = get_font(self.text_size).render(text,True,self.text_colour)                     # text default surface
        self.text_surf = self.text_surf_df                                                                  # text surface that will be changed dinamically
        #diferent positions depending on if it's img or text
        self.text_rect_df = self.text_surf.get_rect(center = (self.top_rect.centerx + 40, self.top_rect.centery+15))    # text default positioning when it is text
        self.text_rect_img = (720,pos[1]+15)                                                        # text positioning when it's an image 
        self.text_rect = self.text_surf.get_rect(center = self.top_rect.center)                                         # text positioning

        #hover
        self.img = img                                                                                          #text as image when hovered over
        self.button_hover = glass_button_selected                                                           #button hovered over appearance

        #click
        self.action = action                                                                                    #function that gives button an action
        self.arg = arg                                                                                          #optional argument for function, can be 1 or None
        self.img_small = img_small                                                                              #text as image when clicked



    def draw(self):
        SCREEN.blit(self.button,self.top_rect)
        SCREEN.blit(self.text_surf, self.text_rect)
        self.check_click()

    def check_click(self):
        mouse_pos = pygame.mouse.get_pos()
        if self.top_rect.collidepoint(mouse_pos):
            #hover position
            self.text_surf = self.img
            self.text_rect = self.text_rect_img
            self.button = self.button_hover
            
            #if not self.hover:                             #sound related
                #pygame.mixer.Sound.play(select)
                #self.hover = True
            
            if pygame.mouse.get_pressed()[0]:
                #if not self.pressed:                      #sound related
                    #pygame.mixer.Sound.play(click)
                
                self.text_surf = self.img_small
                self.text_rect = self.text_rect_img
                self.pressed = True
            else: 
                self.text_surf = self.img
                self.text_rect = self.text_rect_img
                if self.pressed == True:
                    #run code
                    self.pressed = False
                    if self.arg is None:
                        self.action()
                    else: 
                        self.action(self.arg)
        else:
            #return text and button to default modes
            self.text_surf = self.text_surf_df
            self.text_rect = self.text_rect_df
            self.button = self.button_df
            #self.hover = False                             #sound related


def env_init():
    MOVE_ACTIONS = tuple(nle.nethack.CompassDirection)
    MISC = tuple(nle.nethack.MiscAction)
    MISC_DIRECTION = tuple(nle.nethack.MiscDirection)

    NAVIGATE_ACTIONS = MISC + MOVE_ACTIONS + MISC_DIRECTION + (
    nle.nethack.Command.OPEN,
    nle.nethack.Command.KICK,
    nle.nethack.Command.SEARCH,
    nle.nethack.Command.EAT,
    nle.nethack.Command.ESC,
    nle.nethack.Command.INVENTORY,
    nle.nethack.Command.QUAFF,
    nle.nethack.Command.PICKUP
    )
    env = gym.make("NetHackScore-v0",actions=NAVIGATE_ACTIONS)
    env.reset() 

    return env

def quit_game():
    pygame.quit()
    sys.exit()

# dungeon_size W=1264 H=336 --> sobra 656 px de lado começar em: 1315 o texto
# the bitmap has more sprites than we have monsters in the game. Some monsters will eventually be implemented or exist in other nethack versions
# for the current nle nethack implementation, we had to figure out which monsters were extra, find the relation between their glyph# and bitmap# and skip over them, adjusting further positions
# MONSTERS:
# monsters appear in the following categories: GLYPH_MON, GLYPH_PET, GLYPH_INVIS, GLYPH_DETECT,GLYPH_BODY and GLYPH_RIDDEN + GLYPH_STATUE
# for all categories, Mon, Pet and Detect detect all map to the normal sprite
# INVIS is it's own category and is only one glyph that maps to itself
# BODY should default to corpse sprite in map
# RIDDEN since we don't know will default to normal mapping
# Statue has it's own sprites BUT that also need to account for missing monsters 
# currently extra monsters are:  Cerebrus, Beholder, Baby Shimmering Dragon, Shimmering Dragon, Vorpal Jabberwock, Vampire Mage, Charon and Mail Demon. (Mail Demon is in the game but not in NLE)
# ITEMS:
# There are also extra items associated with the extra monsters that need to be account for in the OBJ leading to offsets needing to be made as well
# currently extra itens are: shimmering dragon scale mail, shimmering scales and scroll of mail.
# Other GLYPHS:
# CMAP, Explosions, Zap and Warning can be directly map to their own from [2359,2540]
# With the exception of Walls, there are 5 styles of walls in the bitmap. 
# default walls are mapped 1 to 1. However, depending on the dungeon number the wall mapping should change to diferent styles
# so far, we were only able to figure out that:
# Dungeon #0 = Default walls
# Dungeon #1 = ? 
# Dungeon #2 = Gnomish Mines which correspondes with the 1st alternative walls in the bitmap
# Dungeon #3 = ?
# Dungeon #4 = ?
# There are currently 33 walls unaccounted for. 
# The GLYPH_SWALLOW has 8 glyphs per monster that correspond to a monster swallowing the player in one of the 8 directions, no idea how these glyphs should map... 
def draw_dungeon(matrix,dungeon_num):

    game_surface = pygame.Surface((WIDTH, HEIGHT))
    SCREEN.blit(game_surface, (100, 50))

    for i in range(0,GLYPH_ROW):
        for j in range(0,GLYPH_COL):
            n = matrix[i][j]
            #instanteaded as 0 in case monster is not a statue
            n_statue = 0
            
            #adjust statues - 1st statue is 1082 on the bitmap  - statues also need to account for monster redundency
            if n>=5595:
                n_statue = 1082
                n -= 5595
            
            #monster redundency calculus
            if(n<1906):

                #monster
                if n <= 380:
                    pass
                #pet monster
                elif n < 762:
                    n-=381
                #762 is invisible monster
                elif n == 762:
                    n = 393
                # detect
                elif n < 1144:
                    n -= 763
                # body - should default to corpse object 2146 maps to 636 on bitmap
                # human bodies have diferent corpse default
                elif n < 1525:
                    n = 636
                # ridden
                else:
                    n-= 1525

                #Luker above 101101/4
                #account for extra monsters in bitmap not in game
                # Monster   Glyph   bitmap  Diff
                #Giant ant  0       0       0
                #Hell Hound 26      26      0
                #Cereberus  -       27      -
                #Gas Spore  27      28      +1
                #Shk. Sph.  31      32      +1
                #Beholder   -       33      -
                #Kitten     32      34      +2
                #bb sil Dr. 133     135     +2 
                #bg gli Dr. -       136     -   
                #bb red dr. 134     137     +3      
                #Silver Dr. 142     145     +3
                #Glist. Dr. -       146     -
                #Red Dr.    143     147     +4
                #Jarberwok  175     179     +4
                #V Jaberwok -       180     -
                #K. Kop     176     181     +5
                #Vamp. Lord 223     228     +5
                #Vamp. Mage -       229     -
                #Vlad       224     230     +6
                #Croesus    282     288     +6
                #Charon     -       289     -
                #Ghost      283     290     +7
                #Famine     310     317     +7  
                #Mail Demon -       318     -
                #Djini      311     319     +8  
                #Sha Karnov 344     352     +8
                #Earendil   -       353     -
                #Elwing     -       354     -
                #Hippocrate 345     355     +10
                #Chrom. Drg 357     367     +10
                #Gob. King  -       368     -
                #Cyclops    358     369     +11
                #neanderthl 369     380     +11
                #high elf   -       381     -
                #attendant  370     382     +12
                #Apprentice 380     392     +12
                if n <= 27:
                    pass
                elif n <=31:
                    n+=1
                elif n <= 133:
                    n+=2
                elif n <= 142:
                    n+=3
                elif n <=175:
                    n+=4
                elif n <=223:
                    n+=5 
                elif n <=282:
                    n+=6
                elif n<=310:
                    n+=7
                elif n<=344:
                    n+=8
                elif n<=357:
                    n+=10
                elif n<=369:
                    n+=11
                elif n<381:
                    n+=12
                #because of possibility of corpse or invis monster that does not need to be further adjusted -- else do nothing
                else:
                    pass

            #1st item glyph:1903 bitmap: 394
            #OBJ Class:
            elif (n<2541):
                if n <= 1989:
                    n -= 1512
                elif n <= 1998:
                    n -= 1511
                elif n <= 2244:
                    n -= 1510
                else:
                    #CMAP starts at 2359
                    #diferent walls for specific dungeons/levels are unacounted for (33) walls
                    #gnomish mine wall range in bitmap 1038 - 1048
                    if n>= 2360 and n<=2370 and dungeon_num == 2:
                        n -= 2360 + 1038
                    else:
                        n -= 1509
            #2541 Swallow for monsters is unacounted for, it's 8 per monster. 

            #adjust warning glyphs - 1st warning glyph is 1032 on  the bitmap
            elif (n<5595):
                n-=4557
            
            
            #account for n possibly being a statue                
            n += n_statue
            
            col = n // OFFSET
            row = n % OFFSET
            img = ss.image_at((row*SIZE, col*SIZE, SIZE, SIZE))
            SCREEN.blit(img, (50+(j*SIZE),50+(i*SIZE)))

def print_action_list(action_list):
    text_surface = pygame.Surface((650,450))
    text_surface.fill("#000000")
    SCREEN.blit(text_surface,(1315,50))

    font_text = get_font(10)

    for i in range(0,len(action_list)):
        render_text = font_text.render(action_list[i],True, "#F0EAD6")
        SCREEN.blit(render_text, (1315, 50+i*20))

def update_message(msg):
    terminal_font_m = get_font(20)
    msg_len = len(msg)
    strmsg = ''
    for i in range(0,msg_len):
        if msg[i] == 0:
            break
        strmsg += chr(msg[i])

    game_msg = terminal_font_m.render(strmsg, True, "#F0EAD6")
    SCREEN.blit(game_msg, (50, 10))

def update_graphics(env,action_list):
    
    terminal_font_s = get_font(15)
    
    black_surface = pygame.Surface((SCREEN_W, SCREEN_H))
    black_surface.fill((0, 0, 0))
    SCREEN.blit(black_surface, (0, 0))

    matrix = env.last_observation[0]
    msg = env.last_observation[5]
    stat_values = env.last_observation[4]

    if msg[0] != 0:
        update_message(msg)
    
    stat_values_s = map(str,stat_values)
        
    stat_dict = dict(zip(STAT_KEYS, stat_values_s))
    #St:14 Dx:13 Co:12 In:11 Wi:18 Ch:7 Neutral S:4 Dlvl:1 $:0 HP:4(14) Pw:4(4) AC:4 Xp:1/1 T:43
    stat_msg = 'HP:' + stat_dict['hp'] + '(' + stat_dict['maxhp'] + ') PW:' + stat_dict['energy'] + '(' + stat_dict['maxenergy'] + ') Lvl:' + stat_dict['explvl'] + ' Exp:' + stat_dict['exp'] + ' $:' + stat_dict['gold'] + ' Dungeon #:' + stat_dict['dungeon_num']
    stat_msg_2 = 'Neutral'

    for key in STATS_TO_PRINT:
        stat_msg_2 += ' ' + key + ':' + stat_dict[key]
        
    render_stat_msg = terminal_font_s.render(stat_msg,True, "#F0EAD6")
    render_stat_msg2 = terminal_font_s.render(stat_msg_2,True, "#F0EAD6")
    SCREEN.blit(render_stat_msg, (50, 450))
    SCREEN.blit(render_stat_msg2, (50, 470))

    draw_dungeon(matrix,stat_dict['dungeon_num'])
    
    if len(action_list)>=1:
        print_action_list(action_list)
    
    pygame.display.update()

def init_prolog():
    pygame.display.set_caption("Prolog Agent")
    env = env_init()
    janus.query_once("main:main_start(ENV).",{'ENV':env})
    game_over()

def game_over():
    pygame.display.set_caption("Game Over")

    SCREEN.blit(fog_BG, (0, 0))
    SCREEN.blit(glass_panel,(0,0))

    MENU_RECT = game_over_text.get_rect(center=(960, 300))


    PLAY_BUTTON = Button('Play',500,150,(680, 490),init_prolog,play_glow,play_glow_small,None)
    QUIT_BUTTON = Button('Quit',500,150,(680, 660),quit_game,quit_glow,quit_glow_small,None)
    #SCREEN.blit(button_shadow,(710, 500))
    #SCREEN.blit(button_shadow,(710, 700))
    SCREEN.blit(game_over_text, MENU_RECT)

    while True:
        for event in pygame.event.get():
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    pygame.quit()
                    sys.exit()
        
        SCREEN.blit(fog_BG, (0, 0))
        #SCREEN.blit(glass_panel,(MENU_RECT.topleft[0]+180,MENU_RECT.topleft[1]))
        SCREEN.blit(game_over_text, MENU_RECT)
        PLAY_BUTTON.draw()
        QUIT_BUTTON.draw()
        pygame.display.update()

def main_menu():
    pygame.init()
    pygame.display.set_caption("Menu")
    #pygame.mixer.music.load('assets/menu_bg_music.mp3')
    #pygame.mixer.music.play(-1)           
    
    SCREEN.blit(BG, (0, 0))
    SCREEN.blit(glass_panel,(0,0))

    MENU_RECT = main_menu_text.get_rect(center=(960, 300))

    PLAY_BUTTON = Button('Play',500,150,(680, 490),init_prolog,play_glow,play_glow_small,None)

    QUIT_BUTTON = Button('Quit',500,150,(680, 660),quit_game,quit_glow,quit_glow_small,None)
    #SCREEN.blit(button_shadow,(690, 480))
    #SCREEN.blit(button_shadow,(690, 680))
    SCREEN.blit(main_menu_text, MENU_RECT)

    while True:
        for event in pygame.event.get():
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    pygame.quit()
                    sys.exit()

        SCREEN.blit(BG, (0, 0))
        SCREEN.blit(glass_panel,(MENU_RECT.topleft[0]+180,MENU_RECT.topleft[1]))
        SCREEN.blit(main_menu_text, MENU_RECT)
        #SCREEN.blit(button_shadow,(710, 500))
        #SCREEN.blit(button_shadow,(710, 700))
        PLAY_BUTTON.draw()
        QUIT_BUTTON.draw()
        
        pygame.display.update()

if __name__ == '__main__':
    main_menu()