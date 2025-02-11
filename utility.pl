:- consult('./actions.pl').
:- consult('./codes.pl').

/**
 * Move mappings for directions.
 */
move_py(-1,0,'_N_'). %north
move_py(0,1,'_E_'). %east
move_py(1,0,'_S_'). %south
move_py(0,-1,'_W_'). %west
move_py(1,1,'_SE_'). %southEast
move_py(-1,-1,'_NW_'). %northwest
move_py(1,-1,'_SW_'). %southwest
move_py(-1,1,'_NE_'). %northEast



split_diag('_SE_','_S_','_E_').
split_diag('_NW_','_N_','_W_').
split_diag('_SW_','_S_','_W_').
split_diag('_NE_','_N_','_E_').

diag('can\'t move diagonally').

/**
 * Valid elements to walk on in the game environment.
 */
valid('stairsdown').          % >     staircase going down
valid('passage').
valid('door').
valid('doorop').
valid('floor').               % .     floor you can see
valid('floortunel').          % #     floor tile between rooms
valid('ladderup').
valid('ladderdown').
valid('misc').
valid('floornovis').
valid('stairsup').            % <     staircase going up
%valid('player_monk').
valid('pet').
valid('gold').
valid('sink').
valid('fountain').
valid('monster').
valid('vertopendrawbridge').
valid('horopendrawbridge').
valid('vertcloseddrawbridge').
valid('horcloseddrawbdrige').
valid('food').
valid('boulder'). % o boulder pode ser goal mas não caminho, pode não dar para empurrar e dá asneira

intact_door('door').
intact_door('doorop').

actions('combat').
actions('eat_food').
actions('food_pickup').
actions('gold_pickup').

/**
 * Goals in the game environment.
 */
%goals('monster').
%goals('food').
%goals('gold').
goals('stairsdown').
goals('door').
goals('doorop').
goals('passage').
goals('floortunel').
goals('boulder').
goals('floor').

goal_action('monster','combat').
goal_action('food','eat_food').
goal_action('food','food_pickup').
goal_action('gold','gold_pickup').
goal_action('stairsdown','stairsdown').
goal_action('door','door').
goal_action('doorop','The door opens.').
goal_action('passage','The door opens.').
goal_action('floortunel','explore').
goal_action('floor','explore').
goal_action('boulder','push boulder').
goal_action('no goals','quit').

is_floor('floortunel').
/**
 * Declaration of methods that will be asserted and retracted to define previous paths and doors so the player will not turn back, unless necessary.
 * The floor hierarchy and locked doors change the order in which the player explores, being locked implies a removal from the objectives, but not a restriction in going though them.
 */
:- dynamic(once/2).
:- dynamic(locked/2).
:- dynamic(wayback/2).
:- dynamic(floor_once/2).
:- dynamic(floor_twice/2).
:- dynamic(floor_locked/2).
:- dynamic(soft_lock/2).
:-dynamic(edge/3).
:-dynamic(disconect_edge/2).
:-dynamic(is_over/1).

isWayback(X,Y):-
    \+ wayback(X,Y),
    asserta(wayback(X,Y)),!.

isWayback(X,Y):- wayback(X,Y).
/**
 * Base case for isOnce/2 when a door has not been yet used. Assers the door as seen.
 *
 * @param X The X coordinate of the path.
 * @param Y The Y coordinate of the path.
 */

isOnce(X,Y):- 
    \+ once(X,Y),
    asserta(once(X,Y)),!.

/**
 * Predicate to lock a door. After a door has been passed through at least twice, it's taken off the objectives list. 
 *
 * @param X The X coordinate of the path.
 * @param Y The Y coordinate of the path.
 */

isOnce(X,Y):- 
    once(X,Y),
    retract(once(X,Y)),
    asserta(soft_lock(X,Y)),!.

isOnce(X,Y):- 
    soft_lock(X,Y).

/**
 * Base case for isFloorOnce/2 when a floortunnel tile has not been yet used. Asserts the tile as seen once.
 *
 * @param X The X coordinate of the path.
 * @param Y The Y coordinate of the path.
 */
isFloorOnce(X,Y):- 
    \+ floor_once(X,Y),
    \+ once(X,Y),
    \+ soft_lock(X,Y),
    asserta(floor_once(X,Y)),!.

/**
 * If a floortunnel tile has been used once, it retracts that fact and asserts it's been done twice. 
 *
 * @param X The X coordinate of the path.
 * @param Y The Y coordinate of the path.
 */
isFloorOnce(X,Y):-
    floor_once(X,Y),
    retract(floor_once(X,Y)),
    asserta(floor_twice(X,Y)),!.

/**
 * If a floortunnel tile has been used twice, it retracts that fact and asserts it as locked, removing it from the objectives list, however it remains as a tile that can be traversed.
 *
 * @param X The X coordinate of the path.
 * @param Y The Y coordinate of the path.
 */
