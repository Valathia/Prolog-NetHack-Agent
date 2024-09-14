% added for the benifit of the syntax tool
% :- include('./actions.pl').
% :- include('./protocols.pl').
% :- include('./codes.pl').
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
%valid('boulder'). --- o boulder pode ser goal mas não caminho, pode não dar para empurrar e dá asneira

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
%goals('boulder').
%goals('floor').

goal_action('monster','combat').
goal_action('food','eat_food').
goal_action('food','food_pickup').
goal_action('gold','gold_pickup').
goal_action('stairsdown','stairsdown').
goal_action('door','door').
goal_action('doorop','The door opens.').
goal_action('passage','The door opens.').
goal_action('floortunel','explore').

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
truth_val(GameOver_py,GameOver):- arg(1,GameOver_py,GameOver).

is_game_running(DONE,true):- arg(1,DONE,false).
is_game_running(DONE,false):- arg(1,DONE,true).
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




confirm_step(_,_,_,_,_,true).
/**
 * Predicate to confirm if the player can step at the specified coordinates.
 *
 * @param TEMP_DATA Temporary data containing player and game state.
 * @param X2 The target X-coordinate.
 * @param Y2 The target Y-coordinate.
 * @param ACTION The action being confirmed.
 */
confirm_step(X1,Y1,X2,Y2,Game,false):-
    format('Confirming Step ~n '),
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
    format('Correcting Diagonal ~n'),
    split_diag(Move,Comp_1,Comp_2),
    (diag_move(TranslatedMatrix,X1,Y1,Comp_1,NewPos);
    diag_move(TranslatedMatrix,X1,Y1,Comp_2,NewPos)).

diag_move(TranslatedMatrix,X1,Y1,Comp,(NewX,NewY)):-    
    move_py(NewMove_X,NewMove_Y,Comp),
    NewX is X1+NewMove_X,
    NewY is Y1+NewMove_Y,
    get_elem(TranslatedMatrix,NewX,NewY,Elem),
    valid(Elem).

    % move_py(NewMove_X2,NewMove_Y2,Comp_2),
    % NewX2 is NewX1+NewMove_X2,
    % NewY2 is NewY1+NewMove_Y2.

execute_path(TranslatedMatrix,[],Action,GameOver,false,Game):-
    pick_protocol(TranslatedMatrix, Action,[],Game,GameOver).

execute_path(TranslatedMatrix,[(X1,Y1),(X2,Y2)], Action, GameOver, false,Game):- 
    format('Last two moves, time to pick a protocol. ~n'),
    pick_protocol(TranslatedMatrix, Action,[(X1,Y1),(X2,Y2)],Game,GameOver).



/**
 * Recursive predicate to execute a series of actions based on an A* pathfinding result.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)|T] The remaining path coordinates to execute.
 * @param GOAL The final goal of the action sequence.
 * @param WORLD_DATA The current game world data.
 */


execute_path(TranslatedMatrix,[(X1,Y1),(X2,Y2)|T], Action, GameOver, false, Game):-
    format('Executing Move ~w -> ~w ~n ',[(X1,Y1),(X2,Y2)]),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move), %translates MOVE_X & MOVE_Y into a direction
    move(Move, Game, TempGameOver_py),  %moves in the corresponding direction
    truth_val(TempGameOver_py,TempGameOver),
    get_info_from_env(Game, _, Message, _, _, InQuestion, _, _),
    check_mishap(InQuestion, Game),
    (check_sub(Message,'can\'t move diagonally'),
    diag_correct(TranslatedMatrix,Move,X1,Y1,NewHead),
    append(NewHead,[(X2,Y2)|T],NewList),
    execute_path(TranslatedMatrix,NewList, Action, GameOver, TempGameOver, Game),!;
    confirm_step(X1,Y1,X2,Y2,Game,TempGameOver), %confirms if the player is in the new square, if he is not, redo the action
    execute_path(TranslatedMatrix,[(X2,Y2)|T], Action, GameOver, TempGameOver, Game),!;
    execute_path(TranslatedMatrix,[(X1,Y1),(X2,Y2)|T], Action, GameOver, TempGameOver, Game)). %,!; %execute next action
    % is_game_running(DONE,false),
    % WORLD_DATA is TEMP_DATA.

