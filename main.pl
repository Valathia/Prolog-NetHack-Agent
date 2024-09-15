/**
 * This method ensures that the environment term is present so we can run methods such as tty_clear.
 */
ensure_term_environment :-
    (   getenv('TERM', _)
    ->  true  % TERM is already set, do nothing
    ;   setenv('TERM', 'xterm-256color')
    ).

/**
 * The main function that runs the game.
 * Imports the library janus to interact with Python.
 * Imports the library system to access methods to manipulate the terminal.
 * Runs the ensure_term_environment.
 * Consults the necessary files to run the game.
 * Imports nle to have access to the game's functions and executes the gameStart rule to run the game.
 * added import to the gui
 */


%py_add_lib_dir('./app').
% to check for python modules use: py_module_exists(MOD)
% since prolog is being called from python, it can't import the libraries explicitly, it will crash.

main_start(GAME):- 
    use_module(library(janus)), 
    use_module(library(system)), 
    ensure_term_environment, 
    consult('./utility.pl'),
    consult('./protocols.pl'),
    consult('./game_run.pl'),
    gameStart(GAME).