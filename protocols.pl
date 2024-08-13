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
    asserta(locked(X,Y)).

isOnce(X,Y):- 
    locked(X,Y).

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
closed_door_protocol(ENV,[(X1,Y1),(X2,Y2)],DATA):-
    format('Closed Door Protocol: Break it! ~n'),
    py_call(prolog_gui:output_text('Closed Door Protocol: Break it! \n')),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move('_KICK_',ENV,_),
    %renderMap(ENV),
    move(ACTION, ENV, TEMP_DATA),
    %renderMap(ENV),
    get_info_from_map(TEMP_DATA, OBS, _, _, _),
    translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),
    get_elem(TRANSLATED_MATRIX,X2,Y2,ELEM),
    closed_door_protocol_1(ENV,[(X1,Y1),(X2,Y2)],ACTION,ELEM,DATA).


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
closed_door_protocol_1(ENV,[(_,_),(X2,Y2)],ACTION,ELEM,DATA):-
    format('Closed Door Protocol_1: Door Broke, new protocol! ~n'),
    py_call(prolog_gui:output_text('Closed Door Protocol_1: Door Broke, new protocol! \n')),
    \+ closed_door(ELEM),
    move(ACTION, ENV, _),
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,ELEM,DATA).


/**
 * Executes a protocol when encountering a closed door that couldn't be opened.
 * Marks the door as locked and continues searching for alternative paths.
 *
 * @param ENV The current game environment.
 * @param Path A list of coordinates representing the path to the closed door, [(_, _), (X2, Y2)].
 * @param ELEM The element at position (X2, Y2) in the game environment.
 * @param DATA Additional data associated with the action execution.
 */
closed_door_protocol_1(ENV,[(_,_),(X2,Y2)],_,ELEM,DATA):-
    format('Closed Door Protocol_1: Door didnt break, LOCK ~n'),
    py_call(prolog_gui:output_text('Closed Door Protocol_1: Door didnt break, LOCK \n')),
    closed_door(ELEM),
    asserta(locked(X2,Y2)),
    retractall(wayback(_,_)),
    move('_SEARCH_', ENV, DATA).

/**
 * Failsafe for closed_door_protocol_1 in case retract fails. 
 *
 * @param ENV The current game environment.
 * @param Path A list of coordinates representing the path to the closed door, [(_, _), (X2, Y2)].
 * @param ELEM The element at position (X2, Y2) in the game environment.
 * @param DATA Additional data associated with the action execution.
 */
closed_door_protocol_1(ENV,[(_,_),(_,_)],_,ELEM,DATA):-
    format('Closed Door Protocol_1: Failsafe - Search End ~n'),
    py_call(prolog_gui:output_text('Closed Door Protocol_1: Failsafe - Search End \n')),
    closed_door(ELEM),
    move('_SEARCH_', ENV, DATA).


end_execute_action_tunnel(ENV,DATA) :-
    move('_SEARCH_', ENV, DATA).

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

execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], 'door', DATA):-
    format('Execute_action Last Two Moves - Door ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - Door \n')),
    pick_protocol_2(ENV, [(X1,Y1),(X2,Y2)], 'door',' door', DATA).

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

execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], 'passage', DATA):-
    format('Execute_action Last Two Moves - Passage ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - Passage \n')),
    pick_protocol_2(ENV, [(X1,Y1),(X2,Y2)], 'passage', 'passage', DATA).

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
execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], 'doorop', DATA):-
    format('Execute_action Last Two Moves - Open Door ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - Open Door \n')),
    pick_protocol_2(ENV, [(X1,Y1),(X2,Y2)], 'doorop', 'doorop' ,DATA).

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
execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], 'boulder', DATA):-
    format('Execute_action Last Two Moves - BOULDER ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - BOULDER\n')),
    boulder_protocol(ENV,[(X1,Y1),(X2,Y2)],'boulder',DATA).

/**
 * Executes the action to tunnel through blocked floors or obstacles in the game environment.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The coordinates representing the movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current goal or objective.
 * @param DATA The resulting game data after executing the action tunnel.
 */
execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], GOAL, DATA):- 
    format('Execute_action: TUNNEL Last Two Moves ~n'),
    py_call(prolog_gui:output_text('Execute_action Last Two Moves - TUNNEL\n')),
    %pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)], GOAL, GOAL, DATA).
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, ENV, TEMP_DATA),
    %renderMap(ENV),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION),
    %retract(wayback(_,_)),
    asserta(wayback(X1,Y1)),
    isFloorOnce(X1,Y1),
    protocol(ENV,(X2,Y2),ACTION,GOAL,DATA).


execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)], _, DATA):- 
    format('Execute_action: TUNNEL Last Two Moves - FAILSAFE Retract FAIL (hopefully) ~n'),
    py_call(prolog_gui:output_text('Execute_action: TUNNEL Last Two Moves - FAILSAFE Retract FAIL (hopefully)\n')),
    %pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)], GOAL, GOAL, DATA).
    move('_SEARCH_', ENV, TEMP_DATA),
    confirm_step_door(TEMP_DATA,X2,Y2),
    asserta(wayback(X1,Y1)),
    isFloorOnce(X1,Y1),
    end_execute_action_tunnel(ENV,DATA).

execute_action_tunnel(ENV, _, _, DATA):-
    format('Execute_action: TUNNEL Last Two Moves - FAILSAFE BIG FAIL (couldnt confirm move) - Terminate ~n'),
    py_call(prolog_gui:output_text('Execute_action: TUNNEL Last Two Moves - FAILSAFE BIG FAIL (couldnt confirm move) - Terminate\n')),
    move('_SEARCH_', ENV, DATA).

/**
 * Recursively executes the action tunnel for a series of coordinates representing the movement path.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)|T] The list of coordinates representing the movement path.
 * @param GOAL The current goal or objective.
 * @param WORLD_DATA The resulting game data after executing the action tunnel for the entire path.
 */
execute_action_tunnel(ENV, [(X1,Y1),(X2,Y2)|T], GOAL, WORLD_DATA):- 
    format('Execute_action Tunnel List ~n'),
    py_call(prolog_gui:output_text('Execute_action Tunnel List\n')),
    format('(~w,~w) to (~w,~w)',[X1,Y1,X2,Y2]),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, ENV, TEMP_DATA),
    %renderMap(ENV),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION),
    asserta(wayback(X1,Y1)),
    isFloorOnce(X1,Y1),
    execute_action_tunnel(ENV,[(X2,Y2)|T], GOAL, WORLD_DATA).


/**
 * Executes the tunneling protocol to navigate through the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after executing the tunneling protocol.
 */
tunneling_protocol(ENV,DATA):-
    format('Tunneling Protocol - CHOO CHOO ~n'),
    py_call(prolog_gui:output_text('Tunneling Protocol - CHOO CHOO\n')),
    move('_SEARCH_', ENV, TEMP_DATA),
    get_info_from_map(TEMP_DATA, OBS, _, _, _),
    translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),
    get_Player_info(OBS.blstats, POS_COL, POS_ROW, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _),
    get_next_move(TRANSLATED_MATRIX, POS_ROW, POS_COL, GOAL, SOL),
    %get_elem(TRANSLATED_MATRIX,X,Y,GOAL),
    execute_action_tunnel(ENV, SOL, GOAL, DATA).


/**
 * Handles the case when a dead-end is encountered during tunneling.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after handling the dead-end.
 */
tunneling_protocol(ENV,DATA):-
    format('Tunneling failsafe, retract all - End ~n'),
    py_call(prolog_gui:output_text('Tunneling failsafe, retract all - End\n')),
    move('_SEARCH_', ENV, DATA),
    retractall(wayback(_,_)).


/**
 * Handles going down the stairs in the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down the stairs.
 */
go_down_stairs(ENV,DATA):-
    format('Go Down Stairs Protocol - RETRACT ALL . End ~n'),
    py_call(prolog_gui:output_text('Go Down Stairs Protocol - RETRACT ALL . End\n')),
    move('_DOWN_',ENV,DATA),
    retractall(wayback(_,_)),
    retractall(once(_,_)),
    retractall(locked(_,_)),   
    retractall(floor_once(_,_)),
    retractall(floor_twice(_,_)),
    retractall(floor_locked(_,_)).
    %renderMap(ENV).

/**
 * Handles Eating items on the floor in the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down the stairs.
 */
eat_protocol(ENV,DATA):-
    format('Eat Protocol . End ~n'),
    py_call(prolog_gui:output_text('Eat Protocol . End\n')),
    retractall(wayback(_,_)),
    move('_EAT_',ENV,_),
    move('_NW_', ENV, DATA).
    %renderMap(ENV).

/**
 * Recursively pushes a boulder down a tunnel untill it reaches a dead end and cannot make further movements.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)|T] The list of coordinates representing the movement path.
 * @param GOAL The current goal or objective.
 * @param DATA The resulting game data after pushing the boulder untill it reaches a dead end.
 */
