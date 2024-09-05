import nle.env
import nle.env.tasks
import pygame, sys
import numpy as np
import spritesheet
import nle
import nle.nethack as nethack
import json
import janus_swi as janus
import random
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
            "As you kick the door" : self.files['kick'],
            "WHAM" : self.files['kick_hard'],
            "$": self.files['collect_coin'],
            "hits!": self.files['take_bump'],
            "kill": self.files['monster_death'],
            "destroy": self.files['monster_death'],
            "gurgling": self.files["fountain"]
        }

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
                if keys == 'fountain':
                    self.msg_sounds[keys].play(maxtime=3000)
                else:    
                    self.msg_sounds[keys].play()
                    break

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
            anim_dict[key] = spritesheet.Animation(key_dict["file"],key_dict["frame_width"],key_dict["is_full_strip"],key_dict["is_mirrored"])
            
            if key_dict['init_fade_in']:
                surface_key = key_dict["fade_in_surface"]
                anim_dict[key].set_fade_in(self.surfaces[surface_key])
            
            if key_dict['init_fade_out']:
                surface_key = key_dict["fade_out_surface"]
                anim_dict[key].set_fade_out(self.surfaces[surface_key])

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
        self.anim_ss = spritesheet.Animation(dict["file"],dict["frame_size"],dict["is_full_strip"],dict["is_mirrored"]) 

class Buttons(Keys):
    def __init__(self, dict):
        super().__init__(dict)
        self.pos = (0,0)     #placeholder
        #self.update_rect = pygame.Rect((0,0,1,1))           #placeholder
        #self.bg_clean = pygame.Surface((0,0))               #placeholder

class Special(Directional,Buttons):
    def __init__(self, dict):
        super().__init__(dict)

#Keyset of animated keys of same type

class Joypad:
    def __init__(self,key_dict,w,h,images):
        self.key_dict:dict[str,Buttons]|dict[str,Directional] = key_dict
        self.is_pressed = False
        self.key_pressed:str = ''
        self.w_refresh:int = w
        self.h_refresh:int = h
        self.images:ImageBin = images

    def animation(self,anim_array:list[pygame.Surface],clock,base_pos:tuple[int,int],update_rect:pygame.Rect,bg_clean:pygame.Surface):

        size = len(anim_array)
        #base_pos = self.key_dict[self.key_pressed].pos
        #get the clean bg bit from the bg image
        #update_rect = pygame.Rect(base_pos[0],base_pos[1],self.w_refresh,self.h_refresh)
        #bg_clean = pygame.Surface([update_rect.width, update_rect.height], pygame.SRCALPHA)
        #bg_clean.blit(self.images.images['bg'], (0, 0), update_rect)
        #local_clock = pygame.time.Clock()
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
        
    def press_key(self,env,key,clock):
        pass

    def release_key(self,clock):
        pass

