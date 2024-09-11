import nle.env.tasks
import nle.nethack
import pygame, sys
import numpy as np
import spritesheet
import nle
import nle.nethack as nethack
import json
import janus_swi as janus
import gymnasium as gym
#gym = nle.nle.env.gym
janus.consult('./main.pl',module='main')

#from PIL import Image, ImageOps
#nle.nethack.NETHACKOPTIONS
#nle.env.tasks
#internal[7] has the hunger stat
#1920x1080 
#2560x1600
#SCREEN_W = 1920
#SCREEN_H = 1080
# #screen must be set before anything starts
#scrren center: 960x540
#1526x708
#big_monitor:       center - 960x426 --- Center_WxCenter_H-114                  size: 1466x646 -- file size:       1527x710     61x64 30.5 32 --  left_corner: 227x103
#big_mon_overlay:   center - of big_mon                                         size: 1385x553                     1527x710
#big_mon_inside:    center - of big_mon                                         size: 1330x480  --  actual content space: 1300x450 leftcorner: big_monitor_left_corner_x+83 x big_monitor_left_corner_y+98
#small_monitor:     top left corner - 1058x803 -- Center_W+98 x Center_H+263    size: 695x272       --  left_corner: 1405x939
#small_mon_inside:  center-to-small - small-center (1405x940) --                size: 630x200   --  actual content space: 615x190 leftcorner: small_monitor_left_corner+40 x small_monitor_right_corner+41
#small_mon_overlay: center-to-small - small-center (1405x940) --                size: 657x235   -- 701x279 - 350.5x139.5 615x190 - 307,5x95 -- 43x45

#1527x710
#1300x450
#763.5 x 355
#650x225
#113,5 + 130

#when changing adapting this code to agent:
#Joystick and Keypad should both handle env.step. 
#comment/uncomment press_key in both classes accordingly, pressed key checks will not be needed. 
#comment/uncomment corresonding section in game class

#facilmente podia construir um objecto que recebe uma string com o path do ficheiro, para converter numa sprite
#apartir do tamanho , assumindo que é quadrado, calcula quantas frames a animação tem. para fazer load de sprites. 
#deve ser indicado se o ficheiro tem as frames todas (de repouso a repouso) ou se é meia animação (de repouso a estado final - no caso dos botões o estado final é primido)

#se na imagem ele tem o canto esquerdo em: 227,103 (-31,-32)
#196x71
#coin button pos: 946,889
#size: 85 x 85
class Sound:
    def __init__(self,sound_dict):
        self.files = self.init_sound(sound_dict)
        self.key_sounds = {
            "[1]":self.files['joystick_1'],
            "[2]":self.files['joystick_1'],
            "[3]":self.files['joystick_1'],
            "[4]":self.files['joystick_2'],
            "[6]":self.files['joystick_1'],
            "[7]":self.files['joystick_2'],
            "[8]":self.files['joystick_2'],
            "[9]":self.files['joystick_2']
        }
        self.msg_sounds = {
            #doors
            "As you kick the door" : self.files['door_slam'],
            "door crash open.": self.files['door_slam'],
            "WHAM" : self.files['door_resist'],
            "door resists": self.files['door_resist'],
            'kick at empty': self.files['miss'],
            "The door opens.":self.files['door_unlock'],
            "unlock and open.":self.files['door_unlock'],
            #combat
            "hits!": self.files['take_bump'],
            "bites!":  self.files['take_bump'],
            "You are hit": self.files['take_bump'],
            "You kill": self.files['monster_death'],
            "killed": self.files['monster_death'],
            "destroy": self.files['monster_death'],
            "You miss ": self.files['miss'],
            "misses": self.files['miss'],
            "zaps": self.files['zap'],
            "zap.": self.files['zap'],
            #message sfx
            "gurgling": self.files["fountain"],
            "cash register": self.files["chime"],
            "You hear water falling on coins.": self.files["fountain"],
            "bubbling water":self.files["fountain"],
            "splashing": self.files["splashing"],
            'counting money': self.files['counting'],
            "hear a door open": self.files['door_open'],
            "hear the footsteps": self.files['footsteps'],
            "thunder" :  self.files['thunder'],
            "crashing rock" : self.files['crashing_rock'],
            "rock falls on your head!": self.files['crashing_rock'],
            "howling": self.files['howling'],
            'reveille': self.files['bugle'],
            "You hear a chugging sound.": self.files['heal'],
            "slow drip": self.files['drip'],
            #music trap/Squeak Board
            "C note" : self.files["do"],
            "D flat" : self.files["do#"],
            "D note" : self.files["re"],
            "E flat" : self.files["re#"],
            "E note" : self.files["mi"],
            "F note" : self.files["fa"],
            "F sharp" : self.files["fa#"],
            "G note" : self.files["sol"],
            "G sharp" : self.files["sol#"],
            "A note" : self.files["la"],
            "B flat" : self.files["la#"],
            "B note" : self.files["si"],
            #traps
            #arrow
            "shoots out at you!": self.files["arrow"],
            "loud click!": self.files["joystick"],
            #bear trap
            "A bear trap": self.files["bear_trap"],
            "the bear trap.": self.files["metal_release"],
            #anti magic field
            "magical energy drain away": self.files["drain"],
            #fire
            "tower of flame erupts" : self.files["fire"],
            #hole
            "gaping hole under you!": self.files["fall"],
            "You fall down": self.files["fall"],
            "fall into a pit": self.files["fall"],
            "You land on a set of sharp iron spikes.": self.files["fall"],
            #teleport
            "You shudder for a moment.": self.files["teleport"],
            #ladmine
            "KAABLAMM!!!": self.files["explosion"],
            "Kaablamm!": self.files["distant_explosion"],
            "distant explosion.": self.files["distant_explosion"],
            "KABOOM!!": self.files["explosion"],
            #magic trap
            "explodes!": self.files["explosion"],
            "magical explosion!": self.files["explosion"],
            "deafening roar!": self.files["roar"],
            "flash of light": self.files["flash"],
            #boulder
            "Click!": self.files["joystick"],
            "loud crash as a boulder": self.files['crashing_rock'],
            "rumbling": self.files['rumble'],
            #rust
            "gush of water": self.files["water_gush"],
            #sleep
            "cloud of gas": self.files["gas"],
            #trap door
            #"trap door opens"
            #food
            "is delicious!": self.files['eat'],
            "yummy":self.files['eat'],
            "You discard the open tin.": self.files['eat'],
            "Delicious!":self.files['eat'],
            "finish eating":self.files['eat'],
            "stop eating":self.files['eat'],
            "completely healed." :self.files['heal'],
            "You feel much better.":self.files['heal'],
            #Blecch!
            #path sfx
            'hidden': self.files['hidden'],
            "solid stone":self.files['bonk'],
            "a wall": self.files['bonk'],
            "a secret door.": self.files['hidden'],
            #misc
            "Welcome to experience level": self.files['level_up'],
            #"healthy!": self.files['level_up'], #message displayed when monk levels up to level 3
            "$": self.files['collect_coin'],
            "you move the boulder": self.files['rock_push'],
            #pet
            "swap places": self.files['cat'],
            "You stop.  Your kitten": self.files['cat_way'],
            "You stop.  Your little": self.files['dog_way']
        }
        self.limit_time = ['fountain','hear a door open','The door opens.','counting money',"You hear water falling on coins.","bubbling water", "tower of flame erupts","flash of light"]

    def init_sound(self,sound_dict):
        new_dict:dict[str,pygame.mixer.Sound] = {}

        pygame.mixer.init(44100, -16, 2, 2048)
        pygame.mixer.music.set_volume(1)

        for key in sound_dict:
            new_dict[key] = pygame.mixer.Sound(sound_dict[key]['file'])

        return new_dict

    def play_bg_sound(self,sound:str):
        #music can be queued using: pygame.mixer.music.queue()
        #music.play takes an int with the number of times it will play (5 plays 6 times - plays once and repeats 5) , -1 plays in loop
        pygame.mixer.music.fadeout(200)
        pygame.mixer.music.unload()
        pygame.mixer.music.load(sound)
        pygame.mixer.music.play(-1)

    def play_sfx(self,sfx:pygame.mixer.Sound):
        pygame.mixer.Sound.play(sfx)

    def msg_sfx(self,msg):
        for keys in self.msg_sounds:
            if keys in msg:
                if keys in self.limit_time:
                    self.msg_sounds[keys].play(maxtime=3000)
                elif keys == 'footsteps':
                    self.msg_sounds[keys].play().fadeout(10000)
                elif keys == 'reveille' or keys == 'rumbling':
                    self.msg_sounds[keys].play(maxtime=8000)
                else:    
                    self.msg_sounds[keys].play()