execute_path(_,_,_,true,true,_).

/**
 * Calculates the Manhattan distance between two points.
 *
 * @param X1 The X-coordinate of the first point.
 * @param Y1 The Y-coordinate of the first point.
 * @param X2 The X-coordinate of the second point.
 * @param Y2 The Y-coordinate of the second point.
 * @param D The Manhattan distance between the two points.
 */
manhattan((X1, Y1), (X2, Y2), D):-
    D is abs(X1 - X2) + abs(Y1 - Y2).

/**
 * Checks if a position is within the bounds of a matrix.
 *
 * @param X The X-coordinate of the position.
 * @param Y The Y-coordinate of the position.
 * @param Matrix The matrix representing the game map.
 */
in_bounds((X,Y), Matrix):-
    length(Matrix, Rows),
    nth0(0, Matrix, Row),
    length(Row, Cols),
    X >= 0, X < Rows,
    Y >= 0, Y < Cols.

/**
 * Checks if a position in the matrix is valid.
 *
 * @param X The X-coordinate of the position.
 * @param Y The Y-coordinate of the position.
 * @param Matrix The matrix representing the game map.
 */
check_valid((X,Y), Matrix):-
    get_elem(Matrix,X,Y,ELEM),
    valid(ELEM),
    \+ wayback(X,Y),
    \+ locked(X,Y).

/**
 * Finds neighboring positions of a given position within the matrix.
 *  neighbors of floortunel can be diagonal, but they can't, if the neighbor is a dor it can't be diagonal
 * @param X The X-coordinate of the position.
 * @param Y The Y-coordinate of the position.
 * @param Matrix The matrix representing the game map.
 * @param Neighbors The list of neighboring positions.
 */
neighbors((X, Y), Matrix, Neighbors):-
    get_elem(Matrix,X,Y,CUR),
    neighbors((X, Y), Matrix, Neighbors, CUR).
    %format('Cur Neighbor: ~w ~n',[CUR]),
    %format('Cur Neighbor Pos: ~w ~n',[(X, Y)]),
    %format('Neighbours: ~w ~n',[Neighbors]).

%this seems to be working, if it's a door it doesn't go in diagonally
neighbors((X, Y), Matrix, Neighbors, _):-
    %format('Cur Neighbor floortunnel - Admissable diagonals from it. ~w ~n',[CUR]),
    %is_floor(CUR),
    findall((NX, NY),
            (   (NX is X + 1, NY is Y);
                (NX is X - 1, NY is Y);
                (NX is X, NY is Y + 1);
                (NX is X, NY is Y - 1);
                (NX is X + 1, NY is Y + 1);
                (NX is X - 1, NY is Y - 1);
                (NX is X + 1, NY is Y - 1);
                (NX is X - 1, NY is Y + 1)              %,get_elem(Matrix,NX,NY,Elem),is_floor(Elem) no more need for this
                ),
            AllNeighbors),
    include({Matrix}/[Pos]>>in_bounds(Pos, Matrix), AllNeighbors, InBoundsNeighbors),
    include({Matrix}/[Pos]>>check_valid(Pos, Matrix), InBoundsNeighbors, Neighbors).

%when the player starts from a door, the door won't be a door but player...
%needs to exclude the player as well. 
% neighbors((X, Y), Matrix, Neighbors, _):-
%     %format('Cur Neighbor is not floortunnel ~w ~n',[CUR]),
%     findall((NX, NY),
%             (   (NX is X + 1, NY is Y);
%                 (NX is X - 1, NY is Y);
%                 (NX is X, NY is Y + 1);
%                 (NX is X, NY is Y - 1)),
%             AllNeighbors),
%     include({Matrix}/[Pos]>>in_bounds(Pos, Matrix), AllNeighbors, InBoundsNeighbors),
%     include({Matrix}/[Pos]>>check_valid(Pos, Matrix), InBoundsNeighbors, Neighbors).