#The joypads still have hardcoded sprites and probably other things
class Joystick(Joypad):

    def __init__(self,key_dict:dict[str,Directional],images:ImageBin,pos,w_joystick_anim,h_joystick_anim):
        super().__init__(key_dict,w_joystick_anim,h_joystick_anim,images)
        self.pos:tuple[int,int] = pos
        self.key_dict = key_dict
        self.default_state = self.init_default()
        #clean surface
        print(self.pos)
        print((w_joystick_anim,h_joystick_anim))
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
        #self.sound = pygame.mixer.Sound( "assets/Sound/joystick.mp3")
        self.iddle = False 
        self.iddle_key = ''
        
    def init_default(self):
        key = list(self.key_dict.keys())[0]
        return self.key_dict[key].anim_ss.default_frame #type: ignore
    
    #not sure if this will work in the long wrong and is uneeded anyway
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

    def press_key_no_action(self,key,clock,bg_surface,screen):
        #for agent: let env.step should be performed here -- no need for checking if pressed though
        if self.is_pressed:
            if key != self.key_pressed:
                self.release_key(clock)
                self.animation(self.key_dict[key].anim_ss.anim_press,clock,bg_surface,self.pos,screen) # type: ignore
        else: 
            self.animation(self.key_dict[key].anim_ss.anim_press,clock,bg_surface,self.pos,screen) # type: ignore
        
        #env.step(self.key_dict[key].nle_move)
        self.is_pressed = True 
        self.key_pressed = key

    def press_key(self,env,key,clock):
        #for agent: let env.step should be performed here -- no need for checking if pressed though
        step_res = env.step(self.key_dict[key].nle_move)

        # if self.is_pressed:
        #     if key != self.key_pressed:
        #         self.release_key(clock)
        #         self.animation(self.key_dict[key].anim_ss.anim_press,clock,self.pos,self.update_rect,self.bg_clean) # type: ignore
        # else: 
        self.animation(self.key_dict[key].anim_ss.anim_press,clock,self.pos,self.update_rect,self.bg_clean) # type: ignore
        #env.step(self.key_dict[key].nle_move)
        self.is_pressed = True 
        self.key_pressed = key
        #return env
        return step_res

    def release_key(self,clock):
        if self.is_pressed:
            self.is_pressed = False
            self.animation(self.key_dict[self.key_pressed].anim_ss.anim_release,clock,self.pos,self.update_rect,self.bg_clean) # type: ignore
            return True
        else:
            return False

class Keypad(Joypad):

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

    def press_key(self,env,key,clock):
        #change this for only 1 input at a time for agent (no pressing)
        #if self.is_pressed:
        if key != self.key_pressed:
            if self.is_pressed:
                self.release_key(clock)
            else:
                self.animation(self.anim.anim_press,clock,self.key_dict[key].pos,self.key_dict[key].update_rect,self.key_dict[key].bg_clean) # type: ignore
                step_res = env.step(self.key_dict[key].nle_move)
                self.is_pressed = True
                self.key_pressed = key
        
        print("pressed key"+key)
        return step_res

    def release_key(self,clock):
        if self.is_pressed:
            self.animation(self.anim.anim_release,clock,self.key_dict[self.key_pressed].pos,self.key_dict[self.key_pressed].update_rect,self.key_dict[self.key_pressed].bg_clean) # type: ignore
            print("Released key " + self.key_pressed)
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

        BUTTON_KEYS = ['k','e','s','q','up','down']
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

class MenuVertical(Joypad):
        
        def __init__(self,key_dict:dict[str,Directional],images:ImageBin,button_base,button_width,button_height):
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
        def __init__(self,key_dict:dict[str,Directional],images:ImageBin,button_base,button_width,button_height):
            super().__init__(key_dict,button_width,button_height,images)
            self.button_base = button_base
            self.button_pos = self.button_layout()
            self.who_is_pressed = 0
            self.menu_len = len(self.button_pos)
            self.key_list = self.init_buttons()
            self.cur_key = self.key_dict['yes'].anim_ss.anim_press[0] #type: ignore
            self.cur_key_pos:tuple[int,int] = self.button_pos[0] 
            self.prev_key = self.key_dict['no'].anim_ss.anim_release[0] #type: ignore
            self.prev_key_pos:tuple[int,int] = self.button_pos[1]

        def button_layout(self):
            button_pos:list[tuple[int,int]] = []
            #hardcoded needs to be changed
            #+40 + 35
            for i in range(2):
                button_pos.append((self.button_base[0]+i*200,self.button_base[1]))
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

    def __init__(self,keys_dict,controller_dict,images:ImageBin):
        self.keys:dict[str,Keys] = {}
        self.key_type_map = [Keys,Directional,Buttons,Special]
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

                            if n>= 2360 and n<=2370 and dungeon_num == 2:
                                n -= 2360
                                n+= 1038
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

