
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
valid('boulder').

intact_door('door').
intact_door('doorop').

/**
 * Goals in the game environment.
 */
goals('stairsdown').
goals('monster').
goals('gold').
goals('food').
goals('door').
goals('doorop').
goals('passage').
goals('floortunel').
goals('boulder').
%goals('floor').

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
get_player_pos(WORLD_DATA,ROW,COL):- 
    get_info_from_map(WORLD_DATA, OBS, _, _, _),
    get_Player_info(OBS.blstats, COL, ROW, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _).

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
is_game_running(DONE,true):- arg(1,DONE,false).
is_game_running(DONE,false):- arg(1,DONE,true).
%is_game_running(DONE, true):- format('is_game_running True ~n'),INFO.end_status == 0.
%is_game_running(DONE, false):- format('is_game_running False ~n'),INFO.end_status == 1.


/**
 * Get game information from the ENV environment.
 *
 * @param ENV The game environment.
 * @param OBS The observed game state.
 * @param REWARD The reward obtained.
 * @param DONE If the game is done.
 * @param INFO Additional game info.
 */
get_info_from_map(ENV, OBS, REWARD, DONE, INFO) :- arg(1, ENV, OBS), arg(2,ENV, REWARD), arg(3, ENV, DONE), arg(4, ENV, INFO).


/**
 * Predicate to confirm if the player can step on a door at the specified coordinates.
 *
 * @param TEMP_DATA Temporary data containing player and game state.
 * @param X2 The target X-coordinate.
 * @param Y2 The target Y-coordinate.
 */
confirm_step_door(TEMP_DATA,X2,Y2,_):-
    get_player_pos(TEMP_DATA,ROW,COL),
    X2 == ROW,
    Y2 == COL.
/**
 * Predicate to confirm if the player can step at the specified coordinates.
 *
 * @param TEMP_DATA Temporary data containing player and game state.
 * @param X2 The target X-coordinate.
 * @param Y2 The target Y-coordinate.
 * @param ACTION The action being confirmed.
 */
confirm_step(_,TEMP_DATA,X2,Y2,_,_):-
    get_player_pos(TEMP_DATA,ROW,COL),
    X2 == ROW,
    Y2 == COL.
/**
 * Predicate to confirm a step action in the game environment.
 *
 * @param ENV The game environment.
 * @param TEMP_DATA Temporary data containing player and game state.
 * @param X2 The target X-coordinate.
 * @param Y2 The target Y-coordinate.
 * @param ACTION The action being confirmed.
 */
confirm_step(ENV,_,X2,Y2,ACTION,GAME):-
    move(ACTION, ENV, GAME, TEMP_DATA),
    renderMap(ENV),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION,GAME).


/**
 * Executes a series of actions based on an A* pathfinding result.
 *
 * @param ENV The game environment.
 * @param PATH The list of coordinates representing the path.
 * @param GOAL The final goal of the action sequence.
 * @param DATA Additional game data.
 */
execute_action(ENV, [(X1,Y1),(X2,Y2)], GOAL, DATA,GAME):- 
    pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,GOAL,DATA,GAME).

/**
 * Recursive predicate to execute a series of actions based on an A* pathfinding result.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)|T] The remaining path coordinates to execute.
 * @param GOAL The final goal of the action sequence.
 * @param WORLD_DATA The current game world data.
 */
execute_action(ENV, [(X1,Y1),(X2,Y2)|T], GOAL, WORLD_DATA, GAME):-
    format('executing action'),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION), %translates MOVE_X & MOVE_Y into a direction
    move(ACTION, ENV, GAME, TEMP_DATA),  %moves in the corresponding direction
    renderMap(ENV),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION,GAME), %confirms if the player is in the new square, if he is not, redo the action
    asserta(floor_locked(X1,Y2)),
    get_info_from_map(TEMP_DATA, _, _, DONE, _),
    is_game_running(DONE, true),
    execute_action(ENV,[(X2,Y2)|T], GOAL, WORLD_DATA, GAME). %,!; %execute next action
    % is_game_running(DONE,false),
    % WORLD_DATA is TEMP_DATA.