class ImageBin:
    def __init__(self,positioning,images,surfaces,animations):
        #display and screen vars
        self.default_display = 0 
        self.screen_w, self.screen_h, self.screen = self.init_screen_vars()
        self.center_w:int = self.screen_w // 2
        self.center_h:int = self.screen_h // 2
        
        self.images = self.init_images(images)
        self.pos = self.init_positioning(positioning)
        self.surfaces = self.init_surfaces(surfaces)
        self.animations = self.init_animation(animations)
        
    def init_images(self,images):
        new_dict:dict[str,pygame.Surface]  = {}
        for keys in images:
            new_dict[keys] = pygame.image.load(images[keys]["file"]).convert_alpha()
        
        return new_dict

    def init_positioning(self,pos_dict):
        new_dict:dict[str,tuple[int,int]] = {}
        for key in pos_dict:
            new_dict[key] = (pos_dict[key][0],pos_dict[key][1])
        
        #relative positions:
        new_dict["center"] = (self.center_w,self.center_h)
        new_dict["big_monitor_left_corner"] = (227-21,103-32)
        new_dict["big_monitor_fs_left_corner"] = (new_dict["big_monitor_left_corner"][0]+new_dict["big_monitor_fs_margin"][0], new_dict["big_monitor_left_corner"][1]+new_dict["big_monitor_fs_margin"][1])
        new_dict["big_content_left_corner"] = (new_dict["big_monitor_left_corner"][0]+new_dict["big_content_margin"][0], new_dict["big_monitor_left_corner"][1]+new_dict["big_content_margin"][1])
        new_dict["small_monitor_center"] = (self.center_w+98,self.center_h+263)
        new_dict["small_monitor_left_corner"] = (1058-2,803-4)
        new_dict["small_content_left_corner"] = (new_dict["small_monitor_left_corner"][0]+new_dict["small_content_margin"][0], new_dict["small_monitor_left_corner"][1]+new_dict["small_content_margin"][1])
        return new_dict

    def init_surfaces(self,surface_dict):
        new_dict:dict[str,pygame.Surface] = {}
        for key in surface_dict:
            pos_key =surface_dict[key]['pos']
            size_key = surface_dict[key]['size']
            image_key = surface_dict[key]['image']
            new_dict[key] = self.init_surface(self.pos[pos_key],self.pos[size_key],self.images[image_key])

        return new_dict 


    def init_animation(self,animation_dict):
        anim_dict:dict[str,spritesheet.Animation] = {}
        for key in animation_dict:
            key_dict = animation_dict[key]
            anim_dict[key] = spritesheet.Animation(key_dict["file"],key_dict["frame_width"],key_dict["is_full_strip"],key_dict["is_mirrored"],key_dict["is_symmetric"])
            
            if key_dict['init_fade_in']:
                surface_key = key_dict["fade_in_surface"]
                anim_dict[key].set_fade_in(self.surfaces[surface_key],True)
            
            if key_dict['init_fade_out']:
                surface_key = key_dict["fade_out_surface"]
                anim_dict[key].set_fade_out(self.surfaces[surface_key],True)

        return anim_dict
    
    def init_screen_vars(self):
        screen_W, screen_H = pygame.display.get_desktop_sizes()[self.default_display]
        return screen_W, screen_H, pygame.display.set_mode((screen_W,screen_H),pygame.RESIZABLE,display=self.default_display)
    
    def init_surface(self,pos,size,image):
        rect = pygame.Rect(pos,size)
        content_surface = pygame.Surface(size, pygame.SRCALPHA)
        content_surface.blit(image, (0,0),rect)

        return content_surface

    def set_new_pos_var(self,key_name,pos):
        self.pos[key_name] = pos

class Keys:
    def __init__(self,dict):
        self.nle_move:int =  dict["nle_move"]                            #action in nle
        self.controller:str = dict["controller"]      #component type where the key will fall under (joystick:directional | buttons: all other actions)
        self.has_graphics:bool =  dict["has_graphics"] 

class Directional(Keys):
    def __init__(self, dict):
        super().__init__(dict)
        self.anim_ss = spritesheet.Animation(dict["file"],dict["frame_size"],dict["is_full_strip"],dict["is_mirrored"],dict["is_symmetric"]) 

class Buttons(Keys):
    def __init__(self, dict):
        super().__init__(dict)
        self.pos = (0,0)     #placeholder



#Keyset of animated keys of same type
class Joypad:
    """
    Parent class for all controllers aka key sets
    """
    def __init__(self,key_dict,w,h,images):
        self.key_dict:dict[str,Buttons]|dict[str,Directional] = key_dict
        self.is_pressed = False
        self.key_pressed:str = ''
        self.w_refresh:int = w
        self.h_refresh:int = h
        self.images:ImageBin = images

    def animation(self,anim_array:list[pygame.Surface],clock,base_pos:tuple[int,int],update_rect:pygame.Rect,bg_clean:pygame.Surface):

        size = len(anim_array)
        aux = bg_clean.copy()
        for i in range(size):
            #clock must be synced - this is probably a bad idea actually
            clock.tick(60)
            #blit the clean bg to the bg_surface
            aux.blit(bg_clean,(0,0))
            #blit the sprite to the bg_surface
            aux.blit(anim_array[i],(0,0))
            #blit the screen
            self.images.screen.blit(aux,base_pos)
            pygame.display.update(update_rect)
        
    def press_key(self,env,key,clock,mode)->tuple: #type: ignore
        pass

    def release_key(self,clock):
        pass

class Joystick(Joypad):
    """
    Joystick behaviours and assets. -> is a collection of Keys, specifically Directional(Keys)
    Properties can be used for objects with similar behaviour. 
    """
    def __init__(self,key_dict:dict[str,Directional],images:ImageBin,pos,w_joystick_anim,h_joystick_anim):
        super().__init__(key_dict,w_joystick_anim,h_joystick_anim,images)
        self.pos:tuple[int,int] = pos
        self.key_dict = key_dict
        self.default_state = self.init_default()
        #clean surface
        self.update_rect = pygame.Rect(self.pos,(w_joystick_anim,h_joystick_anim))
        self.bg_clean= pygame.Surface([w_joystick_anim, h_joystick_anim], pygame.SRCALPHA)
        self.bg_clean.blit(self.images.images['bg'], (0, 0), self.update_rect)
        #for this to work better, a buffer is needed to queue animations if they aren't done.
        self.is_anim = False 
        self.anim_size = 0
        self.cur_frame = 0
        #self.anim_play = []
        self.anim_cur = []
        self.anim_done = True
        self.iddle = False 
        self.iddle_key = ''
        
    def init_default(self):
        key = list(self.key_dict.keys())[0]
        return self.key_dict[key].anim_ss.default_frame #type: ignore
    

    #joystick functions for the menus to swap between options with the animation loops going on and without nle steps
    def press_key_loop(self,key_name):
        self.is_anim = True
        self.anim_cur = self.key_dict[key_name].anim_ss.anim_press   #type: ignore
        self.anim_size = len(self.anim_cur)
        self.is_pressed = True
        self.key_pressed = key_name

    def release_key_loop(self):
        self.is_anim = True
        self.anim_cur = self.key_dict[self.key_pressed].anim_ss.anim_release #type: ignore
        self.anim_size = len(self.anim_cur)  
        self.is_pressed = False

    def set_iddle(self,key_name):
        self.iddle = True 
        self.iddle_key = key_name

    #the coin button functionalities are very similiar to the joystick.
    #the button is created as a joystick and the loop and iddle animation are added for the button
    #the iddle animation is for it to "blink", and the loop animation is to be able to press it from within the loop and have it return to idle
    def iddle_animation(self):
        frame: pygame.Surface = self.key_dict[self.iddle_key].anim_ss.toggle() #type: ignore
        self.images.screen.blit(self.bg_clean,self.pos)
        self.images.screen.blit(frame,self.pos)
        pygame.display.update(self.update_rect)
    
    def loop_animation(self):
        if self.is_anim:
            if self.anim_size != self.cur_frame:

                clean = self.bg_clean.copy()
                clean.blit(self.anim_cur[self.cur_frame],(0,0))
                #blit the screen
                self.images.screen.blit(clean,self.pos)
                pygame.display.update( self.update_rect)
                self.cur_frame +=1
                
            else:
                self.cur_frame = 0
                self.is_anim = False

        elif self.iddle:
            if not self.is_pressed or self.key_pressed != self.iddle_key:
                self.iddle_animation()

    def press_key(self,env,key,clock,mode)-> tuple:

        if self.is_pressed:
            if key != self.key_pressed:
                self.release_key(clock)
                self.animation(self.key_dict[key].anim_ss.anim_press,clock,self.pos,self.update_rect,self.bg_clean) # type: ignore
        else: 
            self.animation(self.key_dict[key].anim_ss.anim_press,clock,self.pos,self.update_rect,self.bg_clean) # type: ignore
        #env.step(self.key_dict[key].nle_move)
        self.is_pressed = True 
        self.key_pressed = key

        #if mode:
        step_res = env.step(self.key_dict[key].nle_move)
        return step_res

    def release_key(self,clock):
        if self.is_pressed:
            self.is_pressed = False
            self.animation(self.key_dict[self.key_pressed].anim_ss.anim_release,clock,self.pos,self.update_rect,self.bg_clean) # type: ignore
            return True
        else:
            return False

