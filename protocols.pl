% added for the benifit of the syntax tool
% :- include('./game_run.pl').

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


end_execute_action_tunnel(_,DATA,GAME) :-
    move('_SEARCH_', GAME, DATA).

/**
 * Executes an action sequence in the game environment based on the given goal.
 * If the goal corresponds to a closed door, it invokes the pick_protocol_2 to restart the selection process
 *
 * @param ENV The current game environment.
 * @param Path A list of coordinates representing the path to be executed, [(X1,Y1),(X2,Y2)].
 *             Moves from (X1,Y1) to (X2,Y2).
 * @param GOAL The current goal or objective in the game.
 * @param DATA Additional data associated with the action execution.
 */

execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], 'door', DATA,GAME):-
    format('Execute_action Last Two Moves - Door ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - Door','',GAME)),
    pick_protocol_2(ENV, [(X1,Y1),(X2,Y2)], 'door',' door', DATA,GAME).

/**
 * 
 * If the goal corresponds to a passage, it invokes the pick_protocol_2 to restart the selection process
 *
 * @param ENV The current game environment.
 * @param Path A list of coordinates representing the path to be executed, [(X1,Y1),(X2,Y2)].
 *             Moves from (X1,Y1) to (X2,Y2).
 * @param GOAL The current goal or objective in the game.
 * @param DATA Additional data associated with the action execution.
 */

execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], 'passage', DATA,GAME):-
    format('Execute_action Last Two Moves - Passage ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - Passage','',GAME)),
    pick_protocol_2(ENV, [(X1,Y1),(X2,Y2)], 'passage', 'passage', DATA,GAME).

/**
 * 
 * If the goal corresponds to a open door, it invokes the pick_protocol_2 to restart the selection process
 *
 * @param ENV The current game environment.
 * @param Path A list of coordinates representing the path to be executed, [(X1,Y1),(X2,Y2)].
 *             Moves from (X1,Y1) to (X2,Y2).
 * @param GOAL The current goal or objective in the game.
 * @param DATA Additional data associated with the action execution.
 */
execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], 'doorop', DATA,GAME):-
    format('Execute_action Last Two Moves - Open Door ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - Open Door','',GAME)),
    pick_protocol_2(ENV, [(X1,Y1),(X2,Y2)], 'doorop', 'doorop' ,DATA,GAME).

/**
 * 
 * If the goal corresponds to a boulder, it invokes a protocol to handle the action.
 *
 * @param ENV The current game environment.
 * @param Path A list of coordinates representing the path to be executed, [(X1,Y1),(X2,Y2)].
 *             Moves from (X1,Y1) to (X2,Y2).
 * @param GOAL The current goal or objective in the game.
 * @param DATA Additional data associated with the action execution.
 */
execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], 'boulder', DATA,GAME):-
    format('Execute_action Last Two Moves - BOULDER ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - BOULDER','',GAME)),
    boulder_protocol(ENV,[(X1,Y1),(X2,Y2)],'boulder',DATA, GAME).

/**
 * Executes the action to tunnel through blocked floors or obstacles in the game environment.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The coordinates representing the movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current goal or objective.
 * @param DATA The resulting game data after executing the action tunnel.
 */
execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], GOAL, DATA,GAME):- 
    format('Execute_action: TUNNEL Last Two Moves ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - TUNNEL','',GAME)),
    %pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)], GOAL, GOAL, DATA).
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, GAME, TEMP_DATA),
    %renderMap(ENV),
    confirm_step(TEMP_DATA,X2,Y2,ACTION,GAME),
    %retract(wayback(_,_)),
    asserta(wayback(X1,Y1)),
    isFloorOnce(X1,Y1),
    protocol(ENV,(X2,Y2),ACTION,GOAL,DATA,GAME).


execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], _, DATA,GAME):- 
    format('Execute_action: TUNNEL Last Two Moves - FAILSAFE Retract FAIL (hopefully) ~n'),
    py_call(prolog_gui:output_text('Execute_action: TUNNEL Last Two Moves - FAILSAFE Retract FAIL (hopefully)','',GAME)),
    %pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)], GOAL, GOAL, DATA).
    move('_SEARCH_',  GAME,TEMP_DATA),
    confirm_step_door(TEMP_DATA,X2,Y2,GAME),
    asserta(wayback(X1,Y1)),
    isFloorOnce(X1,Y1),
    end_execute_action_tunnel(ENV,DATA).