build_edge(_,[]).

build_edge(Start,[Cur|Neighbors]):-
    \+edge(_,Cur,_),
    get_weight(Start,Cur,G),
    asserta(edge(Start,Cur,G)),
    build_edge(Start,Neighbors).

build_edge(Start,[_|Neighbors]):-
    build_edge(Start,Neighbors).

% make_vert(Vert):-
%     \+vert(Vert),
%     asserta(vert(Vert)).

% make_vert(Vert).

build_graph_list([],_,_).

build_graph_list([Cur|Rest],Visited,Matrix):-
    neighbors(Cur,Matrix,Neighbors),
    findall(Node,(member(Node,Neighbors),\+member(Node,Rest),\+member(Node,Visited)),Nodes),
    build_edge(Cur,Nodes),
    append(Rest,Nodes,NewNodes),
    build_graph_list(NewNodes,[Cur|Visited],Matrix).


build_graph(Start,Matrix):-
    neighbors(Start,Matrix,Neighbors),
    %findall(Node,(member(Node,Neighbors), +\edge(Node,_,_)),Nodes),
    build_edge(Start,Neighbors),
    build_graph_list(Neighbors,[],Matrix).




/**
 * A* algorithm implementation to find the shortest path in a matrix.
 *
 * @param Start The starting position.
 * @param Goal The goal position.
 * @param Matrix The matrix representing the game map.
 * @param Path The resulting shortest path.
 */
a_star(Start, (X,Y), Matrix, Path, GAME) :-
    get_elem(Matrix,X,Y,GOAL_P),
    format('A* Star Goal: ~w ~n',[GOAL_P]),
    format('Goal at: (~w,~w) ~n',[X,Y]),
    format('Player at: ~w ~n',[Start]),
    % format('Translated Matrix: ~n'),
    % print_matrix(Matrix,0),
    % format('Path Matrix: ~n'),
    % translate_valid(Matrix,Res,0),
    % print_matrix(Res,0),
    py_call(prolog_gui:output_text('A* Star Goal: ',GOAL_P, GAME)),
    manhattan(Start, (X,Y), H),
    %format('Manhattan Dist to Goal: ~w ~n',[H]),
    astar([(H, [Start], 0, H)], (X,Y), Matrix, RevPath), % <--- coordinates (x,y) aka Start should be F in Astar*
    reverse(RevPath, Path).

/**
 * Helper predicate for A* algorithm.
 *
 * @param [(CurrentPath, G)|Rest] The list of current paths and their costs.
 * @param Goal The goal position.
 * @param Matrix The matrix representing the game map.
 * @param Path The resulting shortest path.
 */
astar([(_, Path, _, 0)|_], _, _, Path):-
    format('Found path: ~w ~n',[Path]).

% astar([(_,CurrentPath,_,_)|[]], _, Matrix,[]) :-     
%     CurrentPath = [Current|_],
%     \+length(CurrentPath,1),
%     neighbors(Current, Matrix, []),
%     format('No Path to Goal. ~n'),!.
%mudar a condição para baixo e mudar a condiçao para nao ter rest nem neighbours
%peso alterado, correção de F(N) para garantir que é sempre crescente
astar([(OldF, CurrentPath, G, _)|Rest], Goal, Matrix, Path) :-
    CurrentPath = [Current|_],
    neighbors(Current, Matrix, Neighbors),
    checkRest(Rest,All_lists),
    findall((F, [Neighbor|CurrentPath], NewG, H),
            (   member(Neighbor, Neighbors),
                \+ member(Neighbor,CurrentPath),
                \+ check_list(Neighbor, All_lists),
                manhattan(Neighbor, Goal, H),
                get_weight(Current,Neighbor,G_2), 
                NewG is G + G_2,
                Hcalc is NewG + H,
                Fcalc is OldF + 1,
                local_max(F,Hcalc,Fcalc)),
            NewNodes),
    append(Rest, NewNodes, NewOpenList),
    sort(NewOpenList, SortedOpenList),
    % format('Rest before: ~w ~n',[Rest]),
    % format('CurrentPath: ~w ~n',[CurrentPath]),
    % format('Neighbours to see: ~w ~n ~n',[SortedOpenList]),
    astar(SortedOpenList, Goal, Matrix, Path).