#still has hardcoded values in class init
class Keypad(Joypad):
    """
    Keypad behaviours and assets. -> is a collection of Keys, specifically Button(Keys)
    """
    def __init__(self,key_dict:dict[str,Buttons],images:ImageBin,button_base,button_width,button_height):
        super().__init__(key_dict,button_width,button_height,images)
        self.default_state = self.images.animations['buttons_ss'].default_frame
        self.button_base = button_base
        self.button_pos, self.button_rect ,self.clean_matrix = self.button_layout()
        self.shared_anim = True 
        self.anim = self.images.animations['buttons_ss']
        self.init_buttons(self.button_pos,'pos')
        self.init_buttons(self.button_rect,'update_rect')
        self.init_buttons(self.clean_matrix,'bg_clean')

    def press_key(self,env,key,clock,mode)->tuple:
        #The game itself does not work well when allowing for multiple inputs in a row
        #if self.is_pressed:
        step_res:tuple = env.step(self.key_dict[key].nle_move)

        if key != self.key_pressed:
            if self.is_pressed:
                self.release_key(clock)
            else:
                self.animation(self.anim.anim_press,clock,self.key_dict[key].pos,self.key_dict[key].update_rect,self.key_dict[key].bg_clean) # type: ignore
                self.is_pressed = True
                self.key_pressed = key
        
        return step_res

    def release_key(self,clock):
        if self.is_pressed:
            self.animation(self.anim.anim_release,clock,self.key_dict[self.key_pressed].pos,self.key_dict[self.key_pressed].update_rect,self.key_dict[self.key_pressed].bg_clean) # type: ignore
            self.is_pressed = False
            self.key_pressed = ''
            return True
        else:
            return False
    
    def set_pos(self,key,pos) -> None:
        self.key_dict[key].pos = pos #type: ignore
    
    def set_update_rect(self,key,rect):
        self.key_dict[key].update_rect = rect #type: ignore

    def set_update_bg_clean(self,key,bg_clean):
        self.key_dict[key].bg_clean = bg_clean   #type: ignore

    def init_buttons(self,matrix,attribute):
        calls = {"pos":self.set_pos,"update_rect":self.set_update_rect,"bg_clean":self.set_update_bg_clean}

        BUTTON_KEYS = ['K','e','s','q','up','down']
        for row in matrix:
            for value in row:
                key: str = BUTTON_KEYS.pop(0)
                calls[attribute](key,value)

    def button_layout(self):
        button_pos:list[list[tuple[int,int]]] = []
        button_rect:list[list[pygame.Rect]] = []
        button_bg = []
        modifier = 0
        surface = pygame.Surface((self.w_refresh,self.h_refresh))
        bg = self.images.images['bg'].copy()
        for i in range(3):
            button_pos.append([])
            button_rect.append([])
            button_bg.append([])
            if i!=0:
                modifier = -25
            # else:
            #     modifier = 0
            
            for j in range(2):
                button_pos[i].append((self.button_base[0]+i*125,self.button_base[1]+modifier+j*100))
                rect = pygame.Rect(((self.button_base[0]+i*125,self.button_base[1]+modifier+j*100)),(self.w_refresh,self.h_refresh))
                
                #if a new object isn't created for each one, it won't work
                aux = surface.copy()
                button_rect[i].append(rect)
                aux.blit(bg,(0,0),rect)
                button_bg[i].append(aux)

        return button_pos,button_rect, button_bg

#vertical menu currently has hardcoded values
class MenuVertical(Joypad):
        """
        Big Monitor Vertical menus behaviours and assets. 
        Is a collection of Keys, in this instance Directional(Keys). 
        """
        def __init__(self,key_dict:dict[str,Directional],images:ImageBin,button_base,button_width,button_height,assets):
            super().__init__(key_dict,button_width,button_height,images)
            self.button_base = button_base
            self.button_pos,self.cursor_pos = self.button_layout()
            self.who_is_pressed = 0
            self.menu_len = len(self.button_pos)
            self.cursor_anim = self.images.animations['arrow']
            self.key_list = self.init_buttons()
            self.cur_key = self.key_dict['start'].anim_ss.anim_press[0] #type: ignore
            self.cur_key_pos:tuple[int,int] = self.button_pos[0] 
            self.cur_cursor_pos:tuple[int,int] = self.cursor_pos[self.who_is_pressed]
            self.prev_key = self.key_dict['quit'].anim_ss.anim_release[0] #type: ignore
            self.prev_key_pos:tuple[int,int] = self.button_pos[1]
            self.assets = assets
        
        def button_layout(self):
            button_pos:list[tuple[int,int]] = []
            cursor_pos:list[tuple[int,int]] = []
            #hardcoded needs to be changed
            #+40 + 35
            for i in range(2):
                button_pos.append((self.button_base[0],self.button_base[1]+i*125))
                cursor_pos.append((self.button_base[0]+40,self.button_base[1]+i*125+35))

            return button_pos,cursor_pos

        def init_buttons(self):
            key_list = []
            i = 0
            for key in self.key_dict:             
                self.key_dict[key].pos = self.button_pos[i] # type: ignore
                key_list.append(key)
                i+=1
            return key_list
        
        def toggle_key(self,dir):
            prev_key = self.key_list[self.who_is_pressed]
            self.prev_key = self.key_dict[prev_key].anim_ss.default_frame   # type: ignore
            self.prev_key_pos = self.button_pos[self.who_is_pressed]
            self.who_is_pressed +=dir
            
            if self.who_is_pressed>=self.menu_len:
                self.who_is_pressed = 0
            
            if self.who_is_pressed < 0:
                self.who_is_pressed = self.menu_len - 1
            
            new_key = self.key_list[self.who_is_pressed]
            self.cur_key = self.key_dict[new_key].anim_ss.anim_press[0] # type: ignore
            self.cur_key_pos = self.button_pos[self.who_is_pressed]
            self.cur_cursor_pos = self.cursor_pos[self.who_is_pressed]

class MenuHorizontal(Joypad):
        #button_width = 340
        #button_height = 99
        """
        Big Monitor horizontal menus behaviours and assets.
        Is a collection of Keys, in this instance Directional(Keys). 
        """
        def __init__(self,key_dict:dict[str,Directional],images:ImageBin,button_base,button_width,button_height,assets):
            super().__init__(key_dict,button_width,button_height,images)
            self.button_base = button_base
            self.button_spacing = self.images.pos[self.key_dict[list(self.key_dict.keys())[0]].controller][0]
            self.button_pos = self.button_layout()
            self.who_is_pressed = 0
            self.menu_len = len(self.button_pos)
            self.key_list = self.init_buttons()
            self.cur_key = self.key_dict[list(self.key_dict.keys())[0]].anim_ss.anim_press[0] #type: ignore should be yes/human
            self.cur_key_pos:tuple[int,int] = self.button_pos[0] 
            self.prev_key = self.key_dict[list(self.key_dict.keys())[1]].anim_ss.anim_release[0] #type: ignore should be no/prolog
            self.prev_key_pos:tuple[int,int] = self.button_pos[1]
            self.assets = assets
        
        def button_layout(self):
            button_pos:list[tuple[int,int]] = []
            #+40 + 35
            for i in range(2):
                button_pos.append((self.button_base[0]+i*self.button_spacing,self.button_base[1]))
            return button_pos

        def init_buttons(self):
            key_list = []
            i = 0
            for key in self.key_dict:             
                self.key_dict[key].pos = self.button_pos[i] # type: ignore
                key_list.append(key)
                i+=1
            return key_list
        
        def toggle_key(self,dir):
            prev_key = self.key_list[self.who_is_pressed]
            self.prev_key = self.key_dict[prev_key].anim_ss.default_frame   # type: ignore
            self.prev_key_pos = self.button_pos[self.who_is_pressed]
            self.who_is_pressed +=dir
            
            if self.who_is_pressed>=self.menu_len:
                self.who_is_pressed = 0
            
            if self.who_is_pressed < 0:
                self.who_is_pressed = self.menu_len - 1
            
            new_key = self.key_list[self.who_is_pressed]
            self.cur_key = self.key_dict[new_key].anim_ss.anim_press[0] # type: ignore
            self.cur_key_pos = self.button_pos[self.who_is_pressed]

