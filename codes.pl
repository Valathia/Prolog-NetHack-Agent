% game code translation facts
/**
 * Maps game codes to their corresponding descriptions.
 */
code(333, 'player_monk').               % @     Player when Monk Class
code(413, 'cat').                  % f     Tame Kitten Pet (MON_GLYPH + 381)
code(397, 'dog').                  % d     Small dog
code(2316, 'gold').                % $
code(2353, 'boulder').
code(2359, 'void').                %  
code(2360, 'wallv').               % |     wall vertical      
code(2361, 'wallh').               % _     wall horizontal     
code(2362, 'topleftc').             % |-    up left corner     
code(2363, 'toprightc').            % -|    up right corner    
code(2364, 'botleftc').           % |_    down left corner     
code(2365, 'botrightc').          % _|    down right corner   
code(2366, 'crosswall').
code(2367, 'tupwall').
code(2368, 'tdownwall').
code(2369, 'tleftwall').
code(2370, 'trightwall').
code(2371, 'passage').              %       opening in a wall
code(2372, 'doorop').               % -     Door Opened Vertical
code(2373, 'doorop').    
code(2374, 'door').                 % +     Door Closed Vertical
code(2375, 'door').                 % +     Door Closed Horizontal
code(2376, 'ironbars').
code(2377, 'tree').
code(2378, 'floor').               % .     floor you can see
code(2379, 'floornovis').          % .     floor you've discoverd but can't currently see
code(2380, 'floortunel').          % #     floor tile between rooms
code(2381, 'passage').             %        Likely also floor or a passage
code(2382, 'stairsup').            % <     staircase going up
code(2383, 'stairsdown').          % >     staircase going down
code(2384, 'ladderup').
code(2385, 'ladderdown').
code(2386, 'altar').
code(2387, 'grave').
code(2388, 'throne').
code(2389, 'sink').
code(2390, 'fountain').            % {     water fountain (we can't quaff but it's good to know)
code(2391, 'pool').
code(2392, 'ice').
code(2393, 'lava').
code(2394, 'vertopendrawbridge').
code(2395, 'horopendrawbridge').
code(2396, 'vertcloseddrawbridge').
code(2397, 'horcloseddrawbdrige').
code(2398, 'air').
code(2399, 'cloud').
code(2400, 'water').
code(2401, 'trap').
code(2402, 'trap').
code(2403, 'trap').
code(2404, 'trap').
code(2405, 'trap').
code(2406, 'trap').
code(2407, 'trap').
code(2408, 'trap').
code(2409, 'trap').
code(2410, 'trap').
code(2411, 'trap').
code(2412, 'trap').
code(2413, 'hole').
code(2414, 'trapdoor').
code(2415, 'tptrap').
code(2416, 'lvltptrap').
code(2417, 'magicportal').
code(2418, 'trap').
code(2419, 'trap').
code(2420, 'trap').
code(2421, 'trap').
code(2422, 'trap').

% //need to set these as non monster 
% 367 - 380 - quest guardians
% 342 - 354 - quest givers 
% 267 - 272 - peaceful - shopkeepers and the like
% 278-279 - peaceful - watch and watch captain
%monsters start at 0
code(Code, 'monster'):- Code < 267.
code(Code,'human'):- Code <=272.  %shopkeeper and the like 267-272
code(278,'human'). %watch
code(279,'human'). %watch captain
code(Code, 'monster'):- Code < 342.
code(Code,'human'):- Code <= 354. %from 342-354 Lord Carnarvon -Neferet the Green quest givers
code(Code,'monster'):- Code <= 366.  % Quest nemesis 355-366
code(Code, 'human'):- Code <= 380. % quest guardians 367-380
%code(Code, 'food'):- Code >= 1144, Code =< 1524. %these are actually corpses --- need to take out the bad food - most corpses shouldn't be eaten...
code(Code, 'food'):- Code >= 2145, Code =< 2177.
code(_, 'misc').