checkRest([],[]).
checkRest(Rest,All_lists):-
        findall(ListEl,(member(ANS_1,Rest),
                arg(2,ANS_1,ANS_2),
                arg(1,ANS_2,ListEl)),
                All_lists).

local_max(F,Hcalc,Fcalc):- 
    Fcalc >= Hcalc,
    F is Fcalc;
    F is Hcalc.

check_list(El,All_lists):-
    member(List,All_lists),
    member(El,List),!.

get_weight((X1,Y1),(X2,Y2),G):-
    X1 =\= X2,
    Y1 =\= Y2,
    G is 50.

get_weight((X1,_),(X2,_),G):-
    X1 =:= X2,
    G is 99.

get_weight((_,Y1),(_,Y2),G):-
    Y1 =:= Y2,
    G is 99.

% arg(N,[(5,[(10,28),(10,29),(9,29)],2,3),(6,[(10,29),(10,28),(9,29)],2,4),(6,[(10,30),(9,29)],1,5),(7,[(10,30),(10,29),(9,29)],2,5)],ANS),
% arg(2,ANS,ANS_2),
% arg(1,ANS_2,FINAL).
/**
 * Predicate that defines a list with the available objects in the board with an order of precedence.
 * Uses the order of the goals defined previously and then combines a series of list 
 * The list will be of the objectives not yet visited, followed by the floor tunnel tiles visited once, then the doors visited once and finally the floors visited twice.
 * Locked tiles can be used but cannot be pathed towards too as objectives.
 * 
 * @param Matrix The matrix representing the game map.
 * @param GOAL_LIST the resulting list of all available objectives
 */

% create_pairs([],_,_,ManList,ManList).

% create_pairs([(X,Y)|T],START_R,START_C,[(D,(X,Y))|CurList],ManList):-
%     manhattan((START_R, START_C), (X, Y), D),
%     create_pairs(T,START_R,START_C,CurList,ManList).

% get_pairs([],Pairs,Pairs).

% get_pairs([((_,X,Y))|T], [(X,Y)|CurList],Pairs):-
%     get_pairs(T,CurList,Pairs).

% order_goals(MATRIX,START_R,START_C,GOAL_LIST):-
%     findall((X,Y),(goals(ELEM_GOAL),get_elem(MATRIX, X, Y, ELEM_GOAL),\+locked(X,Y),\+soft_lock(X,Y),\+floor_locked(X,Y)),L),
%     findall((X,Y),(member((X,Y),L),once(X,Y)),O),
%     findall((X,Y),(member((X,Y),L),get_elem(MATRIX, X, Y, 'stairsdown')),Stairs),
%     findall((X,Y),(member((X,Y),L),\+member((X,Y),O),\+member((X,Y),Stairs)),List),
%     create_pairs(List,START_R, START_C,ManList,[]),
%     format('Manhatan List: -~w ~n',[ManList]),
%     sort(ManList, SortedGoalList),
%     format('Manhatan List Sorted: -~w ~n',[SortedGoalList]),
%     get_pairs(SortedGoalList,Pairs,[]),
%     append(Stairs,Pairs,Half),
%     append(Half,O,GOAL_LIST),
%     format('O: -~w ~n',[O]),
%     format('Stairs: -~w ~n',[Stairs]),
%     format('List: -~w ~n',[List]),
%     format('Goal List: ~w ~n',[GOAL_LIST]).