/**
 * Calculates the Manhattan distance between two points.
 *
 * @param X1 The X-coordinate of the first point.
 * @param Y1 The Y-coordinate of the first point.
 * @param X2 The X-coordinate of the second point.
 * @param Y2 The Y-coordinate of the second point.
 * @param D The Manhattan distance between the two points.
 */
manhattan((X1, Y1), (X2, Y2), D) :-
    D is abs(X1 - X2) + abs(Y1 - Y2).

/**
 * Checks if a position is within the bounds of a matrix.
 *
 * @param X The X-coordinate of the position.
 * @param Y The Y-coordinate of the position.
 * @param Matrix The matrix representing the game map.
 */
in_bounds((X,Y), Matrix) :-
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
check_valid((X,Y), Matrix) :-
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
neighbors((X, Y), Matrix, Neighbors) :-
    get_elem(Matrix,X,Y,CUR),
    neighbors((X, Y), Matrix, Neighbors, CUR),
    format('Cur Neighbor: ~w ~n',[CUR]),
    format('Cur Neighbor Pos: ~w ~n',[(X, Y)]),
    format('Neighbours: ~w ~n',[Neighbors]).

neighbors((X, Y), Matrix, Neighbors, CUR) :-
    intact_door(CUR),
    findall((NX, NY),
            (   (NX is X + 1, NY is Y);
                (NX is X - 1, NY is Y);
                (NX is X, NY is Y + 1);
                (NX is X, NY is Y - 1)),
            AllNeighbors),
    include({Matrix}/[Pos]>>in_bounds(Pos, Matrix), AllNeighbors, InBoundsNeighbors),
    include({Matrix}/[Pos]>>check_valid(Pos, Matrix), InBoundsNeighbors, Neighbors).

neighbors((X, Y), Matrix, Neighbors, _) :-
    findall((NX, NY),
            (   (NX is X + 1, NY is Y);
                (NX is X - 1, NY is Y);
                (NX is X, NY is Y + 1);
                (NX is X, NY is Y - 1);
                (NX is X + 1, NY is Y + 1,get_elem(Matrix,NX,NY,Elem),\+intact_door(Elem));
                (NX is X - 1, NY is Y - 1,get_elem(Matrix,NX,NY,Elem),\+intact_door(Elem));
                (NX is X + 1, NY is Y - 1,get_elem(Matrix,NX,NY,Elem),\+intact_door(Elem));
                (NX is X - 1, NY is Y + 1,get_elem(Matrix,NX,NY,Elem),\+intact_door(Elem))
                ),
            AllNeighbors),
    include({Matrix}/[Pos]>>in_bounds(Pos, Matrix), AllNeighbors, InBoundsNeighbors),
    include({Matrix}/[Pos]>>check_valid(Pos, Matrix), InBoundsNeighbors, Neighbors).

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
    py_call(prolog_gui:output_text('A* Star Goal: ',GOAL_P, GAME)),
    manhattan(Start, (X,Y), H),
    format('Manhattan Dist to Goal: ~w ~n',[H]),
    astar([(Start, [Start], 0, H)], (X,Y), Matrix, RevPath),
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


astar([(_, CurrentPath, G, _)|Rest], Goal, Matrix, Path) :-
    CurrentPath = [Current|_],
    neighbors(Current, Matrix, Neighbors),
    checkRest(Rest,All_lists),
    findall((F, [Neighbor|CurrentPath], NewG, H),
            (   member(Neighbor, Neighbors),
                \+ member(Neighbor,CurrentPath),
                \+ check_list(Neighbor, All_lists),
                manhattan(Neighbor, Goal, H),
                NewG is G + 1,
                F is NewG + H),
            NewNodes),
    append(Rest, NewNodes, NewOpenList),
    sort(NewOpenList, SortedOpenList),
    format('CurrentPath: ~w ~n',[CurrentPath]),
    format('Neighbours to see: ~w ~n',[SortedOpenList]),
    astar(SortedOpenList, Goal, Matrix, Path).