execute_action_tunnel(_, [(_,_),(_,_)], _, DATA,GAME):-
    format('Execute_action: TUNNEL Last Two Moves - FAILSAFE BIG FAIL (couldnt confirm move) - Terminate ~n'),
    py_call(prolog_gui:output_text('Execute_action: TUNNEL Last Two Moves - FAILSAFE BIG FAIL (couldnt confirm move) - Terminate','',GAME)),
    move('_SEARCH_', GAME, DATA).



/**
 * Recursively executes the action tunnel for a series of coordinates representing the movement path.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)|T] The list of coordinates representing the movement path.
 * @param GOAL The current goal or objective.
 * @param WORLD_DATA The resulting game data after executing the action tunnel for the entire path.
 */
execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)|T], GOAL, WORLD_DATA,GAME):- 
    format('Execute_action Tunnel List ~n'),
    py_call(prolog_gui:output_text('Execute_action Tunnel Lists','',GAME)),
    format('(~w,~w) to (~w,~w)',[X1,Y1,X2,Y2]),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, GAME,TEMP_DATA),
    %renderMap(ENV),
    confirm_step(TEMP_DATA,X2,Y2,ACTION,GAME),
    asserta(wayback(X1,Y1)),
    isFloorOnce(X1,Y1),
    execute_action_tunnel(ENV,[(X2,Y2)|T], GOAL, WORLD_DATA,GAME).


/**
 * Executes the tunneling protocol to navigate through the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after executing the tunneling protocol.
 */
tunneling_protocol(ENV,DATA,GAME):-
    format('Tunneling Protocol - CHOO CHOO ~n'),
    py_call(prolog_gui:output_text('Tunneling Protocol - CHOO CHOO','',GAME)),
    move('_SEARCH_', GAME, TEMP_DATA),
    get_info_from_map(TEMP_DATA, OBS, _, _, _),
    translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),
    get_Player_info(OBS.blstats, POS_COL, POS_ROW, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _),
    get_next_move(TRANSLATED_MATRIX, POS_ROW, POS_COL, GOAL, SOL,GAME),
    %get_elem(TRANSLATED_MATRIX,X,Y,GOAL),
    format('Player  row:~w col:~w ',[POS_COL,POS_ROW]),
    execute_action_tunnel(ENV, SOL, GOAL, DATA,GAME).


/**
 * Handles the case when a dead-end is encountered during tunneling.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after handling the dead-end.
 */
tunneling_protocol(_,DATA,GAME):-
    format('Tunneling failsafe, dont retract all - End ~n'),
    py_call(prolog_gui:output_text('Tunneling failsafe, dont retract all - End','',GAME)),
    move('_SEARCH_',GAME, DATA).
    %retractall(wayback(_,_)).





/**
 * Recursively pushes a boulder down a tunnel untill it reaches a dead end and cannot make further movements.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)|T] The list of coordinates representing the movement path.
 * @param GOAL The current goal or objective.
 * @param DATA The resulting game data after pushing the boulder untill it reaches a dead end.
 */
boulder_protocol(ENV,[(X1,Y1),(X2,Y2)],GOAL,DATA,GAME):-
    format('BOULDER PROTOCOL ~n'),
    py_call(prolog_gui:output_text('BOULDER PROTOCOL','',GAME)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION,GAME, TEMP_DATA),
    %renderMap(ENV),
    confirm_step_door(TEMP_DATA,X2,Y2,GAME),
    asserta(wayback(X1,Y1)),
    NEWX2 is X2 + MOVE_X,
    NEWY2 is Y2 + MOVE_Y,
    boulder_protocol(ENV,[(X2,Y2),(NEWX2,NEWY2)],GOAL,DATA,GAME).


/**
 * When comfirm_step_door fails, the player should stop pushing the boulder and unify the Data parameter. 
 *
 * @param ENV The game environment.
 * @param [(_,_),(X2,Y2)|T] The list of coordinates representing the movement path.
 * @param DATA The resulting game data after pushing the boulder untill it reaches a dead end.
 */
boulder_protocol(_,[(_,_),(X2,Y2)],_,DATA,GAME):-
    format('Boulder Protocol Lock Boulder - Search End ~n'),
    py_call(prolog_gui:output_text('Boulder Protocol Lock Boulder - Search End - theres a retract here','',GAME)),
    asserta(locked(X2,Y2)),
    retractall(wayback(_,_)),
    move('_SEARCH_', GAME,DATA).