boulder_protocol(ENV,[(X1,Y1),(X2,Y2)],GOAL,DATA):-
    format('BOULDER PROTOCOL ~n'),
    py_call(prolog_gui:output_text('BOULDER PROTOCOL\n')),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, ENV, TEMP_DATA),
    %renderMap(ENV),
    confirm_step_door(TEMP_DATA,X2,Y2),
    asserta(wayback(X1,Y1)),
    NEWX2 is X2 + MOVE_X,
    NEWY2 is Y2 + MOVE_Y,
    boulder_protocol(ENV,[(X2,Y2),(NEWX2,NEWY2)],GOAL,DATA).


/**
 * When comfirm_step_door fails, the player should stop pushing the boulder and unify the Data parameter. 
 *
 * @param ENV The game environment.
 * @param [(_,_),(X2,Y2)|T] The list of coordinates representing the movement path.
 * @param DATA The resulting game data after pushing the boulder untill it reaches a dead end.
 */
boulder_protocol(ENV,[(_,_),(X2,Y2)],_,DATA):-
    format('Boulder Protocol Lock Boulder - Search End ~n'),
    py_call(prolog_gui:output_text('Boulder Protocol Lock Boulder - Search End\n')),
    asserta(locked(X2,Y2)),
    retractall(wayback(_,_)),
    move('_SEARCH_', ENV, DATA).

/**
 * Protocol for handling movement down stairs in the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down stairs.
 */
protocol(ENV,_,_,'stairsdown',DATA):-
    format('Protocol Call: Go Down Stairs ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Go Down Stairs \n')),
    go_down_stairs(ENV,DATA).

/**
 * Protocol for handling eating from the floor of the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down stairs.
 */
protocol(ENV,_,_,'food',DATA):-
    format('Protocol Call: Eat Protocol ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Eat Protocol \n')),
    eat_protocol(ENV,DATA).

protocol(ENV,_,_,'monster',DATA):-
    format('Protocol Call: Monster ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Monster \n')),
    retractall(wayback(_,_)),
    move('_SEARCH_', ENV, DATA).

protocol(ENV,_,_,'monster',DATA):-
    format('Protocol Call: FAILSAFE Monster ~n'),
    py_call(prolog_gui:output_text('Protocol Call: FAILSAFE Monster\n')),
    retract(wayback(_,_)),
    move('_SEARCH_', ENV, DATA).

protocol(ENV,_,_,'monster',DATA):-
    format('Protocol Call: FAILSAFE 2 Monster ~n'),
    py_call(prolog_gui:output_text('Protocol Call: FAILSAFE 2 Monster \n')),
    move('_SEARCH_', ENV, DATA).


protocol(ENV,(X,Y),ACTION,'floortunel',DATA):-
    format('Protocol Call: floortunel - Tunneling  ~n'),
    py_call(prolog_gui:output_text('Protocol Call: floortunel - Tunneling  \n')),
    move(ACTION,ENV,_),
    %renderMap(ENV),
    asserta(wayback(X,Y)),
    isOnce(X,Y),
    tunneling_protocol(ENV,DATA).

/**
 * Protocol for handling passages and opened doors, taking a step further into the tunnel/room and marking the door as a visited space to disallow imediate backtrack. 
 *
 * @param ENV The game environment.
 * @param (X,Y) The coordinates of the door/passage.
 * @param ACTION The action to be performed.
 * @param GOAL The current objective.
 * @param DATA The resulting game data after handling the blocked door.
 */
protocol(ENV,(X,Y),ACTION,GOAL,DATA):-
    format('Protocol Call: Open Door/ Passage - Tunneling  ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Open Door/ Passage - Tunneling \n')),
    door_opened(GOAL),
    retractall(wayback(_,_)),
    move(ACTION,ENV,_),
    %renderMap(ENV),
    asserta(wayback(X,Y)),
    isOnce(X,Y),
    tunneling_protocol(ENV,DATA).

/**
 * Failsafe for the regular protocol in case retract fails. 
 *
 * @param ENV The game environment.
 * @param (X,Y) The coordinates of the door/passage.
 * @param ACTION The action to be performed.
 * @param GOAL The current objective.
 * @param DATA The resulting game data after handling the blocked door.
 */
protocol(ENV,_,_,_,DATA):-
    format('Protocol Call: Faill safe Tunneling ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Faill safe Tunneling \n')),
    tunneling_protocol(ENV,DATA).

