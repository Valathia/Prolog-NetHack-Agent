import pygame

# Got this from https://www.pygame.org/wiki/Spritesheet# Original Comments in code:
# This class handles sprite sheets
# This was taken from www.scriptefun.com/transcript-2-using
# sprite-sheets-and-drawing-the-background
# I've added some code to fail if the file wasn't found..

# Format for the rectangle for image_at
# (top_left_x, top_left_y, width, height)
# (base+x*w, base+y*h, w , h ) --- assuming a square w and h would be the same size. 
# since base is likely (0,0)
# (x*w, y*h, w, h)

#only kep the original try, except. everything else gotta go.

# changed the code to convert_alpha() instead of just convert -- needed for all pngs and files with transparency
# added the size attribute 
# can now calculate the size of spritesheet as a matrix
# added a subclass for animation spritesheets to handled the conversion of animation related sheets to a list 




class Spritesheet:
    #this class assumes the sprites are in squares
    def __init__(self, filename, side):
        self.filename = filename
        #try:
        self.sheet = pygame.image.load(filename).convert_alpha()
        # except pygame.error as message:
        #     print('Unable to load spritesheet image:', filename)
        #     raise SystemExit, message
        self.width = self.sheet.get_width()
        self.height = self.sheet.get_height()
        self.side = side
        self.rows = self.height // self.side 
        self.cols = self.width // self.side 
    
    # Load a specific image from a specific rectangle
    def image_at(self, x, y):

        rect = pygame.Rect((x*self.side, y*self.side), (self.side, self.side))
        image = pygame.Surface([self.side, self.side], pygame.SRCALPHA)

        image.blit(self.sheet, (0, 0), rect)
        return image
    
    # Load a whole bunch of images and return them as a list
    # def images_at(self, rects:list[pygame.Rect]):
    #     #"Loads multiple images, supply a list of coordinates" 
    #     return [self.image_at(rect) for rect in rects]
    
    # Load a whole strip of images
    def load_strip(self, row:int):
        if row < self.rows:
            
            rect = pygame.Rect((row*self.side, 0, self.side, self.width))
            image = pygame.Surface([self.side, self.side], pygame.SRCALPHA)

            image.blit(self.sheet, (0, 0), rect)

            return image
        else:
            raise ValueError(f'Unable to load strip. Row out of range. max range: :{self.rows-1}')