#missing functions to add to leaderboard
class Leaderboard:
    def __init__(self,images,small_content_update_rect) -> None:
        self.cur_frame = 0
        self.cur_index = 0
        self.fps = 60
        self.cur_list = []
        self.small_font = pygame.font.Font("assets/font.ttf", 15)
        self.header = pygame.font.Font("assets/font.ttf", 30).render('High Scores',True, "#ff742f")
        self.header_space = 30+10 #45
        self.header_pos = 308- self.header.get_rect().centerx
        self.board = self.init_leaderboard()
        self.images = images
        self.size = len(self.board)
        self.small_content_update_rect = small_content_update_rect

    def init_leaderboard(self) -> list[str]:
        board = []
        f = open('leaderboard.txt')
        for line in f:
            board.append(line[:-1])
        
        f.close()
        return board

    def small_screen_iddle_append(self):
        
        self.cur_list = []
        bg_clean = pygame.Surface.copy(self.images.surfaces['small_content_surface'])

        header = True
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
            render_text = self.small_font.render(self.cur_list[i],True,"#F0EAD6")
            mid_pos = 308- render_text.get_rect().centerx
            bg_clean.blit(render_text,(mid_pos,render_start))
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
                #print(self.cur_list[i])
                render_text = self.small_font.render(self.cur_list[i],True,"#F0EAD6")
                mid_pos = 308-render_text.get_rect().centerx
                bg_clean.blit(render_text,(mid_pos,render_start))
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

class Graphics:

    def __init__(self,stat_keys,stats_to_print,graphic_components,images,sounds):
        self.stat_keys:list[str]= stat_keys
        self.stats_to_print:list[str] = stats_to_print
        self.images:ImageBin = images
        self.graphic_components:dict = graphic_components
        self.dungeon:Dungeon = Dungeon()
        self.big_content_update_rect = pygame.Rect(self.images.pos['big_content_left_corner'],self.images.pos['big_content_size'])
        self.big_monitor_fs_update_rect = pygame.Rect(self.images.pos['big_monitor_fs_left_corner'],self.images.pos['big_monitor_fs_size']) 
        self.small_content_update_rect = pygame.Rect(self.images.pos['small_content_left_corner'],self.images.pos['small_content_size']) 
        self.bg_surface = self.init_main_menu_graphics()
        self.messages = 'messages.txt'
        self.sound:Sound = sounds

    def render_text(self,text,size,color):
        return self.get_font(size).render(text,True,color)

    def get_font(self,size):  # Returns Press-Start-2P in the desired size
        return pygame.font.Font("assets/font.ttf", size)

    def update_message(self,msg):
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

    def update_action_list(self,action_list):
            small_monitor = self.update_small_monitor(action_list)
            self.images.screen.blit(small_monitor,self.images.pos["small_content_left_corner"])
            pygame.display.update(self.small_content_update_rect)

    def update_small_monitor(self,action_list):

        bg_clean = pygame.Surface.copy(self.images.surfaces['small_content_surface'])

        font_text = self.get_font(10)

        for i in range(0,len(action_list)):
            render_text: pygame.Surface = font_text.render(action_list[i],True, "#F0EAD6")
            #render text
            bg_clean.blit(render_text, (0, 0+i*20))
        
        #apply overlay
        bg_clean.blit(self.images.surfaces["small_overlay_cut"],(0,0))

        return bg_clean

    def update_main_monitor(self,env):
        
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
        
        if int(stat_dict['dungeon_num']) != 0:
            print("dungeon_num: ",stat_dict['dungeon_num'] )
            for i in matrix:
                print(i)

        # print("---- STAT DICT ----")
        # for key in stat_dict:
        #     print(f'{key} - {stat_dict[key]}')
        

        stat_msg = 'HP:' + stat_dict['hp'] + '(' + stat_dict['maxhp'] + ') PW:' + stat_dict['energy'] + '(' + stat_dict['maxenergy'] + ') Lvl:' + stat_dict['explvl'] + ' Exp:' + stat_dict['exp'] + ' $:' + stat_dict['gold'] + ' Dungeon #:' + stat_dict['dungeon_num'] + 'Hunger: ' + str(hunger)
        stat_msg_2 = 'Neutral'

        for key in self.stats_to_print:
            stat_msg_2 += ' ' + key + ':' + stat_dict[key]

        render_stat_msg = terminal_font_s.render(stat_msg,True, "#F0EAD6")
        render_stat_msg2 = terminal_font_s.render(stat_msg_2,True, "#F0EAD6")

        dungeon_surface = self.dungeon.draw_dungeon(matrix,int(stat_dict['dungeon_num']))


        #435 H - 336 dungeon + 15 de cada stat + 5 entre as stats + 20 da mensagem + 20 da mensagem ate à dungeon + 5 da beira do ecra em cima + 5 da beira do ecra em baixo
        #+120 +190 (190-98)
        dungeon_pos = (0,60)
        bg_clean.blit(dungeon_surface, dungeon_pos) #30px da msg (20 font size + 10 de margem) acaba nos 226
        
        if msg[0] != 0:
            game_msg = self.update_message(msg)
            bg_clean.blit(game_msg,(dungeon_pos[0],dungeon_pos[1]-40)) #starts same place as dungeon, Y -40

        bg_clean.blit(render_stat_msg, (dungeon_pos[0], dungeon_pos[1]+356)) #starts same place as dungeon, Y +396
        bg_clean.blit(render_stat_msg2, (dungeon_pos[0], dungeon_pos[1]+376)) #starts same place as dungeon, Y +416

        #apply overlay
        bg_clean.blit(self.images.surfaces["big_overlay_cut"],(0,0))

        return bg_clean

    def update_graphics(self,env,action_list):

        big_monitor = self.update_main_monitor(env)
        
        if len(action_list)>=1:
            small_monitor = self.update_small_monitor(action_list)
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

    def background_anim(self,menu:MenuVertical|MenuHorizontal,bg_anim:spritesheet.Animation,assets:list,top_layer):
        animated_assets = []
        
        key_1_obj = (menu.prev_key,menu.prev_key_pos)
        key_2_obj =(menu.cur_key,menu.cur_key_pos)
        animated_assets = [key_1_obj,key_2_obj] #deleted obj out 
        
        if type(menu) == MenuVertical:
            inner_anim = self.images.animations['arrow'].inner_animation()
            obj =(inner_anim,menu.cur_cursor_pos)
            animated_assets.append(obj)
        
        all_assets = assets + animated_assets
        
        #make something to handle having all the screen assets in one tuple list
        bg_anim.loop_animate(self.images.surfaces['big_monitor_fs_surface'],all_assets,top_layer,self.images.pos['big_monitor_fs_left_corner'],self.big_monitor_fs_update_rect,self.images.screen)