isFloorOnce(X,Y):-
    floor_twice(X,Y),
    retract(floor_twice(X,Y)),
    asserta(floor_locked(X,Y)),!.

isFloorOnce(X,Y):- floor_locked(X,Y).
isFloorOnce(X,Y):- once(X,Y).
isFloorOnce(X,Y):- soft_lock(X,Y).

%%check if in Yes or No question. Decline.
check_mishap(1,Game):-
    letter_to_action("n",Action),
    move(Action,Game,_).

check_mishap(_,_).


/**
 * Extract player information from OBS_BLSTATS.
 *
 * @param OBS_BLSTATS A list of 25 elements containing player stats and position.
 * @param POS_X The X coordinate of the player.
 * @param POS_Y The Y coordinate of the player.
 * @param STR_PERC The strength percentage of the player.
 * @param STR The strength of the player.
 * @param DEX The dexterity of the player.
 * @param CONS The constitution of the player.
 * @param INT The intelligence of the player.
 * @param WIS The wisdom of the player.
 * @param CHAR The charisma of the player.
 * @param SCORE The score of the player.
 * @param HIT The current hit points of the player.
 * @param MAX_HIT The maximum hit points of the player.
 * @param DEPTH The depth level the player is on.
 * @param GOLD The amount of gold the player has.
 * @param ENERGY The current energy of the player.
 * @param MAX_ENERGY The maximum energy of the player.
 * @param ARMOR_C The armor class of the player.
 * @param MONSTER_LVL The monster level of the player.
 * @param EXPLVL The experience level of the player.
 * @param EXP_P The experience points of the player.
 * @param TIME The game time.
 * @param HUNGER The hunger state of the player.
 * @param CARRY_CAP The carrying capacity of the player.
 * @param DUNGEON_NUMBER The current dungeon number.
 * @param LEVEL_NUMBER The current level number.
 */

get_Player_info(OBS_BLSTATS, POS_X, POS_Y, STR_PERC, STR, DEX, CONS, INT, WIS, CHAR, SCORE, HIT, MAX_HIT, DEPTH, GOLD, ENERGY, MAX_ENERGY, ARMOR_C, MONSTER_LVL, EXPLVL, EXP_P, TIME, HUNGER, CARRY_CAP, DUNGEON_NUMBER, LEVEL_NUMBER):- 
    nth1(1, OBS_BLSTATS, POS_X_PY), py_call(POS_X_PY:item(), POS_X), 
    nth1(2, OBS_BLSTATS, POS_Y_PY), py_call(POS_Y_PY:item(), POS_Y), 
    nth1(3, OBS_BLSTATS, STR_PERC_PY), py_call(STR_PERC_PY:item(), STR_PERC), 
    nth1(4, OBS_BLSTATS, STR_PY), py_call(STR_PY:item(), STR), 
    nth1(5, OBS_BLSTATS, DEX_PY), py_call(DEX_PY:item(), DEX), 
    nth1(6, OBS_BLSTATS, CONS_PY), py_call(CONS_PY:item(), CONS), 
    nth1(7, OBS_BLSTATS, INT_PY), py_call(INT_PY:item(), INT), 
    nth1(8, OBS_BLSTATS, WIS_PY), py_call(WIS_PY:item(), WIS), 
    nth1(9, OBS_BLSTATS, CHAR_PY), py_call(CHAR_PY:item(), CHAR), 
    nth1(10, OBS_BLSTATS, SCORE_PY), py_call(SCORE_PY:item(), SCORE), 
    nth1(11, OBS_BLSTATS, HIT_PY), py_call(HIT_PY:item(), HIT), 
    nth1(12, OBS_BLSTATS, MAX_HIT_PY), py_call(MAX_HIT_PY:item(), MAX_HIT), 
    nth1(13, OBS_BLSTATS, DEPTH_PY), py_call(DEPTH_PY:item(), DEPTH), 
    nth1(14, OBS_BLSTATS, GOLD_PY), py_call(GOLD_PY:item(), GOLD), 
    nth1(15, OBS_BLSTATS, ENERGY_PY), py_call(ENERGY_PY:item(), ENERGY), 
    nth1(16, OBS_BLSTATS, MAX_ENERGY_PY), py_call(MAX_ENERGY_PY:item(), MAX_ENERGY), 
    nth1(17, OBS_BLSTATS, ARMOR_C_PY), py_call(ARMOR_C_PY:item(), ARMOR_C), 
    nth1(18, OBS_BLSTATS, MONSTER_LVL_PY), py_call(MONSTER_LVL_PY:item(), MONSTER_LVL), 
    nth1(19, OBS_BLSTATS, EXPLVL_PY), py_call(EXPLVL_PY:item(), EXPLVL), 
    nth1(20, OBS_BLSTATS, EXP_P_PY), py_call(EXP_P_PY:item(), EXP_P), 
    nth1(21, OBS_BLSTATS, TIME_PY), py_call(TIME_PY:item(), TIME), 
    nth1(22, OBS_BLSTATS, HUNGER_PY), py_call(HUNGER_PY:item(), HUNGER), 
    nth1(23, OBS_BLSTATS, CARRY_CAP_PY), py_call(CARRY_CAP_PY:item(), CARRY_CAP), 
    nth1(24, OBS_BLSTATS, DUNGEON_NUMBER_PY), py_call(DUNGEON_NUMBER_PY:item(), DUNGEON_NUMBER),  
    nth1(25, OBS_BLSTATS, LEVEL_NUMBER_PY), py_call(LEVEL_NUMBER_PY:item(), LEVEL_NUMBER).