/**
 * Failsafe protocol when retracting the last position due to protocol failure.
 *
 * @param ENV The game environment.
 * @param (X,Y) The coordinates to retract.
 * @param DATA The resulting game data after retracting the position.
 */
protocol(ENV,_,_,_,DATA):-
    format('Protocol Call: failsafe retract wayback - search_end ~n'),
    py_call(prolog_gui:output_text('Protocol Call: failsafe retract wayback - search_end \n')),
    retract(wayback(_,_)),
    move('_SEARCH_', ENV, DATA).

/**
 * Secondary failsafe protocol when all primary protocols fail.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after returning to search mode.
 */
protocol(ENV,_,_,_,DATA):-
    format('Protocol Call: failsafe 2 - search_end ~n'),
    py_call(prolog_gui:output_text('Protocol Call: failsafe 2 - search_end\n')),
    move('_SEARCH_', ENV, DATA).


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
pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'door',_,DATA):-
    format('Pick_Protocol_2: Closed Door  ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Closed Door\n')),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    %renderMap(ENV),
    move(ACTION, ENV, _),
    move(ACTION, ENV, TEMP_DATA),
    confirm_step_door(TEMP_DATA,X2,Y2),
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,'passage',DATA).

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
pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'door',_,DATA):-
    format(' Pick_Protocol_2: Closed Door - Didnt open ~n'),
    py_call(prolog_gui:output_text(' Pick_Protocol_2: Closed Door - Didnt open \n')),
    closed_door_protocol(ENV,[(X1,Y1),(X2,Y2)],DATA).

/**
 * Protocol for executing actions based on game objectives when encountering boulders.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current objective.
 * @param ELEM The element at (X2,Y2).
 * @param DATA The resulting game data after executing the pick protocol.
 */

pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'boulder',_,DATA):-
    format('Pick_Protocol_2: Boulder ~n'),
    py_call(prolog_gui:output_text(' Pick_Protocol_2: Boulder  \n')),
    boulder_protocol(ENV,[(X1,Y1),(X2,Y2)],DATA).


pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'monster',_,DATA):-
    format('Pick_Protocol_2: Monster ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Monster \n')),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, ENV, TEMP_DATA),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION),
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,'monster',DATA).
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


pick_protocol_2(ENV,_,'fail',_,DATA):-
    format('Pick_Protocol_2: FAIL - Failsafe into Return ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: FAIL - Failsafe into Return \n')),
    retractall(wayback(_,_)),
    move('_SEARCH_', ENV, DATA).
    %closed_door_protocol(ENV,[(X1,Y1),(X2,Y2)],DATA).


pick_protocol_2(ENV,_,'fail',_,DATA):-
    format('Pick_Protocol_2: FAIL TM - retract all failed, Failsafe into Return ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: FAIL TM - retract all failed, Failsafe into Return  \n')),
    move('_SEARCH_', ENV, DATA).

pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,_,DATA):-
    format('Pick_Protocol_2: Opened Door, Passages, Food and Stairdown  ~n'),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Opened Door, Passages, Food and Stairdown   \n')),
    door_opened(GOAL),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, ENV, TEMP_DATA),
    confirm_step(ENV,TEMP_DATA,X2,Y2,ACTION),
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,GOAL,DATA).

pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,_,DATA):-
    format('Pick_Protocol_2: Failsafe Goal ~w ~n',[GOAL]),
    py_call(prolog_gui:output_text('Pick_Protocol_2: Failsafe Goal  \n')),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,ACTION),
    move(ACTION, ENV, TEMP_DATA),
    confirm_step_door(TEMP_DATA,X2,Y2),
    asserta(floor_locked(X2,Y2)),
    %renderMap(ENV),
    protocol(ENV,(X2,Y2),ACTION,GOAL,DATA),!;
    pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],'fail',_,DATA).



/**
 * Protocol for executing actions based on game objectives, checking if the goal is not blocked.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)] The movement path from (X1,Y1) to (X2,Y2).
 * @param GOAL The current objective.
 * @param DATA The resulting game data after executing the pick protocol.
 */
pick_protocol(ENV,[(X1,Y1),(X2,Y2)], GOAL,DATA):-
        move('_SEARCH_', ENV, TEMP_DATA),
        get_info_from_map(TEMP_DATA, OBS, _, _, _),
        translate_glyphs(OBS.glyphs, TRANSLATED_MATRIX),
        get_elem(TRANSLATED_MATRIX,X2,Y2,ELEM),
        pick_protocol_2(ENV,[(X1,Y1),(X2,Y2)],GOAL,ELEM,DATA).