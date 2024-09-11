/**
 * Door status in the game environment.
 */
door_opened('doorop').
door_opened('passage').
door_opened('food').
door_opened('stairsdown').
closed_door('door').



/**
 * Base case for isOnce/2 when a door has not been yet used. Assers the door as seen.
 *
 * @param X The X coordinate of the path.
 * @param Y The Y coordinate of the path.
 */

isOnce(X,Y):- 
    \+ once(X,Y),
    asserta(once(X,Y)).

/**
 * Predicate to lock a door. After a door has been passed through at least twice, it's taken off the objectives list. 
 *
 * @param X The X coordinate of the path.
 * @param Y The Y coordinate of the path.
 */

isOnce(X,Y):- 
    once(X,Y),
    retract(once(X,Y)),
    asserta(soft_lock(X,Y)).

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
    asserta(floor_once(X,Y)).

/**
 * If a floortunnel tile has been used once, it retracts that fact and asserts it's been done twice. 
 *
 * @param X The X coordinate of the path.
 * @param Y The Y coordinate of the path.
 */
isFloorOnce(X,Y):-
    floor_once(X,Y),
    retract(floor_once(X,Y)),
    asserta(floor_twice(X,Y)).

/**
 * If a floortunnel tile has been used twice, it retracts that fact and asserts it as locked, removing it from the objectives list, however it remains as a tile that can be traversed.
 *
 * @param X The X coordinate of the path.
 * @param Y The Y coordinate of the path.
 */
isFloorOnce(X,Y):-
    floor_twice(X,Y),
    retract(floor_twice(X,Y)),
    asserta(floor_locked(X,Y)).

isFloorOnce(X,Y):- floor_locked(X,Y).
/**
 * Handles the protocol for interacting with a closed door.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The coordinates representing the movement path from (X1,Y1) to (X2,Y2).
 * @param DATA The resulting game data after the protocol execution.
 */
closed_door_protocol(ENV,[(X1,Y1),(X2,Y2)],DATA,GAME):-
    format('Closed Door Protocol: Break it! ~n'),
    py_call(prolog_gui:output_text('Closed Door Protocol: Break it!','',GAME)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move('_KICK_',ENV,GAME,_),
    %%renderMap(ENV),
    move(ACTION, ENV, GAME,TEMP_DATA),
    %renderMap(ENV),
    get_info_from_map(TEMP_DATA, OBS, _, _, _),
    translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),
    get_elem(TRANSLATED_MATRIX,X2,Y2,ELEM),
    closed_door_protocol_1(ENV,[(X1,Y1),(X2,Y2)],ACTION,ELEM,DATA,GAME).


/**
 * Executes a protocol when encountering a closed door in the game environment.
 * If the door is not closed, attempts to move according to the provided action.
 *
 * @param ENV The current game environment.
 * @param Path A list of coordinates representing the path to the closed door, [(_, _), (X2, Y2)].
 * @param ACTION The action to perform in order to attempt to open the door.
 * @param ELEM The element at position (X2, Y2) in the game environment.
 * @param DATA Additional data associated with the action execution.
 */
closed_door_protocol_1(ENV,[(_,_),(X2,Y2)],ACTION,ELEM,DATA,GAME):-
    format('Closed Door Protocol_1: Door Broke, new protocol! ~n'),
    py_call(prolog_gui:output_text('Closed Door Protocol_1: Door Broke, new protocol!','',GAME)),
    \+ closed_door(ELEM),
    move(ACTION, ENV,GAME, _),
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,ELEM,DATA,GAME).


/**
 * Executes a protocol when encountering a closed door that couldn't be opened.
 * Marks the door as locked and continues searching for alternative paths.
 *
 * @param ENV The current game environment.
 * @param Path A list of coordinates representing the path to the closed door, [(_, _), (X2, Y2)].
 * @param ELEM The element at position (X2, Y2) in the game environment.
 * @param DATA Additional data associated with the action execution.
 */