/**
 * Get the player position from WORLD_DATA.
 *
 * @param WORLD_DATA The game world data.
 * @param ROW The row position of the player.
 * @param COL The column position of the player.
 */
get_player_pos(Game,ROW,COL):-
    get_info_from_env(Game, _, _, Stats, _, _, _, _),
    get_Player_info(Stats, COL, ROW, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _).

/**
 * Convert a line of values to their respective designations.
 *
 * @param VALUES A list of values to convert.
 * @param DESIGNATIONS The resulting list of designations.
 */
convertLine([VALUE_PY], [DESIGNATION]):- py_call(VALUE_PY:item(), VALUE), code(VALUE, DESIGNATION).
convertLine([VALUE_PY|VALUES], [DESIGNATION|REST]):- py_call(VALUE_PY:item(), VALUE), code(VALUE, DESIGNATION), convertLine(VALUES, REST).
/**
 * Translate a matrix of glyphs to their respective designations.
 *
 * @param MATRIX The matrix of glyphs to translate.
 * @param CONVERTED_MATRIX The resulting matrix of designations.
 */
translate_glyphs([], []).
translate_glyphs([LINE], [CONVERTED_LINE]):- convertLine(LINE, CONVERTED_LINE).
translate_glyphs([LINE|LINES], [CONVERTED_LINE|MATRIX]):- convertLine(LINE, CONVERTED_LINE), translate_glyphs(LINES, MATRIX).

/**
 * DEBUGING FUNCTIONS
 *
 * 
 * 
 */


print_matrix(MATRIX,20):-
    nth0(20,MATRIX,LINE),
	format('~w ~n',[LINE]),!.

print_matrix(MATRIX,N):-
    nth0(N,MATRIX,LINE),
    format('~w ~n',[LINE]),
    NewN is N + 1,
    print_matrix(MATRIX,NewN).

designate(_,_,'player_monk','player_monk').
designate(R,C,_,'wayback'):- wayback(R,C).
designate(_,_,VALUE,'valid'):- valid(VALUE),!.
designate(_,_,VALUE,VALUE).

convertLine_valids([VALUE],INDEX_ROW,[DESIGNATION],78):- designate(INDEX_ROW,78,VALUE,DESIGNATION),!.
convertLine_valids([VALUE|VALUES], INDEX_ROW, [DESIGNATION|REST],C):- designate(INDEX_ROW,C,VALUE,DESIGNATION), NewC is C+1, convertLine_valids(VALUES,INDEX_ROW,REST,NewC).

translate_valid([LINE], [CONVERTED_LINE],20):- convertLine_valids(LINE,20, CONVERTED_LINE,0),!.
translate_valid([LINE|LINES],[CONVERTED_LINE|VALID_MATRIX],N):- convertLine_valids(LINE,N,CONVERTED_LINE,0), NewN is N + 1, translate_valid(LINES,VALID_MATRIX,NewN).

/**------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */

/**
 * Get an element from a matrix at the specified row and column.
 *
 * @param MATRIX The matrix to get the element from.
 * @param INDEX_ROW The row index.
 * @param INDEX_COL The column index.
 * @param ELEM The resulting element.
 */
get_elem(MATRIX,INDEX_ROW,INDEX_COL,ELEM) :-
    nth0(INDEX_ROW,MATRIX,LINE),
    nth0(INDEX_COL,LINE,ELEM).

/**
 * Check if the game is running based on INFO.end_status.
 *
 * @param INFO The game info.
 * @param IsRunning True if the game is running, false otherwise.
 */
truth_val(GameOver_py,_):- arg(1,GameOver_py,true),retract(is_over(false)),asserta(is_over(true)),fail.
truth_val(GameOver_py,GameOver):- arg(1,GameOver_py,GameOver).

