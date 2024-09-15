% added for the benifit of the syntax tool
% :- include('./actions.pl').
% :- include('./protocols.pl').
% :- include('./codes.pl').
%:- consult('./protocols.pl').
:- consult('./utility.pl').


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