closed_door_protocol_1(ENV,[(_,_),(X2,Y2)],_,ELEM,DATA,GAME):-
    format('Closed Door Protocol_1: Door didnt break, LOCK ~n'),
    py_call(prolog_gui:output_text('Closed Door Protocol_1: Door didnt break, LOCK','',GAME)),
    closed_door(ELEM),
    asserta(locked(X2,Y2)),
    retractall(wayback(_,_)),
    move('_SEARCH_', ENV, GAME,DATA).

/**
 * Failsafe for closed_door_protocol_1 in case retract fails. 
 *
 * @param ENV The current game environment.
 * @param Path A list of coordinates representing the path to the closed door, [(_, _), (X2, Y2)].
 * @param ELEM The element at position (X2, Y2) in the game environment.
 * @param DATA Additional data associated with the action execution.
 */
closed_door_protocol_1(ENV,[(_,_),(_,_)],_,ELEM,DATA,GAME,GAME):-
    format('Closed Door Protocol_1: Failsafe - Search End ~n'),
    py_call(prolog_gui:output_text('Closed Door Protocol_1: Failsafe - Search End','',GAME)),
    closed_door(ELEM),
    move('_SEARCH_', ENV, GAME,DATA).


end_execute_action_tunnel(ENV,DATA,GAME) :-
    move('_SEARCH_', ENV,GAME, DATA).



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
    move(ACTION, ENV,GAME, TEMP_DATA),
    %renderMap(ENV),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION,GAME),
    %retract(wayback(_,_)),
    asserta(wayback(X1,Y1)),
    isFloorOnce(X1,Y1),
    protocol(ENV,(X2,Y2),ACTION,GOAL,DATA,GAME).


execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], _, DATA,GAME):- 
    format('Execute_action: TUNNEL Last Two Moves - FAILSAFE Retract FAIL (hopefully) ~n'),
    py_call(prolog_gui:output_text('Execute_action: TUNNEL Last Two Moves - FAILSAFE Retract FAIL (hopefully)','',GAME)),
    %pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)], GOAL, GOAL, DATA).
    move('_SEARCH_', ENV, GAME,TEMP_DATA),
    confirm_step_door(TEMP_DATA,X2,Y2,GAME),
    asserta(wayback(X1,Y1)),
    isFloorOnce(X1,Y1),
    end_execute_action_tunnel(ENV,DATA).

execute_action_tunnel(ENV, [(_,_),(_,_)], _, DATA,GAME):-
    format('Execute_action: TUNNEL Last Two Moves - FAILSAFE BIG FAIL (couldnt confirm move) - Terminate ~n'),
    py_call(prolog_gui:output_text('Execute_action: TUNNEL Last Two Moves - FAILSAFE BIG FAIL (couldnt confirm move) - Terminate','',GAME)),
    move('_SEARCH_', ENV,GAME, DATA).



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
    move(ACTION, ENV, GAME,TEMP_DATA),
    %renderMap(ENV),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION,GAME),
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
    move('_SEARCH_', ENV,GAME, TEMP_DATA),
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
tunneling_protocol(ENV,DATA,GAME):-
    format('Tunneling failsafe, dont retract all - End ~n'),
    py_call(prolog_gui:output_text('Tunneling failsafe, dont retract all - End','',GAME)),
    move('_SEARCH_', ENV,GAME, DATA).
    %retractall(wayback(_,_)).


/**
 * Handles going down the stairs in the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down the stairs.
 */
go_down_stairs(ENV,DATA,GAME):-
    format('Go Down Stairs Protocol - RETRACT ALL . End ~n'),
    py_call(prolog_gui:output_text('Go Down Stairs Protocol - RETRACT ALL . End','',GAME)),
    move('_DOWN_',ENV,GAME,DATA),
    retractall(wayback(_,_)),
    retractall(once(_,_)),
    retractall(locked(_,_)),   
    retractall(floor_once(_,_)),
    retractall(floor_twice(_,_)),
    retractall(floor_locked(_,_)),
    retractall(edge(_,_,_)).
    %%renderMap(ENV).

/**
 * Handles Eating items on the floor in the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down the stairs.
 */