class ControllerSet:
    """
    Instantiates and keep all of the needed physical controllers and their behaviours.
    The controllers are the joystick, buttons, coin button and all menus. 
    """
    def __init__(self,keys_dict,controller_dict,images:ImageBin):
        self.keys:dict[str,Keys] = {}
        self.key_type_map = [Keys,Directional,Buttons]
        self.controller_type_map = [Joystick,Keypad,MenuVertical,MenuHorizontal]
        self.images = images
        self.controller_settings = self.init_vars(controller_dict)
        self.controller_set = self.populate(keys_dict)

    def init_vars(self,controller_dict):
        controllers = {}
        for key in controller_dict:
            base_key = controller_dict[key]['base']
            offset_key = controller_dict[key]['offset']
            base = self.images.pos[base_key]
            offset = self.images.pos[offset_key]

            new_pos = (base[0]+offset[0],base[1]+offset[1])
            self.images.set_new_pos_var(controller_dict[key]["pos_key"],new_pos)
            controllers[key] = {}
            controllers[key]['key_dict'] = {}
            controllers[key]['type'] = self.controller_type_map[controller_dict[key]['type']]
            controllers[key]['pos'] = new_pos
            size_key = controller_dict[key]['size']
            controllers[key]['width'] = self.images.pos[size_key][0]
            controllers[key]['height'] = self.images.pos[size_key][1]
            
            if controllers[key]['type'] == MenuHorizontal or controllers[key]['type'] == MenuVertical:
                asset_size = len(controller_dict[key]['assets'])
                assets = []
                for i in range(0,asset_size,2):
                    image_key = controller_dict[key]['assets'][i]
                    pos_key = controller_dict[key]['assets'][i+1]
                    assets.append((self.images.images[image_key],self.images.pos[pos_key]))
                controllers[key]['assets'] = assets
        
        return controllers

    def populate(self,keys_dict):
        controller = {}
        for key in keys_dict:
            key_type = keys_dict[key]["graphic_component"]      #if key has a graphic component
            aux = self.key_type_map[key_type](keys_dict[key])   #key dictionary
            controller_key = keys_dict[key]["controller"]                  #key Joypad/controller
            if key_type != 0:
                self.controller_settings[controller_key]['key_dict'][key] = aux
            self.keys[key] = aux

        for key in self.controller_settings:
            settings =  self.controller_settings[key]
            #the menus have screen assets to be rendered during the bg animation loops
            if settings['type'] == MenuHorizontal or settings['type'] == MenuVertical:
                controller[key] = settings['type'](settings['key_dict'],self.images,settings['pos'],settings["width"],settings["height"],settings["assets"])
            else:
                controller[key] = settings['type'](settings['key_dict'],self.images,settings['pos'],settings["width"],settings["height"])
            
        return controller

    def get_controller_type(self,key_name)-> Joystick|Keypad|MenuVertical:
        key_parent: str = self.keys[key_name].controller
        return self.controller_set[key_parent]

class Dungeon:
    def __init__(self):
        self.glyph_col = 79                                                             # number of columns in glyph matrix 1264 px -1300
        self.glyph_row = 21                                                             # number of rows in glyph matrix    336px - 372
        self.size = 16                                                                  # bitmap sprite size 16x16
        self.offset= 40                                                                 # elements per row in bitmap
        self.width = self.glyph_col * self.size                                         # display width of dungeon 
        self.height = self.glyph_row * self.size                                        # display height of dungeon
        self.map_size = (self.width, self.height)       # dungeon display size as tupple
        self.map_sprite =  spritesheet.Spritesheet("assets/dawnhack_16.bmp",16)
    
    def draw_dungeon(self,matrix,dungeon_num):

        game_surface = pygame.Surface((self.width, self.height),pygame.SRCALPHA)

        for i in range(0,self.glyph_row):
            for j in range(0,self.glyph_col):
                n = matrix[i][j]
                #instanteaded as 0 in case monster is not a statue
                n_statue = 0
                
                if n!= 2359:
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
                            #CMAP starts at 2359,
                            #diferent walls for specific dungeons/levels are unacounted for (33) walls
                            #gnomish mine wall range in bitmap 1038 - 1048
                            if n>= 2360 and n<=2370:
                                match(dungeon_num):
                                    case 1:
                                        #Gehennom - unsure
                                        n -= 2360
                                        n += 1049
                                    case 2:
                                        #gnomish mines
                                        n -= 2360
                                        n += 1038
                                    case 3:
                                        #Ft. Ludios - unsure
                                        n -= 2360
                                        n += 1060
                                    case 4:
                                        #sokoban
                                        n -= 2360
                                        n += 1071
                                    case _:
                                        n -= 1509
                            else:
                                n -= 1509
                    #2541 Swallow for monsters is unacounted for, it's 8 per monster. 
                    #adjust warning glyphs - 1st warning glyph is 1032 on  the bitmap
                    elif (n<5595):
                        n-=4557

                    #account for n possibly being a statue                
                    n += n_statue
                    
                    col = n // self.offset
                    row = n % self.offset
                    img = self.map_sprite.image_at(row,col)
                    game_surface.blit(img, (j*self.size,i*self.size))
        return game_surface

#isto tá off by one, não faças perguntas
class Leaderboard:
    def __init__(self,images,small_content_update_rect) -> None:
        self.cur_frame = 0
        self.cur_index = 0
        self.fps = 60
        self.file = 'leaderboard.json'
        self.cur_list = []
        self.small_font = pygame.font.Font("assets/font.ttf", 15)
        self.header = pygame.font.Font("assets/font.ttf", 30).render('High Scores',True, "#ff742f")
        self.header_space = 30+10 #45
        self.header_pos = 308- self.header.get_rect().centerx
        self.board = self.init_leaderboard()
        self.images = images
        self.size = len(self.board)
        self.small_content_update_rect = small_content_update_rect
        self.offset = self.init_offset()
        self.bg_anim = self.images.animations['highscore_bg']
        self.assets = [(self.images.images['highscore_header'],(0,0)),(self.images.images['new_highscore'],(0,0))]
        self.json_keys = ['RANK','NAME','LVL','SCORE']

    def init_leaderboard(self):
        board = [['RANK','NAME','LVL','SCORE']]
        file = open(self.file)
        data = json.load(file)
        for keys in data:
            obj = data[keys]
            line = [keys,obj['NAME'],obj['LVL'],obj['SCORE']]
            board.append(line)
        file.close()
        return board
    
    def init_offset(self):
        headers = self.board[0]
        offset:list[int] = []
        x_pos = 0
        for i in range(len(headers)):
            render_text = self.small_font.render(headers[i],True,"#F0EAD6")
            mid_pos = 143+render_text.get_width()
            offset.append(mid_pos+x_pos)
            x_pos += render_text.get_width() + 30

        return offset

    def lvl_comp(self,lvl,index):
        if lvl > self.board[index][2]:
            return index 
        else:
            return index + 1

    def search(self,score,lvl,i,j)-> int:
        score_index = 3
        mid = i + (j-i) // 2

        mid_score = self.board[mid][score_index]

        if mid_score == score:
            return self.lvl_comp(lvl,mid)

        if score > mid_score:
            j = mid - 1
        elif score < mid_score:
            i = mid + 1
        
        if i==j:
            if self.board[i][score_index] < score:
                return i 
            else:
                return i+1
        # if j==1:
        #     if  score == self.board[j][score_index]:
        #         return self.lvl_comp(lvl,j)
        #     elif score > self.board[j][score_index]:
        #         return j 
        #     else:
        #         return j+1
            
        return self.search(score,lvl,i,j)            

    def is_highscore(self,score):
        last = len(self.board) - 1
        if score >= self.board[last][3]:
            return True
        else:
            return False 

    def insert_name(self,name,index):
        self.board[index][1] = name

    def insert_highscore(self,score,lvl,name):
        index:int = self.search(score,lvl,1,self.size-1)
        print(index)
        old_name = self.board[index][1]
        old_level = self.board[index][2]
        old_score = self.board[index][3]
        self.board[index][1] = name 
        self.board[index][2] = lvl 
        self.board[index][3] = score

        for i in range(index+1,self.size):
            aux_name = self.board[i][1]
            aux_level = self.board[i][2]
            aux_score = self.board[i][3]
            self.board[i][1] = old_name
            self.board[i][2] = old_level 
            self.board[i][3] = old_score
            old_name = aux_name
            old_level = aux_level
            old_score = aux_score
        
        return index

    def small_screen_iddle_append(self):
        
        self.cur_list = []
        bg_clean = pygame.Surface.copy(self.images.surfaces['small_content_surface'])

        header = True
        aux = ''
        for i in range (self.cur_index):
            self.cur_list.append(self.board[i])
        
        cur_size = len(self.cur_list)
        render_start = 210-self.header_space-20*cur_size
        #print("render start init: ", render_start)
        if render_start < 0:
            render_start += self.header_space//2
            if render_start < 0:
                render_start += self.header_space //2
                header = False
            if render_start > 0:
                render_start = 0
        
        while render_start < 0:
            self.cur_list.pop(0)
            render_start += 20
            #print('render start while-loop: ',render_start)
            if render_start >= 0:
                render_start = 0
                #print('back to zero')

        if header:
            bg_clean.blit(self.header, (self.header_pos, render_start))
            render_start += self.header_space

        for i in range(len(self.cur_list)):
            #print(self.cur_list[i])
            for j in range(len(self.cur_list[i])):
                render_text = self.small_font.render(str(self.cur_list[i][j]),True,"#F0EAD6")
                bg_clean.blit(render_text,(self.offset[j]-render_text.get_width(),render_start))

            render_start += 20
        

        bg_clean.blit(self.images.surfaces['small_overlay_cut'],(0,0))
        self.images.screen.blit(bg_clean,self.images.pos['small_content_left_corner'])
        pygame.display.update(self.small_content_update_rect)
    
    def small_screen_iddle_pop(self):
        if self.cur_frame == 0:            
            bg_clean = pygame.Surface.copy(self.images.surfaces['small_content_surface'])
            self.cur_list.pop(0)
            render_start = 0

            for i in range(len(self.cur_list)):
                for j in range(len(self.cur_list[i])):
                    render_text = self.small_font.render(str(self.cur_list[i][j]),True,"#F0EAD6")
                    bg_clean.blit(render_text,(self.offset[j]-render_text.get_width(),render_start))
                render_start += 20

            bg_clean.blit(self.images.surfaces['small_overlay_cut'],(0,0))
            self.images.screen.blit(bg_clean,self.images.pos['small_content_left_corner'])
            pygame.display.update(self.small_content_update_rect)
    
    def small_screen_iddle(self):
        if self.cur_frame >=self.fps:
            self.cur_frame = 0

        if self.cur_frame == 0:
            if self.cur_index >= self.size:
                self.small_screen_iddle_pop()
                
                if(len(self.cur_list)) == 0:
                    self.cur_index = 0
            else:
                self.small_screen_iddle_append()
                self.cur_index +=1

        self.cur_frame += 1

    def update_json(self):
        f = open(self.file,'r')
        data = json.load(f)
        f.close()

        for i in range(1,len(self.board)):
            for j in range (1,len(self.board[i])):
                data[self.board[i][0]][self.json_keys[j]] = self.board[i][j]
        f = open(self.file, "w+")
        json.dump(data,f)
        f.close()