checkRest([],[]).
checkRest(Rest,All_lists):-
        findall(ListEl,(member(ANS_1,Rest),
                arg(2,ANS_1,ANS_2),
                arg(1,ANS_2,ListEl)),
                All_lists).

check_list(El,All_lists):-
    member(List,All_lists),
    member(El,List),!.

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

create_pairs([],_,_,ManList,ManList).

create_pairs([(X,Y)|T],START_R,START_C,[(D,(X,Y))|CurList],ManList):-
    manhattan((START_R, START_C), (X, Y), D),
    create_pairs(T,START_R,START_C,CurList,ManList).

get_pairs([],Pairs,Pairs).

get_pairs([((_,X,Y))|T], [(X,Y)|CurList],Pairs):-
    get_pairs(T,CurList,Pairs).

order_goals(MATRIX,START_R,START_C,GOAL_LIST):-
    findall((X,Y),(goals(ELEM_GOAL),get_elem(MATRIX, X, Y, ELEM_GOAL),\+locked(X,Y),\+soft_lock(X,Y),\+floor_locked(X,Y)),L),
    findall((X,Y),(member((X,Y),L),once(X,Y)),O),
    findall((X,Y),(member((X,Y),L),get_elem(MATRIX, X, Y, 'stairsdown')),Stairs),
    findall((X,Y),(member((X,Y),L),\+member((X,Y),O),\+member((X,Y),Stairs)),List),
    create_pairs(List,START_R, START_C,ManList,[]),
    format('Manhatan List: -~w ~n',[ManList]),
    sort(ManList, SortedGoalList),
    format('Manhatan List Sorted: -~w ~n',[SortedGoalList]),
    get_pairs(SortedGoalList,Pairs,[]),
    append(Stairs,Pairs,Half),
    append(Half,O,GOAL_LIST),
    format('O: -~w ~n',[O]),
    format('Stairs: -~w ~n',[Stairs]),
    format('List: -~w ~n',[List]),
    format('Goal List: ~w ~n',[GOAL_LIST]).


% get_objectives(MATRIX, GOAL_LIST):-
%     %findall((X,Y),(goals(ELEM_GOAL),get_elem(MATRIX, X, Y, ELEM_GOAL),\+locked(X,Y),\+soft_lock(X,Y),\+floor_locked(X,Y)),L),
    
%     findall((X,Y),(member((X,Y),L),once(X,Y)),O),

%     %findall((X,Y),(member((X,Y),L),floor_once(X,Y)),FO),
%     %findall((X,Y),(member((X,Y),L),floor_twice(X,Y)),FT),
%     %findall((X,Y),(member((X,Y),L),get_elem(MATRIX, X, Y, 'floor'),length(FL,5)),FL),!,
%     %append(FO,O,FOO),
%     %append(FOO,FT,FOOFT),
%     %append(FOOFT,FL,AllVisited),
%     %instead of O it was AllVisited
%     findall((X,Y),(member((X,Y),L),\+member((X,Y),O)),H),
%     append(H,O,GOAL_LIST).


get_objectives_2(MATRIX, GOAL_LIST):-
    findall((X,Y),(goals(ELEM_GOAL),get_elem(MATRIX, X, Y, ELEM_GOAL),\+locked(X,Y),\+soft_lock(X,Y),\+floor_locked(X,Y)),L),
    findall((X,Y),(member((X,Y),L),once(X,Y)),O),
    findall((X,Y),(member((X,Y),L),floor_once(X,Y)),FO),
    findall((X,Y),(member((X,Y),L),floor_twice(X,Y)),FT),
    findall((X,Y),(member((X,Y),L),get_elem(MATRIX, X, Y, 'floor'),length(FL,5)),FL),!,
    append(FO,O,FOO),
    append(FOO,FT,FOOFT),
    append(FOOFT,FL,AllVisited),
    findall((X,Y),(member((X,Y),L),\+member((X,Y),AllVisited)),H),
    append(H,AllVisited,GOAL_LIST).