eat_protocol(ENV,DATA,GAME):-
    format('Eat Protocol . End ~n'),
    py_call(prolog_gui:output_text('Eat Protocol . End - has a retract','',GAME)),
    %retractall(wayback(_,_)),
    move('_EAT_',ENV,GAME,_),
    move('_NW_', ENV, GAME,DATA).
    %renderMap(ENV).

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
    move(ACTION, ENV,GAME, TEMP_DATA),
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
boulder_protocol(ENV,[(_,_),(X2,Y2)],_,DATA,GAME):-
    format('Boulder Protocol Lock Boulder - Search End ~n'),
    py_call(prolog_gui:output_text('Boulder Protocol Lock Boulder - Search End - theres a retract here','',GAME)),
    asserta(locked(X2,Y2)),
    retractall(wayback(_,_)),
    move('_SEARCH_', ENV,GAME,DATA).

/**
 * Protocol for handling movement down stairs in the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down stairs.
 */
protocol(ENV,_,_,'stairsdown',DATA,GAME):-
    format('Protocol Call: Go Down Stairs ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Go Down Stairs','',GAME)),
    go_down_stairs(ENV,DATA,GAME).

/**
 * Protocol for handling eating from the floor of the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down stairs.
 */
protocol(ENV,_,_,'food',DATA,GAME):-
    format('Protocol Call: Eat Protocol ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Eat Protocol','',GAME)),
    eat_protocol(ENV,DATA,GAME).

protocol(ENV,_,_,'monster',DATA,GAME):-
    format('Protocol Call: Monster ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Monster','',GAME)),
    %retractall(wayback(_,_)),
    move('_SEARCH_', ENV,GAME, DATA).

protocol(ENV,_,_,'monster',DATA,GAME):-
    format('Protocol Call: FAILSAFE Monster ~n'),
    py_call(prolog_gui:output_text('Protocol Call: FAILSAFE Monster - retract all probably failed','',GAME)),
    retract(wayback(_,_)),
    move('_SEARCH_', ENV,GAME, DATA).

protocol(ENV,_,_,'monster',DATA,GAME):-
    format('Protocol Call: FAILSAFE 2 Monster ~n'),
    py_call(prolog_gui:output_text('Protocol Call: FAILSAFE 2 Monster - retract probably failed.','',GAME)),
    move('_SEARCH_', ENV, GAME,DATA).

protocol(ENV,(X,Y),ACTION,'floortunel',DATA,GAME):-
    format('Protocol Call: floortunel - Tunneling  ~n'),
    py_call(prolog_gui:output_text('Protocol Call: floortunel - Tunneling','',GAME)),
    move(ACTION,ENV,GAME,_),
    %renderMap(ENV),
    asserta(wayback(X,Y)),
    isOnce(X,Y),
    tunneling_protocol(ENV,DATA,GAME).

/**
 * Protocol for handling passages and opened doors, taking a step further into the tunnel/room and marking the door as a visited space to disallow imediate backtrack. 
 *
 * @param ENV The game environment.
 * @param (X,Y) The coordinates of the door/passage.
 * @param ACTION The action to be performed.
 * @param GOAL The current objective.
 * @param DATA The resulting game data after handling the blocked door.
 */
protocol(ENV,(X,Y),ACTION,GOAL,DATA,GAME):-
    format('Protocol Call: Open Door/ Passage - Tunneling: ~w  ~n',[GOAL]),
    py_call(prolog_gui:output_text('Protocol Call: Open Door/ Passage - Tunneling','',GAME)),
    door_opened(GOAL),
    %retractall(wayback(_,_)),
    move(ACTION,ENV,GAME,_),
    %renderMap(ENV),
    asserta(wayback(X,Y)),
    isOnce(X,Y),
    tunneling_protocol(ENV,DATA,GAME).

/**
 * Failsafe for the regular protocol in case retract fails. 
 *
 * @param ENV The game environment.
 * @param (X,Y) The coordinates of the door/passage.
 * @param ACTION The action to be performed.
 * @param GOAL The current objective.
 * @param DATA The resulting game data after handling the blocked door.
 */