% is_game_running(DONE,true):- arg(1,DONE,false).
% is_game_running(DONE,false):- arg(1,DONE,true).
%is_game_running(DONE, true):- format('is_game_running True ~n'),INFO.end_status == 0.
%is_game_running(DONE, false):- format('is_game_running False ~n'),INFO.end_status == 1.

%%call with OBS.message -- transform message into atom to do actions with. 
get_message(MESSAGE,ATOM_STRING):-
    findall(El, (member(El_py,MESSAGE), py_call(El_py:item(), El),El=\=0), NEWCHAR),
    atom_codes(ATOM_STRING,NEWCHAR).

check_sub(Char,Sub):-
    get_message(Char,String),
    sub_string(String,_,_,_,Sub),!.

/**
 * Get game information from the ENV environment.
 *
 * @param ENV The game environment.
 * @param OBS The observed game state.
 * @param REWARD The reward obtained.
 * @param DONE If the game is done.
 * @param INFO Additional game info.
 */
get_info_from_map(ENV, OBS, REWARD, DONE, INFO) :- arg(1, ENV, OBS), arg(2,ENV, REWARD), arg(3, ENV, DONE), arg(5, ENV, INFO).

get_info_from_env(Game, GlyphMatrix, Message, Stats, GameOver, InQuestion, Stairs, Hunger):- 
    py_call(Game:env:unwrapped:last_observation, LastObs),
    arg(1,LastObs,GlyphMatrix),                                                 %GlyphMatrix must be decoded after
    arg(5,LastObs, Stats),                                                      %stats must be decoded after
    arg(6,LastObs, Message),                                                    %message must be decoded after
    arg(16,LastObs, Internal),                                                  %tupple with various values of interest
    nth0(1,Internal,InQuestion_py), py_call(InQuestion_py:item(), InQuestion),       %is the agent in a y/n question
    nth0(4,Internal,Stairs_py), py_call(Stairs_py:item(), Stairs),             %need to check if this is "stairs under item player is currently standing on"
    nth0(7,Internal,Hunger_py), py_call(Hunger_py:item(), Hunger),      %all ints are being pulled as np_ints
    arg(15,LastObs, ProgramState),                                              %this is a tubple with multiple bools
    nth0(0,ProgramState, GameOver_py), py_call(GameOver_py:item(), GameOver).           %this is being imported as a compound term.




/**
 * Predicate to confirm if the player can step at the specified coordinates.
 *
 * @param TEMP_DATA Temporary data containing player and game state.
 * @param X2 The target X-coordinate.
 * @param Y2 The target Y-coordinate.
 * @param ACTION The action being confirmed.
 */


confirm_step(X1,Y1,X2,Y2,Game):-
    %format('Confirming Step ~n '),
    get_player_pos(Game,ROW,COL),
    X2 == ROW,
    Y2 == COL,
    isWayback(X1,Y1),
    isFloorOnce(X1,Y1).

/**
 * Executes a series of actions based on an A* pathfinding result.
 *
 * @param ENV The game environment.
 * @param PATH The list of coordinates representing the path.
 * @param GOAL The final goal of the action sequence.
 * @param DATA Additional game data.
 */
% (15,34) -> (16,35)
% (15,34) -> (16,34) -> (16,35)
% (16,34) -> (17,34) -> (17,35)
%  X -> S -> E  (porta a Este)
% (12,40) ->(11,39)
% (12,40) -> (12,39) -> (11,39)
% X -> W -> N (porta a Norte) 
% to minimize errors and maintain step verification along the way,
% instead of just doing the extra step, we add the new step to the path and go back to
% the main executing function
diag_correct(TranslatedMatrix, Move, X1,Y1,[(X1,Y1),NewPos]):-
    %format('Correcting Diagonal ~n'),
    split_diag(Move,Comp_1,Comp_2),
    (diag_move(TranslatedMatrix,Move,X1,Y1,Comp_1,NewPos);
    diag_move(TranslatedMatrix,Move,X1,Y1,Comp_2,NewPos)).

diag_move(TranslatedMatrix,_,X1,Y1,Comp,(NewX,NewY)):-    
    move_py(NewMove_X,NewMove_Y,Comp),
    NewX is X1+NewMove_X,
    NewY is Y1+NewMove_Y,
    get_elem(TranslatedMatrix,NewX,NewY,Elem),
    valid(Elem).

%if no possible correction can be done,disconnect edge:
% diag_move(_,Move,X1,Y1,_,_):-
%     move_py(MOVE_X,MOVE_Y,Move),
%     X2 is X1 + MOVE_X,
%     Y2 is Y1 + MOVE_Y,
%     asserta(disconect_edge((X1,Y1),(X2,Y2))).

    % move_py(NewMove_X2,NewMove_Y2,Comp_2),
    % NewX2 is NewX1+NewMove_X2,
    % NewY2 is NewY1+NewMove_Y2.