get_objectives_2(MATRIX, GOAL_LIST):-
    findall((X,Y),(get_elem(MATRIX, X, Y, 'floor'),length(GOAL_LIST,5),\+locked(X,Y),\+soft_lock(X,Y),\+floor_locked(X,Y)),GOAL_LIST).


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
% get_path(MATRIX, START_R, START_C, [], ELEM_GOAL, SOL):-
%     py_call(prolog_gui:output_text('Get path retract...')),
%     retract(wayback(_,_)),
%     get_next_move(MATRIX, START_R, START_C, ELEM_GOAL, SOL).

%hasn't gone here
get_path(MATRIX, START_R, START_C, [], ELEM_GOAL, SOL,GAME):-
    py_call(prolog_gui:output_text('Get path failsafe - retract failed','',GAME)),          %no objectives introduce floor objectives
    retract(wayback(_,_)),
    get_objectives_2(MATRIX, GOAL_LIST),
    get_path(MATRIX, START_R, START_C, GOAL_LIST, ELEM_GOAL, SOL,GAME).
%

get_path(MATRIX, START_R, START_C, [(X,Y)|T], ELEM_GOAL, SOL, GAME):-
    py_call(prolog_gui:output_text('Searching for path...','',GAME)),
    get_elem(MATRIX,X,Y,ELEM_GOAL),
    a_star((START_R,START_C),(X,Y), MATRIX, SOL, GAME),!;
    get_path(MATRIX, START_R, START_C, T, ELEM_GOAL, SOL, GAME).

/**
 * Determines the next move action based on the current game state and objectives.
 *
 * @param MATRIX The matrix representing the game environment.
 * @param START_R Starting row index.
 * @param START_C Starting column index.
 * @param ELEM_GOAL The objective element to reach.
 * @param SOL List of coordinates representing the next move action.
 */

% get_next_move(MATRIX, START_R, START_C, ELEM_GOAL, SOL, GAME):-
%     get_objectives(MATRIX, []),
%     format('GOAL LIST: ~w ~n',[GOAL_LIST]).

get_next_move(MATRIX, START_R, START_C, ELEM_GOAL, SOL, GAME):-
    %get_objectives(MATRIX, GOAL_LIST),
    order_goals(MATRIX,START_R, START_C,GOAL_LIST),
    format('GOAL LIST: ~w ~n',[GOAL_LIST]),
    %py_call(prolog_gui:output_text('GOAL LIST: ',GOAL_LIST,GAME)),
    get_path(MATRIX, START_R, START_C, GOAL_LIST, ELEM_GOAL, SOL, GAME).


/**
 * Calculates the best action to take based on game state and goals.
 *
 * @param WORLD_DATA The current game world data.
 * @param ELEM_GOAL The goal element to reach.
 * @param BEST_ACTION The best calculated action to take.
 */
calculate_best_action(WORLD_DATA, ELEM_GOAL, GAME, BEST_ACTION):-
    get_info_from_map(WORLD_DATA, OBS, _, _, _),
    translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),                                                  %hunger
    get_Player_info(OBS.blstats, POS_COL, POS_ROW, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _),
    %get_elem(TRANSLATED_MATRIX,X,Y,ELEM_GOAL),
    get_next_move(TRANSLATED_MATRIX, POS_ROW, POS_COL, ELEM_GOAL, BEST_ACTION, GAME).


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
game_run(_, _, _, false):- format('GAME OVER: ~w~n', [true]).

game_run(ENV, PREV_WORLD_DATA, GAME, true):- 
    calculate_best_action(PREV_WORLD_DATA, GOAL, GAME, ACTION),!,
    format('picking protocol?'),
    pick_protocol(ENV, ACTION, GOAL, WORLD_DATA, GAME),
    %execute_action(ENV, ACTION, GOAL, WORLD_DATA),
    get_info_from_map(WORLD_DATA, _, _, DONE, _),
    is_game_running(DONE, GAME_RUNNING),
    game_run(ENV, WORLD_DATA, GAME, GAME_RUNNING).

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
gameStart(ENV,GAME):- %game_innit(ENV),
    move('_SEARCH_', ENV, GAME, WORLD_DATA),
    game_run(ENV, WORLD_DATA, GAME, true),
    nb_setval(game,GAME).