protocol(ENV,_,_,_,DATA,GAME):-
    format('Protocol Call: Fail safe Tunneling ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Fail safe Tunneling','',GAME)),
    retractall(wayback(_,_)),
    tunneling_protocol(ENV,DATA,GAME).

/**
 * Failsafe protocol when retracting the last position due to protocol failure.
 *
 * @param ENV The game environment.
 * @param (X,Y) The coordinates to retract.
 * @param DATA The resulting game data after retracting the position.
 */
protocol(ENV,_,_,_,DATA,GAME):-
    format('Protocol Call: failsafe retract wayback - search_end ~n'),
    py_call(prolog_gui:output_text('Protocol Call: failsafe retract wayback - search_end','',GAME)),
    retract(wayback(_,_)),
    move('_SEARCH_', ENV, GAME,DATA).

/**
 * Secondary failsafe protocol when all primary protocols fail.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after returning to search mode.
 */
protocol(ENV,_,_,_,DATA,GAME):-
    format('Protocol Call: failsafe 2 - search_end ~n'),
    py_call(prolog_gui:output_text('Protocol Call: failsafe 2 - search_end','',GAME)),
    move('_SEARCH_', ENV,GAME, DATA).


/**
 * Protocol for executing actions based on game objectives, ensuring the player moves into the objective cell.
 * This version handles objectives that are closed doors, attempting to open the door first.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current objective.
 * @param ELEM The element at (X2,Y2).
 * @param DATA The resulting game data after executing the pick protocol.
 */


pick_protocol_2(ENV,_,'fail',_,DATA,GAME):-
    format('Pick_Protocol_2: FAIL - Failsafe into Return ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: FAIL - Failsafe into Return','',GAME)),
    retractall(wayback(_,_)),
    move('_SEARCH_', ENV, GAME,DATA).
    %closed_door_protocol(ENV,[(X1,Y1),(X2,Y2)],DATA).


pick_protocol_2(ENV,_,'fail',_,DATA,GAME):-
    format('Pick_Protocol_2: FAIL TM - retract all failed, Failsafe into Return ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: FAIL TM - retract all failed, Failsafe into Return','',GAME)),
    move('_SEARCH_', ENV, GAME,DATA).

pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'door',_,DATA,GAME):-
    format('Pick_Protocol_2: Closed Door  ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Closed Door','',GAME)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    %renderMap(ENV),
    move(ACTION, ENV, GAME,TEMP_DATA),
    move(ACTION, ENV,GAME, TEMP_DATA),                       %if door was closed it needs 2 moves to get into the proper spot
    confirm_step_door(TEMP_DATA,X2,Y2,GAME),
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,'passage',DATA,GAME).        %if the door opened, the new glyph is now an open door or passage , protocol picked will be passage

/**
 * Protocol for executing actions based on game objectives when encountering closed doors that won't open.
 * This version kicks the door to attempt opening it.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current objective.
 * @param ELEM The element at (X2,Y2).
 * @param DATA The resulting game data after executing the pick protocol.
 */
pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'door',_,DATA,GAME):-
    format('Pick_Protocol_2: Closed Door - Didnt open ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Closed Door - Didnt open','',GAME)),
    closed_door_protocol(ENV,[(X1,Y1),(X2,Y2)],DATA,GAME).                   %if door failed to open closed_door_protocol needs to be called (to kick it)

/**
 * Protocol for executing actions based on game objectives when encountering boulders.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current objective.
 * @param ELEM The element at (X2,Y2).
 * @param DATA The resulting game data after executing the pick protocol.
 */

pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'boulder',_,DATA,GAME):-
    format('Pick_Protocol_2: Boulder ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Boulder','',GAME)),
    boulder_protocol(ENV,[(X1,Y1),(X2,Y2)],'boulder',DATA,GAME).


pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'monster',_,DATA,GAME):-
    format('Pick_Protocol_2: Monster ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Monster','',GAME)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, ENV, GAME,TEMP_DATA),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION,GAME),               %confirming the step when it's a monster ensures the agent will try to kill the monster, when they're able to step in the same square it means the monster died
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,'monster',DATA,GAME).
    %pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'fail',_,DATA).