get_goals(MATRIX, GOAL_LIST):-
    findall((X,Y),(goals(ELEM_GOAL),get_elem(MATRIX, X, Y, ELEM_GOAL),(edge((X,Y),_,_);edge(_,(X,Y),_)),\+locked(X,Y),\+soft_lock(X,Y),\+floor_locked(X,Y)),L),
    findall((X,Y),(member((X,Y),L),once(X,Y)),O),
    findall((X,Y),(member((X,Y),L),\+member((X,Y),O)),H),
    append(H,O,GOAL_LIST).

get_objectives(MATRIX, GOAL_LIST):-
    findall((X,Y),(goals(ELEM_GOAL),get_elem(MATRIX, X, Y, ELEM_GOAL),\+locked(X,Y),\+soft_lock(X,Y),\+floor_locked(X,Y)),L),
    findall((X,Y),(member((X,Y),L),once(X,Y)),O),
    findall((X,Y),(member((X,Y),L),\+member((X,Y),O)),H),
    append(H,O,GOAL_LIST).


get_goals_2(Matrix, Goal_List):-
    findall((X,Y),(get_elem(Matrix, X, Y, 'stairsdown'),(edge((X,Y),_,_);edge(_,(X,Y),_))),Priority),
    findall((X,Y),(goals(Elem_Goal),get_elem(Matrix, X, Y, Elem_Goal),(edge((X,Y),_,_);edge(_,(X,Y),_)),\+locked(X,Y),\+soft_lock(X,Y),\+floor_locked(X,Y),\+member((X,Y),Priority)),L),
    findall((X,Y),(member((X,Y),L),once(X,Y),\+member((X,Y),Priority)),O),
    findall((X,Y),(member((X,Y),L),floor_once(X,Y),\+member((X,Y),Priority),\+member((X,Y),O)),FO),
    findall((X,Y),(member((X,Y),L),floor_twice(X,Y),\+member((X,Y),Priority),\+member((X,Y),O),\+member((X,Y),FO)),FT),
    %findall((X,Y),(member((X,Y),L),get_elem(Matrix, X, Y, 'floor'),length(FL,5)),FL),!,
    append(FO,O,FOO),
    append(FOO,FT,AllVisited),
    %append(FOOFT,FL,AllVisited),
    findall((X,Y),(member((X,Y),L),\+member((X,Y),AllVisited)),H),
    append(Priority,H,Head),
    append(Head,AllVisited,Goal_List).

get_objectives_2(Matrix, Goal_List):-
    findall((X,Y),(get_elem(Matrix, X, Y, 'floor'),length(Goal_List,5),\+locked(X,Y),\+soft_lock(X,Y),\+floor_locked(X,Y)),Goal_List).

/**
 * Finds the shortest path from a starting position, iterating through a list of end positions (goals)
 *
 * @param MATRIX The matrix representing the game environment.
 * @param START_R Starting row index.
 * @param START_C Starting column index.
 * @param GOAL_LIST List of coordinates (X,Y) of all available goals
 * @param ELEM_GOAL Selected Goal to go towards to
 * @param SOL List of coordinates representing the path from (START_R, START_C) to (END_R, END_C).
 */

get_path(TranslatedMatrix,Start_R,Start_C,[],Elem_Goal,Sol,Game,Reason):- 
    py_call(prolog_gui:output_text('All out of options - retract','',Game)),
    format('All out of options - retract ~n'),
    wayback(_,_),
    retractall(wayback(_,_)),
    retractall(edge(_,_,_)),
    build_graph((Start_R,Start_C),TranslatedMatrix),!,
    get_next_move(TranslatedMatrix, Start_R, Start_C, Elem_Goal, Sol, Game, Reason).

get_path(_,_,_,[],_,[],_,_):- 
    \+wayback(_,_), 
    format('All out of options - No more moves left ~n'),
    get_next_move(_,_,_,_,[],_,'No more Goals').