class Graphics:

    def __init__(self,stat_keys,stats_to_print,stats_to_print_2,graphic_components,images,sounds):
        self.stat_keys:list[str]= stat_keys
        self.stats_to_print:list[str] = stats_to_print
        self.stats_to_print_2:list[str] = stats_to_print_2
        self.images:ImageBin = images
        self.graphic_components:dict = graphic_components
        self.dungeon:Dungeon = Dungeon()
        self.big_content_update_rect = pygame.Rect(self.images.pos['big_content_left_corner'],self.images.pos['big_content_size'])
        self.big_monitor_fs_update_rect = pygame.Rect(self.images.pos['big_monitor_fs_left_corner'],self.images.pos['big_monitor_fs_size']) 
        self.small_content_update_rect = pygame.Rect(self.images.pos['small_content_left_corner'],self.images.pos['small_content_size']) 
        self.bg_surface = self.init_main_menu_graphics()
        self.messages = 'messages.txt'
        self.sound:Sound = sounds
        self.action_list = []
        self.action_list_max_size = 10
        self.msg_max_size = 60      #big screen can fit around 75-ish

    def render_text(self,text,size,color):
        return self.get_font(size).render(text,True,color)

    def get_font(self,size):  # Returns Press-Start-2P in the desired size
        return pygame.font.Font("assets/font.ttf", size)

    def output_text(self,text:str):
        msg_2:str = ""

        if len(text) > self.msg_max_size:
            ind = self.msg_max_size-1
            if text[ind] != ' ':
                for i in range(ind,0,-1):
                    if text[i] == ' ':
                        ind = i
                        break 
            
            msg_2 = text[ind+1:]
            text = text[:ind]

        free_space = self.action_list_max_size-len(self.action_list)

        if msg_2 != '': 
            if free_space<2:
                if free_space ==1:
                    self.action_list.pop(0)
                else:
                    self.action_list.pop(0)
                    self.action_list.pop(0)

            self.action_list.append(text)
            self.action_list.append(msg_2)
        else:
            if free_space == 0:
                self.action_list.pop(0)
            
            self.action_list.append(text)

        self.update_action_list()

    def update_message(self,msg,mode):
        terminal_font_m = self.get_font(17)
        msg_len = len(msg)
        strmsg = ''
        for i in range(0,msg_len):
            if msg[i] == 0:
                break
            strmsg += chr(msg[i])

        game_msg = terminal_font_m.render(strmsg, True, "#F0EAD6")
        f = open(self.messages, 'a')
        f.write(strmsg)
        f.write(str(msg))
        f.close()
        #50, 10
        if not mode:
            self.output_text(strmsg)
        self.sound.msg_sfx(strmsg)
        return game_msg

    #doesn't work
    def screen_toggle(self):
        if not self.default_display:
            self.default_display = 1
        else:
            self.default_display = 0
        #update display
        desktop_sizes = pygame.display.get_desktop_sizes()
        self.screen = pygame.display.set_mode((desktop_sizes[self.default_display][0], desktop_sizes[self.default_display][1]),pygame.RESIZABLE,display=self.default_display)
        pygame.display.update()

    def update_action_list(self):
            small_monitor = self.update_small_monitor()
            self.images.screen.blit(small_monitor,self.images.pos["small_content_left_corner"])
            pygame.display.update(self.small_content_update_rect)

    def update_small_monitor(self):

        bg_clean = pygame.Surface.copy(self.images.surfaces['small_content_surface'])

        font_text = self.get_font(10)

        for i in range(0,len(self.action_list)):
            render_text: pygame.Surface = font_text.render(self.action_list[i],True, "#F0EAD6")
            #render text
            bg_clean.blit(render_text, (0, 0+i*20))
        
        #apply overlay
        bg_clean.blit(self.images.surfaces["small_overlay_cut"],(0,0))

        return bg_clean

    def update_main_monitor(self,env,mode):
        
        terminal_font_s = self.get_font(15)

        #surface com o tamanho do monitor. blit o monitor apartir do canto esquerdo
        bg_clean = pygame.Surface.copy(self.images.surfaces["big_content_surface"])


        # print(env.unwrapped.last_observation)
        # for i in range(len(env.unwrapped.last_observation)):
        #     print(f'{i} - {env.unwrapped.last_observation[i]}')
        
        matrix = env.unwrapped.last_observation[0]      #glyph matrix
        msg = env.unwrapped.last_observation[5]         #message matrix
        stat_values = env.unwrapped.last_observation[4] #blstats
        internal = env.unwrapped.last_observation[15]
        #hunger = internal[7]
        hunger = internal[7]
        stat_values_s = map(str,stat_values)
        stat_dict = dict(zip(self.stat_keys, stat_values_s))
        
        if int(stat_dict['D#']) != 0:
            print("dungeon_num: ",stat_dict['D#'] )
            # for i in matrix:
            #     print(i)

        # print("---- STAT DICT ----")
        # for key in stat_dict:
        #     print(f'{key} - {stat_dict[key]}')
        
        hp_text = f'HP {stat_dict['hp']} ({stat_dict['maxhp']})'
        hp_bar_total_width = 240
        max_hp = int(stat_dict['maxhp'])
        hp = int(stat_dict['hp'])

        if hp !=0 :
            bar_width = hp*hp_bar_total_width//max_hp
            percentage = bar_width/hp_bar_total_width * 100
        else:
            bar_width = 0
            percentage = 0
        
        bar_colour = "#87d6a5"
        
        #stat_msg = 'HP:' + stat_dict['hp'] + '(' + stat_dict['maxhp'] + ')' + Lvl:' + stat_dict['explvl'] + ' Exp:' + stat_dict['exp'] + ' $:' + stat_dict['gold'] + ' Hunger: ' + str(hunger) + ' Dungeon #:' + stat_dict['dungeon_num']
        #240x15 87d6a5
        
        if percentage >= 85:
            bar_colour = "#87d696"
        elif percentage >= 70:
            bar_colour = "#88d687"
        elif percentage >= 60:
            bar_colour ="#88d33c"
        elif percentage >= 50:
            bar_colour ="#ecf52c"
        elif percentage >= 40:
            bar_colour ="#f5e02c"
        elif percentage >= 30:
            bar_colour ="#f5ca2c"
        elif percentage >= 20:
            bar_colour ="#f5a02c"
        elif percentage >= 10:
            bar_colour ="#f56f2c"
        else:
            bar_colour ="#f54d2c"

        stat_msg_2 = 'Neutral '
        stat_msg = ' PW:' + stat_dict['energy'] + '(' + stat_dict['maxenergy'] + ') '
        
        for key in self.stats_to_print:
            stat_msg += key + ':' + stat_dict[key] + ' '

        stat_msg += ' Hunger: ' + str(hunger)

        for key in self.stats_to_print_2:
            stat_msg_2 += key + ':' + stat_dict[key] + ' '

        bar = pygame.Surface((bar_width,15))
        bar.fill(bar_colour)
        bar_limit = terminal_font_s.render('|',True, bar_colour)
        hp_text_render = terminal_font_s.render(hp_text,True, "#F0EAD6")
        render_stat_msg = terminal_font_s.render(stat_msg,True, "#F0EAD6")
        render_stat_msg2 = terminal_font_s.render(stat_msg_2,True, "#F0EAD6")

        dungeon_surface = self.dungeon.draw_dungeon(matrix,int(stat_dict['D#']))

        #435 H - 336 dungeon + 15 de cada stat + 5 entre as stats + 20 da mensagem + 20 da mensagem ate à dungeon + 5 da beira do ecra em cima + 5 da beira do ecra em baixo
        #+120 +190 (190-98)
        dungeon_pos = (0,60)
        bg_clean.blit(dungeon_surface, dungeon_pos) #30px da msg (20 font size + 10 de margem) acaba nos 226
        
        if msg[0] != 0:
            game_msg = self.update_message(msg,mode)
            bg_clean.blit(game_msg,(dungeon_pos[0],dungeon_pos[1]-40)) #starts same place as dungeon, Y -40
        

        #HP BAR shananigans
        mid_point = hp_bar_total_width//2 -65
        bg_clean.blit(bar_limit,(dungeon_pos[0], dungeon_pos[1]+356))
        bg_clean.blit(bar_limit,(dungeon_pos[0]+hp_bar_total_width, dungeon_pos[1]+356))
        bg_clean.blit(bar,(dungeon_pos[0], dungeon_pos[1]+356))
        bg_clean.blit(hp_text_render,(dungeon_pos[0]+mid_point, dungeon_pos[1]+356))
        
        bg_clean.blit(render_stat_msg, (dungeon_pos[0]+hp_bar_total_width, dungeon_pos[1]+356)) #starts same place as dungeon, Y +396
        bg_clean.blit(render_stat_msg2, (dungeon_pos[0], dungeon_pos[1]+376)) #starts same place as dungeon, Y +416

        #apply overlay
        bg_clean.blit(self.images.surfaces["big_overlay_cut"],(0,0))

        return bg_clean

    def update_graphics(self,env,mode):

        big_monitor = self.update_main_monitor(env,mode)
        
        if len(self.action_list)>=1:
            small_monitor = self.update_small_monitor()
            self.images.screen.blit(small_monitor,self.images.pos["small_content_left_corner"])
        
        self.images.screen.blit(big_monitor, self.images.pos["big_content_left_corner"])
        pygame.display.update([self.big_content_update_rect,self.small_content_update_rect])

    def game_over_screen(self):

        #clean monitor surface
        bg_clean = pygame.Surface.copy(self.images.surfaces['big_monitor_fs_surface'])

        #insert game over assets between monitor layers
        #play again text
        bg_clean.blit(self.images.images['play_again'],self.images.pos['play_again_pos'])

        #blit overlay cut
        bg_clean.blit(self.images.surfaces["big_overlay_cut_fs"],(0,0))

        #blit onto screen
        self.images.screen.blit(bg_clean,self.images.pos["big_content_left_corner"])
        
        #update
        pygame.display.update(self.big_monitor_fs_update_rect)

    def init_main_menu_graphics(self):
        #background image
        bg_surface = pygame.Surface((self.images.screen_w, self.images.screen_h),pygame.SRCALPHA)
        bg_surface.blit(self.images.images["bg"], (0, 0)) 
        
        #monitor overlay
        bg_surface.blit(self.images.images['monitor_overlay'], self.images.pos['big_monitor_left_corner'])


        #draw joystick
        bg_surface.blit(self.graphic_components['joystick_default'],self.graphic_components['joystick_pos'])
        
        #draw buttons
        for i in range(len(self.graphic_components['button_pos'])):
            for j in range(len(self.graphic_components['button_pos'][0])):
                bg_surface.blit(self.graphic_components['button_default'],self.graphic_components['button_pos'][i][j])
        
        #small monitor overlay
        bg_surface.blit(self.images.images['small_monitor_overlay'],self.images.pos['small_monitor_left_corner'])
        
        #draw everything on screen
        self.images.screen.blit(bg_surface, (0, 0))
        
        #update
        pygame.display.flip()
        return bg_surface

    def background_anim(self,menu:MenuVertical|MenuHorizontal,bg_anim:spritesheet.Animation,top_layer):
        animated_assets = []
        key_1_obj = (menu.prev_key,menu.prev_key_pos)
        key_2_obj =(menu.cur_key,menu.cur_key_pos)
        animated_assets = [key_1_obj,key_2_obj] #deleted obj out 
        
        if type(menu) == MenuVertical:
            inner_anim = self.images.animations['arrow'].inner_animation()
            obj =(inner_anim,menu.cur_cursor_pos)
            animated_assets.append(obj)
        
        all_assets = menu.assets + animated_assets
        
        if bg_anim.filename == "assets/menu_bg_anim.png":
            all_assets += [(self.images.images['nle_logo_menu'],self.images.pos['menu_text'])]

        
        #make something to handle having all the screen assets in one tuple list
        bg_anim.loop_animate(self.images.surfaces['big_monitor_fs_surface'],all_assets,top_layer,self.images.pos['big_monitor_fs_left_corner'],self.big_monitor_fs_update_rect,self.images.screen)