/**
 * Protocol for executing actions based on game objectives, ensuring the player moves into the objective cell.
 * This version handles objectives that are not closed doors.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current objective.
 * @param ELEM The element at (X2,Y2).
 * @param DATA The resulting game data after executing the pick protocol.
 */


pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,_,DATA,GAME):-
    format('Pick_Protocol_2: Opened Door, Passages, Food and Stairdown  ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Opened Door, Passages, Food and Stairdown','',GAME)),
    door_opened(GOAL),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, ENV, GAME,TEMP_DATA),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION,GAME),
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,GOAL,DATA,GAME).

pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,_,DATA,GAME):-
    format('Pick_Protocol_2: Failsafe Goal ~w ~n',[GOAL]),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Failsafe Goal - no goal defined for action','',GAME)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, ENV, GAME,TEMP_DATA),
    confirm_step_door(TEMP_DATA,X2,Y2,GAME),
    asserta(floor_locked(X2,Y2)),
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,GOAL,DATA,GAME),!;
    pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'fail',_,DATA,GAME).



/**
 * Protocol for executing actions based on game objectives, checking if the goal is not blocked.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current objective.
 * @param DATA The resulting game data after executing the pick protocol.
 */

% pick_protocol(ENV,[(X1,Y1),(X2,Y2)], GOAL,DATA):-
%         move('_SEARCH_', ENV, TEMP_DATA),           %does a search to get new data
%         get_info_from_map(TEMP_DATA, OBS, _, _, _), %gets info from map
%         translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),   
%         get_elem(TRANSLATED_MATRIX,X2,Y2,GOAL),                 %gets glyph in square to check what objective it is (the objective might have moved (monsters or items, something could be in the way as well))
%         pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,GOAL,DATA). %picks protocol propper

%if check fails - if it's the pet doesn't matter go
% pick_protocol(ENV,[(X1,Y1),(X2,Y2)], GOAL,DATA):-
%         move('_SEARCH_', ENV, TEMP_DATA),           %does a search to get new data
%         get_info_from_map(TEMP_DATA, OBS, _, _, _), %gets info from map
%         translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),   
%         get_elem(TRANSLATED_MATRIX,X2,Y2,'pet'),                 %gets glyph in square to check what objective it is (the objective might have moved (monsters or items, something could be in the way as well))
%         pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,'pet',DATA). %picks protocol propper

% pick_protocol(ENV,[(X1,Y1),(X2,Y2)], GOAL,DATA):-
%         move('_SEARCH_', ENV, TEMP_DATA),           %does a search to get new data
%         get_info_from_map(TEMP_DATA, OBS, _, _, _), %gets info from map
%         translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),   
%         get_elem(TRANSLATED_MATRIX,X2,Y2,'monster'),                 %gets glyph in square to check what objective it is (the objective might have moved (monsters or items, something could be in the way as well))
%         pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,'monster',DATA). %picks protocol propper

pick_protocol(_,[],_,_,_).

pick_protocol(ENV,[(X1,Y1),(X2,Y2)],GOAL,DATA,GAME):-
        %move('_SEARCH_', ENV, TEMP_DATA),           %does a search to get new data
        %get_info_from_map(TEMP_DATA, OBS, _, _, _), %gets info from map
        %translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),   
        %get_elem(TRANSLATED_MATRIX,X2,Y2,ELEM),                 %gets glyph in square to check what objective it is (the objective might have moved (monsters or items, something could be in the way as well))
        format('sanity check - pick protocol'),
        py_call(prolog_gui:output_text('Picking protocol for Goal: ','??', GAME)),
        pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,GOAL,DATA,GAME). %picks protocol propper

pick_protocol(ENV, ACTION_LIST, GOAL, DATA, GAME):-
    format('is the problem here?'),
    execute_action(ENV, ACTION_LIST, GOAL, DATA, GAME).
%goal and ELEM should be the same but are currently not being checked against each other due to variance - if it's a monster or a pet on top of the goal it doesn't matter go anyway