% added for the benifit of the syntax tool
:- consult('./utility.pl').

/**
 * Recursively pushes a boulder down a tunnel untill it reaches a dead end and cannot make further movements.
 *
 * @param ENV The game environment.
 * @param [(X1,Y1),(X2,Y2)|T] The list of coordinates representing the movement path.
 * @param GOAL The current goal or objective.
 * @param DATA The resulting game data after pushing the boulder untill it reaches a dead end.
 */
% boulder_protocol(ENV,[(X1,Y1),(X2,Y2)],GOAL,DATA,GAME):-
%     format('BOULDER PROTOCOL ~n'),
%     py_call(prolog_gui:output_text('BOULDER PROTOCOL','',GAME)),
%     MOVE_X is X2 - X1,
%     MOVE_Y is Y2 - Y1,
%     move_py(MOVE_X,MOVE_Y,ACTION),
%     move(ACTION,GAME, TEMP_DATA),
%     %renderMap(ENV),
%     confirm_step_door(TEMP_DATA,X2,Y2,GAME),
%     asserta(wayback(X1,Y1)),
%     NEWX2 is X2 + MOVE_X,
%     NEWY2 is Y2 + MOVE_Y,
%     boulder_protocol(ENV,[(X2,Y2),(NEWX2,NEWY2)],GOAL,DATA,GAME).


% /**
%  * When comfirm_step_door fails, the player should stop pushing the boulder and unify the Data parameter. 
%  *
%  * @param ENV The game environment.
%  * @param [(_,_),(X2,Y2)|T] The list of coordinates representing the movement path.
%  * @param DATA The resulting game data after pushing the boulder untill it reaches a dead end.
%  */
% boulder_protocol(_,[(_,_),(X2,Y2)],_,DATA,GAME):-
%     format('Boulder Protocol Lock Boulder - Search End ~n'),
%     py_call(prolog_gui:output_text('Boulder Protocol Lock Boulder - Search End - theres a retract here','',GAME)),
%     asserta(locked(X2,Y2)),
%     retractall(wayback(_,_)),
%     move('_SEARCH_', GAME,DATA).


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