get_path(TranslatedMatrix, Start_R, Start_C, [(X,Y)|T], Elem_Goal, Sol, Game,Reason):-
    py_call(prolog_gui:output_text('Searching for path...','',Game)),
    format('Searching for path... ~n'),
    get_elem(TranslatedMatrix,X,Y,Elem_Goal),
    a_star((Start_R,Start_C),(X,Y), TranslatedMatrix, Sol, Game),!;
    % length(SOL,L),
    % L >= 2,!;
    get_path(TranslatedMatrix, Start_R, Start_C, T, Elem_Goal, Sol, Game, Reason).

/**
 * Determines the next move action based on the current game state and objectives.
 *
 * @param MATRIX The matrix representing the game environment.
 * @param START_R Starting row index.
 * @param START_C Starting column index.
 * @param ELEM_GOAL The objective element to reach.
 * @param SOL List of coordinates representing the next move action.
 */


%it's not ending properly. Cycles when Goal list is empty ...
get_next_move(TranslatedMatrix, Start_R, Start_C, Elem_Goal, Sol, Game,Reason):-
    get_goals_2(TranslatedMatrix,Goal_List),
    format('GOAL LIST: ~w ~n',[Goal_List]),
    %py_call(prolog_gui:output_text('GOAL LIST: ',GOAL_LIST,GAME)),
    get_path(TranslatedMatrix, Start_R, Start_C, Goal_List, Elem_Goal, Sol, Game,Reason).


get_next_move(_,_,_,_,[],_,_).

/**
 * Calculates the best action to take based on game state and goals.
 *
 * @param WORLD_DATA The current game world data.
 * @param ELEM_GOAL The goal element to reach.
 * @param BEST_ACTION The best calculated action to take.
 */

check_goal(Matrix, Goal, Goal_list):-
    findall((X,Y),(get_elem(Matrix, X, Y, Goal),(edge((X,Y),_,_);edge(_,(X,Y),_))),Goal_list).


check_action(Matrix,Goal,Goal_list):-
    check_goal(Matrix,Goal,Goal_list),
    length(Goal_list,N),
    N =\= 0.

% calculate_best_action( Game, Action, Goal):-
%     get_info_from_env(Game, GlyphMatrix, _, Stats, _, _, _, _),
%     translate_glyphs(GlyphMatrix, TranslatedMatrix),                                                  %hunger
%     get_Player_info(Stats, Pos_Col, Pos_Row, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _),
%     %get_elem(TRANSLATED_MATRIX,X,Y,ELEM_GOAL),
%     %print_matrix(TRANSLATED_MATRIX,0),
%     get_next_move(TranslatedMatrix, Pos_Row, Pos_Col, Goal, Action, Game).

%combat
calculate_best_action(Game, TranslatedMatrix, Pos_Row, Pos_Col, _, Path, Action,_):-
    check_action(TranslatedMatrix,'monster',[(X,Y)|_]),
    format('There is a Monters nearby ~n'),
    goal_action('monster',Action),
    a_star((Pos_Row,Pos_Col),(X,Y), TranslatedMatrix, Path, Game),!.

%eat
calculate_best_action(Game, TranslatedMatrix, Pos_Row, Pos_Col, Hunger, Path,Action,_):-
    Hunger =< 500,
    format('Im Hungry... ~n'),
    check_action(TranslatedMatrix,'food',[(X,Y)|_]),
    goal_action('food',Action),
    a_star((Pos_Row,Pos_Col),(X,Y), TranslatedMatrix, Path, Game),!.

%use messages to eat from inventory, need to split message to get INV letters for food
%pickup food
calculate_best_action(Game, TranslatedMatrix, Pos_Row, Pos_Col, _, Path, Action,_):-
    check_action(TranslatedMatrix,'food',[(X,Y)|_]),
    format('Uuh! Piece of Candy! ~n'),
    goal_action('food',Action),
    a_star((Pos_Row,Pos_Col),(X,Y), TranslatedMatrix, Path, Game),!.