class Game:
    def __init__(self):
        pygame.init()
        self.data_file = 'data.json'
        self.images, self.controller,  self.graphics  , self.sound = self.load_data()
        self.env = self.env_init()
        self.clock = pygame.time.Clock()
        self.board = Leaderboard(self.images,self.graphics.small_content_update_rect)
        pygame.display.set_caption("NetHack Prolog Agent")
        pygame.display.set_icon(self.images.images['icon'])
        self.score = 0
        self.main_menu()

    def load_data(self):
        file = open(self.data_file)
        data = json.load(file)
        sound = Sound(data["sound"])
        images = ImageBin(data["positioning"],data["images"],data["surfaces"],data["animations"])
        controller = ControllerSet(data["action_map"],data["controller_sets"],images)
        graphics = self.init_graphics(controller,images,data["stat_keys"],data["stats_to_print"], data["stats_to_print_2"],sound)
        
        return images, controller, graphics, sound

    def init_graphics(self,controller,images,stat_keys,stats_to_print,stats_to_print_2,sound):


        graphic_assets = { 'joystick_default':controller.controller_set['joystick'].default_state,
                                            'joystick_pos': controller.controller_set['joystick'].pos,
                                            'button_default': controller.controller_set['buttons'].default_state,
                                            'button_pos'  : controller.controller_set['buttons'].button_pos}
        
        return Graphics(stat_keys,stats_to_print,stats_to_print_2,graphic_assets,images,sound)

    def display_inv(self):
        
        inv_strs = self.env.unwrapped.last_observation[7]       #type: ignore
        inv_letters = self.env.unwrapped.last_observation[8]    #type: ignore

        for letter, line in zip(inv_letters, inv_strs):
            if np.all(line == 0):
                break
            print(letter.tobytes().decode("utf-8"), line.tobytes().decode("utf-8"))

    def env_init(self):
        #max episode steps defaults to 5000
        
        move_cardinal = tuple(nethack.CompassCardinalDirection)
        move_intercardinal = tuple(nethack.CompassIntercardinalDirection)
        misc = tuple(nethack.MiscAction)
        misc_direction = tuple(nethack.MiscDirection)
        navigate_actions = misc + move_cardinal + move_intercardinal + misc_direction + (
        nethack.Command.OPEN,
        nethack.Command.KICK,
        nethack.Command.SEARCH,     # search for traps and secret doors     -- success is affected by players dicovery stat (Int or Wis ?)
        nethack.Command.EAT,        # eat something
        nethack.Command.ESC,        # escape from the current query/action
        nethack.Command.INVENTORY,  # kick something
        nethack.Command.QUAFF,      # quaff (drink) something
        nethack.Command.PICKUP,
        nethack.Command.APPLY,       
        nethack.Command.CAST,      
        nethack.Command.CLOSE,     
        nethack.Command.DROP ,       
        nethack.Command.FIRE ,       
        nethack.Command.MOVE ,       
        nethack.Command.PAY  ,       
        nethack.Command.PUTON   ,    
        nethack.Command.READ    ,    
        nethack.Command.REMOVE  ,    
        nethack.Command.RUSH    ,    
        nethack.Command.SWAP    ,    
        nethack.Command.TAKEOFF ,    
        nethack.Command.TAKEOFFALL  ,
        nethack.Command.THROW       ,
        nethack.Command.TWOWEAPON   ,
        nethack.Command.VERSIONSHORT,
        nethack.Command.WEAR        ,
        nethack.Command.WIELD       ,
        nethack.Command.ZAP         ,
        nethack.Command.LOOT        ,
        nethack.Command.ADJUST  ,
        nethack.Command.ANNOTATE,
        nethack.Command.CHAT    ,
        nethack.Command.FORCE   ,
        nethack.Command.PRAY    ,
        nethack.Command.QUIT    ,
        nethack.Command.RUB     ,
        nethack.Command.TURN    ,
        nethack.Command.UNTRAP  ,
        nethack.Command.OFFER   ,
        nethack.Command.LOOK,
        nethack.Command.CONDUCT,
        nethack.Command.HISTORY,
        nethack.Command.OVERVIEW
        )
        #"NetHackScore-v0"
        #NetHackGold
        #possible env: 
        #    "NetHack",
        # "NetHackScore",
        # "NetHackStaircase",
        # "NetHackStaircasePet",
        # "NetHackOracle",
        # "NetHackGold",
        # "NetHackEat",
        # "NetHackScout",
        # "NetHackChallenge", actions=navigate_actions
        env = gym.make("NetHackScore-v0", actions=navigate_actions,allow_all_yn_questions=True)
        #env.print_action_meanings()´

        env.reset()
        return env

    def init_prolog(self):
        pygame.display.set_caption("Nethack: Prolog Agent")
        self.init_prolog_game()
        janus.query_once("main:main_start(ENV,GAME).",{'ENV':self.env,"GAME":self})
        self.game_over()

    def init_prolog_game(self):
        self.graphics.update_action_list()
        self.graphics.update_graphics(self.env,1)
        self.sound.files['game'].play(-1,fade_ms=5000)

    def prolog_move(self,key_name):
        self.clock.tick(60)

        if key_name in self.controller.keys:
            if self.controller.keys[key_name].has_graphics:
            
                #fazer um getter para isto, já agora, é por isto que estava a andar 2 vezes pro lado
                controller_type: Joystick | Keypad | MenuVertical = self.controller.get_controller_type(key_name)            #controller.joystick or controller.keypad
                
                step_res = controller_type.press_key(self.env,key_name,self.clock,1)
                self.graphics.update_graphics(self.env,1)
            else:
                step_res = self.env.step(self.controller.keys[key_name].nle_move) #type: ignore
            
            if step_res[0]['blstats'][9] > self.score:  #type: ignore
                self.score =  int(step_res[0]['blstats'][9])  #type: ignore
            
            if step_res[2]: #type: ignore
                return False

        if self.controller.controller_set['joystick'].is_pressed:
            self.sound.key_sounds[key_name].play()
            self.controller.controller_set['joystick'].release_key(self.clock)

        if self.controller.controller_set['buttons'].is_pressed:
            pygame.time.wait(100)
            self.sound.files['button'].play()
            self.controller.controller_set['buttons'].release_key(self.clock)
        
        
        return step_res

    def choose_action(self,action):
        if not action:
            #turn of sound
            self.sound.files['shutdown'].play()
            self.quit_game()
        else:
            self.start_game(action)

    def start_game(self,action):
        self.env = self.env_init()
        self.score = 0
        if action==1:
            self.play_game()
        else:
            self.init_prolog()
        
        self.sound.files['game'].fadeout(1000)
        
        lvl = int(self.env.unwrapped.last_observation[15][0]) #type: ignore
        #score,lvl = self.get_final_stats()
        
        if self.board.is_highscore(self.score):
            if action == 1:
                self.highscore(self.score,lvl)
            else:
                self.board.insert_highscore(self.score,lvl,'PLG')

        #debug to see if game really ended
        pygame.time.wait(1000)
        self.game_over()

    def quit_game(self):
        pygame.quit()
        sys.exit()

    def menu_screen_behaviour(self,animation,menu:MenuVertical|MenuHorizontal,top_layer,action,action_trigger,action_ticks,running,selection):

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
                break
            if event.type == pygame.VIDEORESIZE:
                self.graphics.screen = pygame.display.set_mode((event.w, event.h),pygame.RESIZABLE,display=0)
                self.images.screen.blit(self.graphics.bg_surface, (0, 0))
                pygame.display.update()
            
            if event.type == pygame.VIDEOEXPOSE:
                self.images.screen.blit(self.graphics.bg_surface, (0, 0))
                pygame.display.update()

            if event.type == pygame.KEYDOWN:
                key_name = pygame.key.name(event.key)

                match event.key:
                    case pygame.K_ESCAPE:
                        running = False
                        break
                    case pygame.K_BACKSLASH:
                        pygame.display.toggle_fullscreen()
                        break
                    case pygame.K_SPACE:
                        self.controller.controller_set['special'].press_key_loop(key_name)
                        #sound here
                    case pygame.K_RETURN:
                        self.sound.files['sellect'].play()
                        if not selection:
                            if not menu.who_is_pressed:
                                    menu = self.controller.controller_set['pick_agent_menu']
                                    selection = True
                                    break
                            else:
                                self.sound.files['main_menu'].fadeout(7000)
                                animation.set_fade_out(animation.fade_surface,True)
                                action_trigger = True 
                                action = 0
                                break
                        else:
                            self.sound.files['coin'].play().set_volume(1.0)
                            self.sound.files['main_menu'].fadeout(7000)
                            animation.set_fade_out(animation.fade_surface,True)
                            action_trigger = True 
                            if not menu.who_is_pressed:
                                action = 1
                                break
                            else:
                                action = 2
                                break
                                
                if type(menu) == MenuHorizontal:
                    if event.key == pygame.K_KP_4 or event.key == pygame.K_LEFT:
                        menu.toggle_key(1)
                        self.sound.files['hover'].play()
                    elif event.key == pygame.K_KP_6 or event.key == pygame.K_RIGHT:
                        menu.toggle_key(-1)
                        self.sound.files['hover'].play()
                
                else:
                    if event.key == pygame.K_KP_2 or event.key == pygame.K_DOWN:
                        menu.toggle_key(1)
                        self.sound.files['hover'].play()
                    elif event.key == pygame.K_KP_8 or event.key == pygame.K_UP:
                        menu.toggle_key(-1)
                        self.sound.files['hover'].play()

                if key_name in self.controller.controller_set['joystick'].key_dict:
                    if self.controller.keys[key_name].has_graphics:
                        self.controller.controller_set['joystick'].press_key_loop(key_name)
        
        #OUTSIDE OF EVENT LOOP -> handle kept states and updates
        
        #animated elements        
        self.graphics.background_anim(menu,animation,top_layer)
        self.board.small_screen_iddle()
        self.controller.controller_set['special'].loop_animation()
        self.controller.controller_set['joystick'].loop_animation()

        if self.controller.controller_set['joystick'].is_pressed:
            
            pressed = pygame.key.get_pressed()
            if not pressed[pygame.key.key_code(self.controller.controller_set['joystick'].key_pressed)]:
                #comment this line for agent
                self.controller.controller_set['joystick'].release_key_loop()
        
        if self.controller.controller_set['special'].is_pressed:
            pressed = pygame.key.get_pressed()
            if not pressed[pygame.key.key_code(self.controller.controller_set['special'].key_pressed)]:
                self.controller.controller_set['special'].release_key_loop()
                self.sound.files['drop_coins'].stop()
                self.sound.files['drop_coin'].play()
            
            self.sound.files['drop_coin'].stop()
            self.sound.files['drop_coins'].stop()
            self.sound.files['drop_coins'].play()

        if action_trigger:
            if action_ticks >0:
                action_ticks-=1
            else:
                running = False
        
        return action,action_trigger,action_ticks,running,selection,menu

    def get_end_reason(self):
        text = "You "
        end_reason:nle._pynethack.nethack.game_end_types = self.env.unwrapped.nethack.how_done() #type:ignore
        match (end_reason.value):
            case 0:
                text += 'died.'
            case 1: 
                text += 'choked.'
            case 2: 
                text += 'were poisened.'
            case 3: 
                text += 'starved.'
            case 4: 
                text += 'drowned.'
            case 5: 
                text += 'burned.'
            case 6: 
                text += 'dissolved.'
            case 7: 
                text += 'were crushed.'
            case 8: 
                text += 'were stonned.'
            case 9: 
                text += 'were turned into slime.'
            case 10:
                text += 'were genocided.'
            case 11: 
                text += 'panicked.'
            case 12: 
                text += 'were tricked.'
            case 13: 
                text += 'quit.'
            case 14: 
                text += 'escaped.'
            case 15:
                text += 'Ascended.'
        rect = self.images.surfaces['big_monitor_fs_surface'].get_rect()
        x,y = rect.center
        txt_surface = self.graphics.render_text(text,20,"#F8F8FF")
        w = txt_surface.get_width()
        h = txt_surface.get_height()
        posx = x-w 
        posy = y-h

        return txt_surface,(posx+90,posy+20)   
    
    def highscore(self,score,lvl):
        self.sound.files['highscore'].play()
        index = self.board.insert_highscore(score,lvl,'')

        #render as cenas do ecrã
        name = ''
        name_pos = (518,310)
        rank = self.graphics.render_text(self.board.board[index][0],30,"#F8F8FF")
        lvl_txt =  self.graphics.render_text(str(lvl),30,"#F8F8FF")
        score_txt = self.graphics.render_text(str(score),30,"#F8F8FF")
        name_txt = self.graphics.render_text('',30,"#F8F8FF")
        text_list = [(rank,(293,310)),(lvl_txt,(744,310)),(score_txt,(893,310)),(name_txt,name_pos)]
        cursor = self.graphics.render_text("_",30,"#F8F8FF")
        cursor_pos = (name_pos[0] + name_txt.get_width(),name_pos[1]+10)
        cursor_list =  [(cursor,cursor_pos)]
        assets = self.board.assets + text_list
        top_layer = (self.images.surfaces['big_overlay_cut_fs'],(0,0))
        running = True
        self.board.bg_anim.set_fps(60)
        inserted = True

        while running:
            self.clock.tick(60)
            for event in pygame.event.get():
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_ESCAPE:
                            running = False 
                            break
                    if event.key == pygame.K_RETURN:
                        if name == 'PLG':
                            #tell player to choose another name
                            self.sound.files['wrong'].play()
                        else:
                            self.sound.files['sellect'].play()
                            running = False
                    elif event.key == pygame.K_BACKSPACE:
                        name = name[:-1]
                    else:
                        if len(name) == 3:
                            self.sound.files['wrong'].play()
                            if inserted:
                                cursor_list = []
                                inserted = False
                        else:
                            name += event.unicode.upper()
            
            assets.pop()
            name_txt = self.graphics.render_text(name,30,"#F8F8FF")
            assets.append((name_txt,name_pos))
            cursor_pos = (name_pos[0] + name_txt.get_width(),name_pos[1]+10)

            if len(name)<3:
                cursor_list = [(cursor,cursor_pos)]
                inserted = True
            else:
                if inserted:
                    cursor_list = []
                    inserted = False

            #no idea why this isn't working - can't make it blink/toggle
            # if len(name) < 3:
            #     if inserted:
            #         cursor_list = []
            #         inserted = False
            #     else: 
            #         cursor_list = [(cursor,cursor_pos)]
            #         inserted = True
            # else:
            #     if inserted:
            #         cursor_list = []
            #         inserted = False

            self.board.bg_anim.loop_animate(self.images.surfaces['big_monitor_fs_surface'],cursor_list + assets,top_layer,self.images.pos['big_monitor_fs_left_corner'],self.graphics.big_monitor_fs_update_rect,self.images.screen)
            self.board.small_screen_iddle()
            self.controller.controller_set['special'].loop_animation()
        
        self.board.insert_name(name,index)
        self.board.update_json()

    def game_over(self):        
        self.controller.controller_set['special'].set_iddle('space')
        self.sound.files['game_over'].play(fade_ms=1000).set_volume(0.5)
        self.graphics.game_over_screen()
        #get reason for game_over
        #end_reason:nle= self.env.unwrapped.nethack.how_done() #type: ignore
        # "play_again_pos": [437,259],
        end_reason = self.get_end_reason()
        #txt_surface = self.graphics.render_text(txt,20,"#F0EAD6")
        
        #assets = [(self.images.images['play_again'],(0,0)),(txt_surface,(0,100))]
        animation = self.images.animations['game_over_bg']
        animation.set_fade_out(animation.fade_surface,False)
        animation.set_fade_in(animation.fade_surface,True)
        top_layer = (self.images.surfaces['big_overlay_cut_fs'],(0,0))
        running = True 
        menu = self.controller.controller_set['end_menu']

        menu.assets.append(end_reason)
        action_trigger = False
        action_ticks = 380
        action = 0
        selection = False
        #self.env.reset() #type: ignore
        while running:
            self.clock.tick(60)
            action, action_trigger, action_ticks, running, selection,menu = self.menu_screen_behaviour(animation,menu,top_layer,action,action_trigger,action_ticks,running,selection)

        self.choose_action(action)
    
    def play_game(self):
        self.sound.files['game'].play(-1,fade_ms=3000)
        running = True

        self.graphics.update_graphics(self.env,0)
        #clear graphics
        self.graphics.update_small_monitor()
        
        while running:
            self.clock.tick(60)

            for event in pygame.event.get():

                if event.type == pygame.QUIT:
                    self.quit_game()
                    break
                if event.type == pygame.VIDEORESIZE:
                    self.images.screen.blit(self.graphics.bg_surface, (0, 0))
                    pygame.display.update()
                if event.type == pygame.VIDEOEXPOSE:
                    self.images.screen.blit(self.graphics.bg_surface, (0, 0))
                    pygame.display.update()

                if event.type == pygame.KEYDOWN:
                    key_name = pygame.key.name(event.key)
                    
                    if event.mod & pygame.KMOD_SHIFT:
                        key_name = key_name.upper()
                    
                    if event.mod & pygame.KMOD_CTRL:
                        key_name = 'ctrl+' + key_name

                    match event.key:
                        case pygame.K_ESCAPE:
                            running = False 
                            break
                            #pass
                        case pygame.K_BACKSLASH:
                            pygame.display.toggle_fullscreen()
                            
                        case pygame.K_1:
                            self.graphics.screen_toggle()
                            
                        case pygame.K_i:
                            self.display_inv()

                    if key_name in self.controller.keys:
                        #print("score before: ")
                        if self.controller.keys[key_name].has_graphics:
                        
                            #fazer um getter para isto, já agora, é por isto que estava a andar 2 vezes pro lado
                            controller_type: Joystick | Keypad | MenuVertical = self.controller.get_controller_type(key_name)            #controller.joystick or controller.keypad
                            
                            obs:tuple = controller_type.press_key(self.env,key_name,self.clock,0)
                        else:
                            obs:tuple = self.env.step(self.controller.keys[key_name].nle_move)  #type: ignore

                        self.graphics.update_graphics(self.env,0)
                        if obs[0]['blstats'][9] > self.score:           
                            self.score =  int(obs[0]['blstats'][9])      
                        
                        if obs[2] == running:   
                            running = False
                            break
                        # if self.env.unwrapped.last_observation[14][0] == running: # type: ignore
                        #     running = False 
                        #     #pygame.mixer.music.fadeout(1000)
                        #     #self.sound.files['game_over'].play()
                        #     break

            #OUTSIDE OF EVENT LOOP -> handle kept states and updates
            if self.controller.controller_set['joystick'].is_pressed:
                
                pressed = pygame.key.get_pressed()
                if pressed[pygame.key.key_code(self.controller.controller_set['joystick'].key_pressed)]:
                    pass
                    #comment this line for agent
                    #self.env.step(self.controller.controller_set['joystick'].key_dict[self.controller.controller_set['joystick'].key_pressed].nle_move) #type: ignore
                    #self.graphics.update_graphics(self.env,0)
                else:
                    self.controller.controller_set['joystick'].release_key(self.clock)
                
                # if self.env.unwrapped.last_observation[14][0] == running: # type: ignore
                #     running = False
                #     break

            if self.controller.controller_set['buttons'].is_pressed:
                pressed = pygame.key.get_pressed()
                if not pressed[pygame.key.key_code(self.controller.controller_set['buttons'].key_pressed)]:
                    pygame.time.wait(100)

                    self.controller.controller_set['buttons'].release_key(self.clock)

    def main_menu(self):
        
        #main_menu_assets = [(self.images.images['nle_logo_menu'],self.images.pos['menu_text'])]
        menu = self.controller.controller_set['menu']
        bg_anim = self.images.animations["main_menu_bg"]
        top_layer = (self.images.surfaces['big_overlay_cut_fs'],(0,0))
        action_trigger:bool = False 
        action_ticks:int = 380
        action = 0
        running:bool = True
        selection = False
        self.controller.controller_set['special'].set_iddle('space')
        #sound
        self.sound.files['main_menu'].play(-1,fade_ms=7000).set_volume(0.4)

        while running:
            self.clock.tick(60)
            action, action_trigger,action_ticks,running,selection,menu = self.menu_screen_behaviour(bg_anim,menu,top_layer,action,action_trigger,action_ticks,running,selection)

        self.choose_action(action)

# indicador das keys para os botões
# overlay togle para ver as keys/acções
# hp bar

# ver reinforcement learning - dig tá a ver
# arranjar o prolog todo lol
#   - é preciso ver que a fome tá num sitio diferente daquele que inicialmente esperado. usar o mesmo que ta a ser usado no interface
#   - as diagonais estão só a ser realizadas dentro de corredores, de tile de chão de corredor para tile de chão de corredor
#   - não está a empurrar boulders, boulders não estão na valid list.
# added reason for game_over to game_over screen - it's returning: game_end_types.DIED
# portas: 1 abre, 2 entra na porta
# door resists: é ir contra a porta até abri.
# só door locked é que precisa de kick

if __name__ == '__main__':
    Game()