/**
 * Protocol for handling movement down stairs in the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down stairs.
 */

/**
 * Handles going down the stairs in the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down the stairs.
 */

protocol(_,'stairsdown',GameOver,Game):-
    format('Go Down Stairs Protocol - RETRACT ALL . End ~n'),
    py_call(prolog_gui:output_text('Go Down Stairs Protocol - RETRACT ALL . End','',Game)),
    move('_DOWN_',Game,GameOver_py),
    truth_val(GameOver_py,GameOver),
    retractall(wayback(_,_)),
    retractall(once(_,_)),
    retractall(locked(_,_)),   
    retractall(floor_once(_,_)),
    retractall(floor_twice(_,_)),
    retractall(floor_locked(_,_)),
    retractall(edge(_,_,_)).


/**
 * Protocol for handling eating from the floor of the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down stairs.
 */

protocol(_,'eat_food',GameOver,Game):-
    format('Eat Protocol . End ~n'),
    py_call(prolog_gui:output_text('Eat Protocol. ','',Game)),
    move('_EAT_',Game,_),
    letter_to_action("y",Move),
    move(Move,Game,GameOver_py),
    truth_val(GameOver_py,GameOver).

protocol(_,'food_pickup',GameOver,Game):-
    format('Takeout . End ~n'),
    py_call(prolog_gui:output_text('Takeout. ','',Game)),
    move('_PICKUP_',Game,GameOver_py),
    truth_val(GameOver_py,GameOver).

protocol(_,Action,GameOver,Game):-
    format('~w Protocol End ~n',[Action]),
    move('_SEARCH_',Game,GameOver_py),
    truth_val(GameOver_py,GameOver).