%pickup gold
calculate_best_action(Game, TranslatedMatrix, Pos_Row, Pos_Col, _, Path, Action,_):-
    check_action(TranslatedMatrix,'gold',[(X,Y)|_]),
    format('Good as Gold ~n'),
    goal_action('gold',Action),
    a_star((Pos_Row,Pos_Col),(X,Y), TranslatedMatrix, Path, Game),!.

%need something to tell action based on goal
%explore
calculate_best_action(Game, TranslatedMatrix, Pos_Row, Pos_Col, _, Path, Action, Reason):-
    get_next_move(TranslatedMatrix, Pos_Row, Pos_Col, Elem_Goal, Path, Game,Reason),
    goal_action(Elem_Goal,Action),
    format('Goal chosen: ~w ~n ', [Elem_Goal]),
    format('We are going exploring! ~w ~n',[Action]).

calculate_best_action(_,_,_,_,_,[],'quit',_).

%add an if on top of stairs  go down
get_best_action(TranslatedMatrix, Game,Path,Action,Reason):-
    format('Get Best Action ~n'),
    retractall(edge(_,_,_)),
    get_info_from_env(Game, _, _, _, _, InQuestion, _, Hunger),
    check_mishap(InQuestion, Game),
    %translate_glyphs(GlyphMatrix, TranslatedMatrix),  
    get_player_pos(Game, Pos_Row, Pos_Col),
    build_graph((Pos_Row,Pos_Col),TranslatedMatrix),
    calculate_best_action(Game, TranslatedMatrix, Pos_Row, Pos_Col, Hunger, Path, Action,Reason),!.

/**
 * Renders the game environment by calling a Python function.
 * Clears the terminal screen before rendering for better display.
 *
 * @param ENV The Python environment object used for rendering.
 */
renderMap(ENV):- sleep(0.25), tty_clear, py_call(ENV:render()), sleep(0.25).

/**
 * Main predicate to run the game environment until completion.
 *
 * @param ENV The game environment.
 * @param PREV_WORLD_DATA The previous game world data.
 * @param FIRST_MOVE Flag indicating if this is the first move.
 * @param GAME_RUNNING Flag indicating if the game is still running.
 */
game_run(_, true, Reason):- format('GAME OVER: ~w~n', [Reason]).

game_run(Game, false, Reason):- 
    format('Game is Running ~n'),
    get_info_from_env(Game, GlyphMatrix, _, _, _, _, _, _),
    translate_glyphs(GlyphMatrix, TranslatedMatrix),  
    get_best_action(TranslatedMatrix, Game,Path,Action,Reason),!,
    format('Path for Action: ~w ~w ~n', [Action,Path]),
    execute_path(TranslatedMatrix, Path, Action, GameOver, false, Game),
    format('Is Game Over ? ~w ~n', [GameOver]),
    game_run(Game, GameOver, Reason).

% game_run(Game, false, _):- 
%     get_best_action(Game,[],_),
%     py_call(prolog_gui:output_text('No more moves left','',Game)), 
%     format('Game_run:No more moves left ~n'),
%     %execute_action(ENV, ACTION, GOAL, WORLD_DATA),
%     game_run(_,true,'no best action').

/**
 * Initializes the game environment by creating a new instance and resetting it.
 * This predicate initializes the environment for the NetHackScore-v0 game.
 *
 * @param ENV The Python environment object to interact with the game environment.
 *            It should be instantiated before calling this predicate.
 */
/* change this function to call another python function that will create the env env_init() */
% game_innit(ENV):- py_call(gym:make("NetHackScore-v0"), ENV),
% py_call(ENV:reset()).
%functio not currently in use, ENV is being created in python and passed onto gameStart directly.
% game_innit(ENV) :- 
%     py_call(prolog_gui:env_init(),ENV), 
%     py_call(prolog_gui:start_game(ENV)).

/**
 * Starts the game environment and initiates the game loop.
 */
gameStart(Game):- %game_innit(ENV),
    %move('_SEARCH_', GAME, WORLD_DATA),
    game_run(Game, false, _).
    %nb_setval(game,GAME).