#
# animation assumes that it's a strip, where every frame is in a identical sized square ---- think if I should allow for rectangle frames or not
# minimum number of frames is 2: for a toggle effect
# from the Spritesheet it can generate 1 or 2 lists with the animation split.
#   - 1 list will provide the full animation, it's best suited for loops. (works for most things really)
#   - 2 lists is for flexibility, for situations like a button press. The result will be a list with the press animation and one with the release
#   both modes will generate the default (at rest) key frame, if the object needs to be drawn still
#   let's say there's a full strip provided of a small animation with 5 frames (from rest to rest)
#   frame sequence 0-1-2-1-0
#       full will return: default: 0 full: 1-2-1-0 - we skip the first at rest position for the animation to not redraw it. 
#       split will returm: default: 0 first_part: 1-2 second_part:1-0 - if this was a button, 1-2 would be presing with 2 being the button fully pressed. 1-0 would be releasing the button to default state. 
#   half-strip and inverted half_strip should return the same values. 
#
class Animation(Spritesheet):
    
    def __init__(self,filename,side,is_fullstrip,is_mirrored):
        super().__init__(filename,side)
        self.frames = self.cols #renaming for readability
        if self.frames <=1:
            raise ValueError(f'Unable to create Animation list. Less than 2 frames found.\n your frame size is: {self.height}x{self.height} and your spritesheet is {self.height}x{self.width}')
        self.is_fullstrip:bool = is_fullstrip           
        self.is_mirrored:bool = is_mirrored              #when creating animations from mirrored half strips -- won't matter for a fullstrip
        self.fade_surface = pygame.Surface((self.side,self.height)) #placeholder
        self.clean_surface = pygame.Surface((self.side,self.height)) #placeholder
        self.anim_press, self.anim_release, self.default_frame = self.set_strips()
        self.anim_full = self.anim_press + self.anim_release
        self.fade_in =False 
        self.fade_out = False 
        self.alpha = 0
        self.current_frame = 0
        self.fps = 60           #default
        self.frame_rate = self.fps // (len(self.anim_full)-1)
        self.pos = (0,0)
        # print("Setting Strips for: ",self.filename)
        # print("frames: ", self.frames)
        # print("frame_rate: ",self.frame_rate)
        # print("Anim full frames: ",len(self.anim_full))
    #initially was going to be a callable method from the class, seems easier to simply store the results in the object
    def set_strips(self):
        """
        Makes either 1 or 2 list for animating an object.

        Parameters
        ----------
        split (bool):   flag to determine if result should be 1 or 2 lists.
                        True:  splits the animation into 2 lists \n
                        False: returns 1 list with the full animation

        Returns
        -------
        float
            list[Surface] | tup[list[Surface],list[Surface]]: either 1 list with the full animation or 2 lists , one with each half of the animation frames - depends on argument passed
        """

        params = {
        "frames": self.frames,
        "press_at"   : self.frames,         #append
        "press_off"    : 0,                 #offset
        "release_at": 0,                    #insert à cabeça
        "release_off" :-1,                  #offset
        "default_at": 0                     #default 1º
        }

        if self.is_fullstrip:
            params["frames"] = self.frames // 2 #se for full só usr metade
        elif self.is_mirrored:
            params["press_at"] = 0                  #insert à cabeça
            params["press_off"] = -1                #offset
            params["release_at"] =  self.frames     #append
            params["release_off"] = 0               #offset
            params["default_at"] = self.frames-1    #last image
        
        return  self.set_split_strip(params)

    #divides the animation in half (ex: pressing a button, releasing a button)
    def set_split_strip(self,params:dict):
        anim_press= []
        anim_release = []
        
        for i in range(1,params['frames']):

            anim_press.insert( params['press_at'] , self.image_at(i+params['press_off'],0))
            anim_release.insert( params['release_at'] , self.image_at(i+params['release_off'],0))
        
        default = self.image_at(params["default_at"],0)
        
        print("#n frames: ",self.frames)
        print("Default image: ",params["default_at"])
        print('\n')
        return anim_press, anim_release, default
    
    def set_fade_in(self,surface:pygame.Surface):
        self.fade_in = True 
        self.alpha = 255
        self.fade_surface = surface 
    
    def set_fade_out(self,surface:pygame.Surface):
        self.fade_out = True
        self.alpha = 0
        self.fade_surface = surface

    def set_fade_surface(self,surface:pygame.Surface):
        self.fade_surface = surface

    def set_fps(self,fps_val:int):
        self.fps = fps_val
        self.frame_rate = self.fps // self.frames
    
    def fade(self,surface):
        fade_surface = self.fade_surface.copy()

        #fade in: 255 -> 0 alph>0     alpha-5
        #fade out: 0 -> 255 alph <255 alpha+5
        if self.fade_in:
            a = 0
            if self.alpha > 0:
                self.alpha -=15
                a = max(a,self.alpha)
            else:
                self.fade_in = False
        elif self.fade_out:
            a = 255
            if self.alpha < 255:
                self.alpha +=5
                a = min(a,self.alpha)
            #not setting fade_out to False so screen doesn't go back to normal
        
        fade_surface.fill((0, 0, 0, a), special_flags=pygame.BLEND_RGBA_MULT)
        surface.blit(fade_surface,(0,0))
        return surface
    
    def loop_animate(self,bg_surface:pygame.Surface,additional_assets:list[tuple[pygame.Surface,tuple[int,int]]],top_layer,update_pos,monitor_rect,screen):
        
        if self.current_frame >=self.fps:
            self.current_frame = 0

        if self.current_frame%self.frame_rate==0:
            #self.images.big_monitor_fs_surface
            surface = bg_surface.copy()
            #monitor_rect = pygame.Rect(update_pos,surface.get_size())

            surface.blit( self.anim_full[self.current_frame//self.frame_rate],(0,0))
            #assets_size = len(additional_assets)-1
            #top_layer = additional_assets[assets_size]
            for asset in additional_assets:
                surface.blit(asset[0],asset[1])
            
            if self.fade_in or self.fade_out:
                surface = self.fade(surface)
            
            surface.blit(top_layer[0],top_layer[1])
            screen.blit(surface,update_pos)

            pygame.display.update(monitor_rect)
        
        self.current_frame += 1

    def inner_animation(self)->pygame.Surface:

        if self.current_frame >=self.fps:
            self.current_frame = 0

        frame = self.anim_full[self.current_frame//self.frame_rate]
        if self.current_frame%self.frame_rate==0:
            frame = self.anim_full[self.current_frame//self.frame_rate]
        self.current_frame += 1
        return frame 
    
    def toggle(self):
        #frame = self.inner_animation()
        frame_rate = self.fps // len(self.anim_release)
        if self.current_frame >=self.fps:
            self.current_frame = 0
        
        frame = self.anim_release[self.current_frame//frame_rate]

        if self.current_frame%self.frame_rate==0:
            frame = self.anim_release[self.current_frame//frame_rate]

        self.current_frame += 1
        
        #clean = self.clean_surface.copy()
        #clean.blit(frame,(0,0))
        #clear.blit(frame,(0,0))
        return frame
    

    #returns full animation in 1 list
    # def get_full_strip(self):
    #     anim_push = []
    #     anim_release = []

    #     #full from full
    #     for i in range(1,self.frames//2):
    #         anim_push.append(self.image_at(0, i))
    #         anim_release.insert(0,self.image_at(0,i-1))
    #     #full from half  - it's easier if it starts as half and half and then combine
    #     for i in range(1,self.frames):
    #         anim_push.append(self.image_at(0, i))
    #         anim_release.insert(0,self.image_at(0,i-1))
    #     #full from half inverted:
    #     for i in range(1,self.frames):
    #         anim_push.insert(0,self.image_at(0,i-1))
    #         anim_release.insert(0,self.image_at(0,i))