class Game:
    def __init__(self):
        pygame.init()
        self.data_file = 'data.json'
        self.images, self.controller,  self.graphics  , self.sound = self.load_data()
        self.action_list = []
        self.action_list_max_size = 10
        self.msg_max_size = 60      #big screen can fit around 75-ish
        self.env = self.env_init()
        self.clock = pygame.time.Clock()
        self.board = Leaderboard(self.images,self.graphics.small_content_update_rect)
        self.joystick_sound = [self.sound.files['joystick_1'],self.sound.files['joystick_2']]
        pygame.display.set_caption("NetHack Prolog Agent")
        pygame.display.set_icon(self.images.images['icon'])
        self.main_menu()

    def load_data(self):
        file = open(self.data_file)
        data = json.load(file)
        sound = Sound(data["sound"])
        images = ImageBin(data["positioning"],data["images"],data["surfaces"],data["animations"])
        controller = ControllerSet(data["action_map"],data["controller_sets"],images)
        graphics = self.init_graphics(controller,images,data["stat_keys"], data["stats_to_print"],sound)
        
        return images, controller, graphics, sound

    def init_graphics(self,controller,images,stat_keys,stats_to_print,sound):


        graphic_assets = { 'joystick_default':controller.controller_set['joystick'].default_state,
                                            'joystick_pos': controller.controller_set['joystick'].pos,
                                            'button_default': controller.controller_set['buttons'].default_state,
                                            'button_pos'  : controller.controller_set['buttons'].button_pos}
        
        return Graphics(stat_keys,stats_to_print,graphic_assets,images,sound)

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
        nethack.Command.PICKUP
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
        env = gym.make("NetHackScore-v0", actions=navigate_actions)
        #env.print_action_meanings()´

        env.reset()
        return env

    def init_prolog(self):
        pygame.display.set_caption("Nethack: Prolog Agent")
        self.init_prolog_game()
        janus.query_once("main:main_start(ENV,GAME).",{'ENV':self.env,"GAME":self})
        self.game_over()

    def init_prolog_game(self):
        self.graphics.update_action_list(self.action_list)
        self.graphics.update_graphics(self.env,self.action_list)
        self.sound.files['game'].play(-1,fade_ms=5000)

    def prolog_move(self,key_name):
        self.clock.tick(60)

        if key_name in self.controller.keys:
            if self.controller.keys[key_name].has_graphics:
            
                #fazer um getter para isto, já agora, é por isto que estava a andar 2 vezes pro lado
                controller_type: Joystick | Keypad | MenuVertical = self.controller.get_controller_type(key_name)            #controller.joystick or controller.keypad
                
                step_res = controller_type.press_key(self.env,key_name,self.clock)
                self.graphics.update_graphics(self.env,self.action_list)
            else:
                step_res = self.env.step(self.controller.keys[key_name].nle_move)

            if self.env.unwrapped.last_observation[14][0]: # type: ignore
                return False

        if self.controller.controller_set['joystick'].is_pressed:
            #self.joystick_sound[random.randint(0,1)].play()
            self.sound.key_sounds[key_name].play()
            self.controller.controller_set['joystick'].release_key(self.clock)

        if self.controller.controller_set['buttons'].is_pressed:
            pygame.time.wait(100)
            self.sound.files['button'].play()
            self.controller.controller_set['buttons'].release_key(self.clock)
        
        return step_res

    def start_game(self):
        self.env = self.env_init()
        self.init_prolog()
        #self.play_game()

    def output_text(self,text):
        msg_2 = ""

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

        if msg_2!='': 
            if free_space<2:
                if free_space ==1:
                    self.action_list.pop(0)
                else:
                    self.action_list.pop(0)
                    self.action_list.pop(0)


            self.action_list.append(msg_2)

        if free_space == 0:
            self.action_list.pop(0)
        
        self.action_list.append(text)
        self.graphics.update_action_list(self.action_list)

    def quit_game(self):
        pygame.quit()
        sys.exit()

    def menu_screen_behaviour(self,animation,menu:MenuVertical|MenuHorizontal,assets,top_layer,action,action_trigger,action_ticks,running):

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
                        self.sound.files['main_menu'].fadeout(7000)
                        animation.set_fade_out(animation.fade_surface)
                        if not menu.who_is_pressed:
                            self.sound.files['coin'].play().set_volume(1.0)
                            action_trigger = True 
                            action = 0
                            break
                        else:
                            action_trigger = True 
                            action = 1
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
        self.graphics.background_anim(menu,animation,assets,top_layer)
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
                if not action:
                    self.start_game()
                else:
                    running = False
        
        return action,action_trigger,action_ticks,running

    def game_over(self):        
        self.controller.controller_set['special'].set_iddle('space')
        self.sound.files['game_over'].play(fade_ms=1000).set_volume(0.5)
        self.graphics.game_over_screen()
        #get reason for game_over
        end_reason = self.env.unwrapped.nethack.how_done()
        txt = 'You ' + end_reason
        txt_surface = self.graphics.render_text(txt,20,"#F0EAD6")

        assets = [(self.images.images['play_again'],(0,0)),(txt_surface,(0,100))]
        animation = self.images.animations['game_over_bg']
        top_layer = (self.images.surfaces['big_overlay_cut_fs'],(0,0))
        running = True 
        menu = self.controller.controller_set['end_menu']
        action_trigger = False 
        action_ticks = 380
        action = 0
        while running:
            self.clock.tick(60)
            action, action_trigger, action_ticks, running = self.menu_screen_behaviour(animation,menu,assets,top_layer,action,action_trigger,action_ticks,running)
        
        pygame.quit()

    def play_game(self):
        self.sound.files['game'].play(-1,fade_ms=3000)
        running = True

        self.graphics.update_graphics(self.env,self.action_list)
        #clear graphics
        self.graphics.update_small_monitor(self.action_list)
        while running:
            self.clock.tick(60)

            for event in pygame.event.get():

                if event.type == pygame.QUIT:
                    #quit_game()
                    running = False
                    break
                if event.type == pygame.VIDEORESIZE:
                    self.graphics.screen = pygame.display.set_mode((event.w, event.h),pygame.RESIZABLE,display=0)
                
                if event.type == pygame.VIDEOEXPOSE:
                    self.graphics.screen.blit(self.graphics.bg_surface, (0, 0))
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
                        case pygame.K_1:
                            self.graphics.screen_toggle()
                            break
                    
                    if key_name in self.controller.keys:
                        if self.controller.keys[key_name].has_graphics:
                        
                            #fazer um getter para isto, já agora, é por isto que estava a andar 2 vezes pro lado
                            controller_type: Joystick | Keypad | MenuVertical = self.controller.get_controller_type(key_name)            #controller.joystick or controller.keypad
                            
                            self.env = controller_type.press_key(self.env,key_name,self.clock)
                            self.graphics.update_graphics(self.env,self.action_list)
                        else:
                            self.env.step(self.controller.keys[key_name].nle_move)
                        
                        if self.env.unwrapped.last_observation[14][0] == running: # type: ignore
                            running = False 
                            break
            #OUTSIDE OF EVENT LOOP -> handle kept states and updates
            if self.controller.controller_set['joystick'].is_pressed:
                
                pressed = pygame.key.get_pressed()
                if pressed[pygame.key.key_code(self.controller.controller_set['joystick'].key_pressed)]:
                    #comment this line for agent
                    self.env.step(self.controller.controller_set['joystick'].key_dict[self.controller.controller_set['joystick'].key_pressed].nle_move) #type: ignore
                    self.graphics.update_graphics(self.env,self.action_list)
                else:
                    self.controller.controller_set['joystick'].release_key(self.clock)
                
                if self.env.unwrapped.last_observation[14][0] == running: # type: ignore
                    running = False
                    break

            if self.controller.controller_set['buttons'].is_pressed:
                pressed = pygame.key.get_pressed()
                if not pressed[pygame.key.key_code(self.controller.controller_set['buttons'].key_pressed)]:
                    pygame.time.wait(100)

                    self.controller.controller_set['buttons'].release_key(self.clock)

        pygame.mixer.music.fadeout(1000)
        
        self.game_over()

    def main_menu(self):
        
        main_menu_assets = [(self.images.images['nle_logo_menu'],self.images.pos['menu_text'])]
        menu = self.controller.controller_set['menu']
        bg_anim = self.images.animations["main_menu_bg"]
        top_layer = (self.images.surfaces['big_overlay_cut_fs'],(0,0))
        action_trigger:bool = False 
        action_ticks:int = 380
        action = 0
        running:bool = True
        
        self.controller.controller_set['special'].set_iddle('space')
        #sound
        self.sound.files['main_menu'].play(-1,fade_ms=7000).set_volume(0.4)

        while running:
            self.clock.tick(60)
            action, action_trigger,action_ticks,running = self.menu_screen_behaviour(bg_anim,menu,main_menu_assets,top_layer,action,action_trigger,action_ticks,running)

        pygame.quit()

# mode de jogo humano ou agent
# indicador das keys para os botões
# overlay togle para ver as keys/acções
# algo para guardar os melhores scores quer dos players quer do agent
# hp bar
# ver reinforcement learning 
# arranjar o prolog todo lol

# added reason for game_over to game_over screen
if __name__ == '__main__':
    Game()