%use feedback to know if monster is killed
protocol(TranslatedMatrix,'combat',[(X1,Y1),(X2,Y2)],GameOver,Game):-
    format('Combat Protocol . End ~n'),
    py_call(prolog_gui:output_text('Hit the Monster! ','',Game)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    move(Move, Game, TempGameOver_py),
    truth_val(TempGameOver_py,TempGameOver),
    get_info_from_env(Game, _, Message, _, _, InQuestion, _, _),
    check_mishap(InQuestion, Game),
    ((check_sub(Message,'You kill');check_sub(Message,'You destroy')),
    format('You kill the monster! ~n'),
    GameOver = TempGameOver;
    % confirm_step(X1,Y1,X2,Y2,Game,TempGameOver),
    % GameOver = TempGameOver;
    protocol(TranslatedMatrix,'combat',GameOver,Game)).

protocol(TranslatedMatrix,Action,[(X1,Y1),(X2,Y2)],GameOver,Game) :-
    format('~w Protocol ~n',[Action]),
    py_call(prolog_gui:output_text(Action,' Protocol',Game)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    move(Move, Game, TempGameOver_py),
    truth_val(TempGameOver_py,TempGameOver),
    get_info_from_env(Game, _, Message, _, _, InQuestion, _, _),
    check_mishap(InQuestion, Game),
    (check_sub(Message,'can\'t move diagonally'),
     diag_correct(TranslatedMatrix,Move,X1,Y1,NewHead),
     append(NewHead,[(X2,Y2)],NewList),
     execute_path(TranslatedMatrix,NewList, Action, GameOver, TempGameOver, Game),!;
     confirm_step(X1,Y1,X2,Y2,Game,TempGameOver),
     protocol(TranslatedMatrix,Action,GameOver,Game) ;
     GameOver = TempGameOver).

% /**
%  * Protocol for executing actions based on game objectives, ensuring the player moves into the objective cell.
%  * This version handles objectives that are closed doors, attempting to open the door first.
%  *
%  * @param ENV The game environment.
%  * @param [(X1,Y1),(X2,Y2)] The movement path from (X1,Y1) to (X2,Y2).
%  * @param GOAL The current objective.
%  * @param ELEM The element at (X2,Y2).
%  * @param DATA The resulting game data after executing the pick protocol.
%  */

/**
 * Handles the protocol for interacting with a closed door.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The coordinates representing the movement path from (X1,Y1) to (X2,Y2).
 * @param DATA The resulting game data after the protocol execution.
 */


atom_protocol(TranslatedMatrix,'As you kick the door, it crashes open!', Last_Moves, GameOver, Game):-
    py_call(prolog_gui:output_text('NEW Atom Protocol: Door crashed! - end','',Game)),
    atom_protocol(TranslatedMatrix,'The door opens.', Last_Moves, GameOver, Game).

atom_protocol(TranslatedMatrix,'WHAMMM!!!', Last_Moves, GameOver, Game):-
    py_call(prolog_gui:output_text('NEW Atom Protocol: Door is still locked, Kick it Again!','',Game)),
    atom_protocol(TranslatedMatrix,'This door is locked.', Last_Moves, GameOver, Game).

atom_protocol(TranslatedMatrix,'This door is locked.',[(X1,Y1),(X2,Y2)],GameOver,Game):-
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    format('NEW Atom Protocol: Door is locked, Kick it! ~n'),
    py_call(prolog_gui:output_text('NEW Atom Protocol: Door is locked, Kick it!','',Game)),
    move('_KICK_',Game,_),
    move(Move, Game, TempGameOver_py),
    truth_val(TempGameOver_py,false),
    get_info_from_env(Game,_,Message,_,_,_,_,_),
    get_message(Message,Atom),
    atom_protocol(TranslatedMatrix,Atom,[(X1,Y1),(X2,Y2)],GameOver,Game).

atom_protocol(TranslatedMatrix,'The door resists!',[(X1,Y1),(X2,Y2)],GameOver,Game):-
    format('Atom Protocol: Door Resists! ~n'),
    py_call(prolog_gui:output_text('Atom Protocol: Door Resists! - Try again','',Game)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    move(Move, Game ,TempGameOver_py),
    truth_val(TempGameOver_py,false),
    get_info_from_env(Game,_,Message,_,_,_,_,_),
    get_message(Message,Atom),
    atom_protocol(TranslatedMatrix,Atom,[(X1,Y1),(X2,Y2)],GameOver,Game).

%%the data being propagated to the beginning might not be the most updated.

atom_protocol(_,'The door opens.',[(X1,Y1),(X2,Y2)],GameOver,Game):-
    format('Atom Protocol: The door opened! ~n'),
    py_call(prolog_gui:output_text('Atom Protocol: The door opened! - end','',Game)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    move(Move,Game,GameOver_py_Temp),
    truth_val(GameOver_py_Temp,GameOver_Temp),
    confirm_step(X1,Y1,X2,Y2,Game,GameOver_Temp),
    isOnce(X2,Y2),
    move(Move,Game,GameOver_py),                    %hotfix, one step over the door
    truth_val(GameOver_py,GameOver),
    isWayback(X2,Y2).

atom_protocol(_,_,_,_,GameOver,Game):-
    format('Atom Protocol Failsafe, got an unexpected message. ~n'),
    py_call(prolog_gui:output_text('Atom Protocol Failsafe - Unexpected Message Received - end','',Game)),
    move('_SEARCH_', Game, GameOver_py),
    truth_val(GameOver_py,false),
    GameOver = false.

atom_protocol(_,_,_,_,true,_).



/**
 * Protocol for executing actions based on game objectives, checking if the goal is not blocked.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current objective.
 * @param DATA The resulting game data after executing the pick protocol.
 */

pick_protocol(_,'quit',[],Game,GameOver):-
    move('_QUIT_',Game,GameOver).

pick_protocol(TranslatedMatrix,'The door opens.', Last_Moves, Game, GameOver):-
    atom_protocol(TranslatedMatrix,'The door opens.', Last_Moves, GameOver, Game).

pick_protocol(TranslatedMatrix,'door',[(X1,Y1),(X2,Y2)],Game,GameOver):-
    format('Protocol Call: Closed Door ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Closed Door','',Game)),
    Move_X is X2 - X1,
    Move_Y is Y2 - Y1,
    move_py(Move_X,Move_Y,Move),
    move(Move, Game, GameOver_py),
    truth_val(GameOver_py,false),
    get_info_from_env(Game,_,Message,_,_,_,_,_),
    get_message(Message,Atom),
    format('Message: ~w ~n',[Atom]),
    atom_protocol(TranslatedMatrix,Atom,[(X1,Y1),(X2,Y2)],GameOver,Game).


pick_protocol(TranslatedMatrix,'combat', Last_Moves, Game, GameOver):-
    format('Protocol Call: Monster Combat ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Monster Combat','',Game)),
    protocol(TranslatedMatrix,'combat',Last_Moves,GameOver,Game).

pick_protocol(TranslatedMatrix,Action, Last_Moves, Game, GameOver):-
    protocol(TranslatedMatrix,Action,Last_Moves,GameOver,Game).

pick_protocol(_,_,_,_,true).