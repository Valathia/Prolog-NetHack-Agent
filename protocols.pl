% added for the benifit of the syntax tool
:- consult('./utility.pl').


protocol(_,'stairsdown',Game):-
    %format('Go Down Stairs Protocol - RETRACT ALL . End ~n'),
    py_call(prolog_gui:output_text('Go Down Stairs Protocol - Retract current floor Objects ','',Game)),
    move('_DOWN_',Game,GameOver_py),
    truth_val(GameOver_py,_),
    retractall(wayback(_,_)),
    retractall(once(_,_)),
    retractall(locked(_,_)),   
    retractall(floor_once(_,_)),
    retractall(floor_twice(_,_)),
    retractall(floor_locked(_,_)),
    retractall(soft_lock(_,_)),
    retractall(edge(_,_,_)),
    retractall(disconect_edge(_,_)).



/**
 * Protocol for handling eating from the floor of the game environment.
 *
 * @param ENV The game environment.
 * @param DATA The resulting game data after going down stairs.
 */

protocol(_,'eat_food',Game):-
    %format('Eat Protocol . End ~n'),
    py_call(prolog_gui:output_text('Eat Protocol. ','',Game)),
    move('_EAT_',Game,_),
    letter_to_action("y",Move),
    move(Move,Game,GameOver_py),
    truth_val(GameOver_py,_).

protocol(_,'food_pickup',Game):-
    %format('Takeout . End ~n'),
    py_call(prolog_gui:output_text('Takeout. ','',Game)),
    move('_PICKUP_',Game,GameOver_py),
    truth_val(GameOver_py,_).


protocol(_,_,Game):-
    %format('~w Protocol End ~n',[Action]),
    move('_SEARCH_',Game,GameOver_py),
    truth_val(GameOver_py,_).

protocol(_,_,_).

%use feedback to know if monster is killed
protocol(TranslatedMatrix,'combat',[(X1,Y1),(X2,Y2)],Game):-
    %format('Combat Protocol . End ~n'),
    py_call(prolog_gui:output_text('Hit the Monster! ','',Game)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    move(Move, Game, TempGameOver_py),
    truth_val(TempGameOver_py,_),
    get_info_from_env(Game, _, Message, _, _, InQuestion, _, _),
    check_mishap(InQuestion, Game),
    ((check_sub(Message,'You kill');check_sub(Message,'You destroy')),
    %format('You kill the monster! ~n');
    % confirm_step(X1,Y1,X2,Y2,Game,TempGameOver),
    % GameOver = TempGameOver;
    protocol(TranslatedMatrix,'combat',Game)).

protocol(TranslatedMatrix,'combat',[],Game):-
    %format('Combat Protocol . End ~n'),
    py_call(prolog_gui:output_text('Combat with no moves left... ','',Game)),
    move('_SEARCH_', Game, TempGameOver_py),
    truth_val(TempGameOver_py,_),
    get_info_from_env(Game, _, _, _, _, _, _, _),
    protocol(TranslatedMatrix,'combat',Game).

protocol(TranslatedMatrix,Action,[(X1,Y1),(X2,Y2)],Game) :-
    %format('~w Protocol ~n',[Action]),
    %py_call(prolog_gui:output_text(Action,' Protocol',Game)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    move(Move, Game, TempGameOver_py),
    truth_val(TempGameOver_py,_),
    get_info_from_env(Game, _, Message, _, _, InQuestion, _, _),
    check_mishap(InQuestion, Game),
    (check_sub(Message,'can\'t move diagonally'),
    diag_correct(TranslatedMatrix,Move,X1,Y1,NewHead),
    append(NewHead,[(X2,Y2)],NewList),
    execute_path(TranslatedMatrix,NewList, Action, Game),!);
    (confirm_step(X1,Y1,X2,Y2,Game),
    protocol(TranslatedMatrix,Action,Game)).

protocol(_,_,_,_).

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


atom_protocol(TranslatedMatrix,'As you kick the door, it crashes open!', Last_Moves, Game):-
    %py_call(prolog_gui:output_text('Protocol: Door crashed!','',Game)),
    atom_protocol(TranslatedMatrix,'The door opens.', Last_Moves, Game).

atom_protocol(TranslatedMatrix,'WHAMMM!!!', Last_Moves, Game):-
    py_call(prolog_gui:output_text('Protocol: Door is still locked, Kick it Again!','',Game)),
    atom_protocol(TranslatedMatrix,'This door is locked.', Last_Moves, Game).

atom_protocol(TranslatedMatrix,'This door is locked.',[(X1,Y1),(X2,Y2)],Game):-
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    %format('NEW Atom Protocol: Door is locked, Kick it! ~n'),
    py_call(prolog_gui:output_text('Protocol: Door is locked, Kick it!','',Game)),
    move('_KICK_',Game,_),
    move(Move, Game, TempGameOver_py),
    truth_val(TempGameOver_py,false),
    get_info_from_env(Game,_,Message,_,_,_,_,_),
    get_message(Message,Atom),
    atom_protocol(TranslatedMatrix,Atom,[(X1,Y1),(X2,Y2)],Game).

atom_protocol(TranslatedMatrix,'The door resists!',[(X1,Y1),(X2,Y2)],Game):-
    %format('Atom Protocol: Door Resists! ~n'),
    py_call(prolog_gui:output_text('Protocol: Door Resists! - Try again','',Game)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    move(Move, Game ,TempGameOver_py),
    truth_val(TempGameOver_py,false),
    get_info_from_env(Game,_,Message,_,_,_,_,_),
    get_message(Message,Atom),
    atom_protocol(TranslatedMatrix,Atom,[(X1,Y1),(X2,Y2)],Game).

%%the data being propagated to the beginning might not be the most updated.

atom_protocol(_,'The door opens.',[(X1,Y1),(X2,Y2)],Game):-
    %format('Atom Protocol: The door opened! ~n'),
    %py_call(prolog_gui:output_text('Atom Protocol: The door opened! - end','',Game)),
    MOVE_X is X2 - X1,
    MOVE_Y is Y2 - Y1,
    move_py(MOVE_X,MOVE_Y,Move),
    move(Move,Game,GameOver_py_Temp),
    truth_val(GameOver_py_Temp,_),
    confirm_step(X1,Y1,X2,Y2,Game),
    isOnce(X2,Y2),
    move(Move,Game,GameOver_py),                    %hotfix, one step over the door
    truth_val(GameOver_py,_),
    isWayback(X2,Y2).

%Current boulder protocol will only push boulder in 1 direction, could be made better by checking if new objectives are available after pushing
atom_protocol(TranslatedMatrix, 'With great effort you move the boulder.',[(X1,Y1),(X2,Y2)],Game):-
    %format('Atom Protocol: Success! you pushed the boulder ~n'),
    %py_call(prolog_gui:output_text('Protocol: Success! you pushed the boulder ~n','',Game)),
    confirm_step(X1,Y1,X2,Y2,Game),
    Move_X is X2 - X1, 
    Move_Y is Y2 - Y1,
    New_X is X2+Move_X,
    New_Y is Y2+Move_Y,
    move_py(Move_X,Move_Y,Move),
    move(Move,Game,GameOver_py),
    truth_val(GameOver_py,_),
    isOnce(X2,Y2),
    isWayback(X2,Y2),
    get_info_from_env(Game,_,Message,_,_,_,_,_),
    get_message(Message,Atom),
    atom_protocol(TranslatedMatrix,Atom,[(X2,Y2),(New_X,New_Y)],Game).

atom_protocol(_, 'You try to move the boulder, but in vain.',[_,(X2,Y2)],Game):-
   % format('Atom Protocol: Boulder wont move any further T-T ~n'),
    py_call(prolog_gui:output_text('Protocol: Boulder wont move any further... ','',Game)),
    asserta(locked(X2,Y2)).

atom_protocol(_, 'Perhaps that\'s why you cannot move it.',[_,(X2,Y2)],Game):-
    %format('Atom Protocol: Boulder wont move any further T-T ~n'),
    py_call(prolog_gui:output_text('Protocol: Boulder wont move any further... ','',Game)),
    asserta(locked(X2,Y2)).

atom_protocol(_,_,_,_,Game):-
    %format('Atom Protocol Failsafe, got an unexpected message. ~n'),
    py_call(prolog_gui:output_text('Protocol Failsafe - Unexpected Message Received - end','',Game)),
    move('_SEARCH_', Game, GameOver_py),
    truth_val(GameOver_py,false).

atom_protocol(_,_,_,_,_).



pick_protocol(_,'quit',[],Game):-
    move('_QUIT_',Game).

pick_protocol(TranslatedMatrix,'The door opens.', Last_Moves, Game):-
    atom_protocol(TranslatedMatrix,'The door opens.', Last_Moves, Game).

pick_protocol(TranslatedMatrix,'door',[(X1,Y1),(X2,Y2)],Game):-
    %format('Protocol Call: Closed Door ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Closed Door','',Game)),
    Move_X is X2 - X1,
    Move_Y is Y2 - Y1,
    move_py(Move_X,Move_Y,Move),
    move(Move, Game, GameOver_py),
    truth_val(GameOver_py,false),
    get_info_from_env(Game,_,Message,_,_,_,_,_),
    get_message(Message,Atom),
    %format('Message: ~w ~n',[Atom]),
    atom_protocol(TranslatedMatrix,Atom,[(X1,Y1),(X2,Y2)],Game).


pick_protocol(TranslatedMatrix,'push boulder',[(X1,Y1),(X2,Y2)],Game):-
    %format('Protocol Call: Push Boulder ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Push Boulder','',Game)),
    Move_X is X2 - X1,
    Move_Y is Y2 - Y1,
    move_py(Move_X,Move_Y,Move),
    move(Move, Game, GameOver_py),
    truth_val(GameOver_py,false),
    get_info_from_env(Game,_,Message,_,_,_,_,_),
    get_message(Message,Atom),
    %format('Message: ~w ~n',[Atom]),
    atom_protocol(TranslatedMatrix,Atom,[(X1,Y1),(X2,Y2)],Game).


pick_protocol(TranslatedMatrix,'combat', Last_Moves, Game):-
    %format('Protocol Call: Monster Combat ~n'),
    py_call(prolog_gui:output_text('Protocol Call: Monster Combat','',Game)),
    protocol(TranslatedMatrix,'combat',Last_Moves,Game).

pick_protocol(TranslatedMatrix,Action, Last_Moves, Game):-
    protocol(TranslatedMatrix,Action,Last_Moves,Game).

pick_protocol(_,_,_,_).