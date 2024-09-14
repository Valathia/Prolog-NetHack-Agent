% action list
/**
 * Executes a step in the environment based on the given action.

 * @param ENV The game environment object.
 * @param RES The result after performing the step.
 */
move('_STOP_', Game, RES):-         py_call(Game:prolog_move("s"), RES) .
move('_N_',Game, RES):-             py_call(Game:prolog_move("[8]"),  RES) .
move('_NE_',Game, RES):-            py_call(Game:prolog_move("[9]"),  RES) .
move('_E_',Game, RES):-             py_call(Game:prolog_move("[6]"),  RES) .
move('_SE_',Game, RES):-            py_call(Game:prolog_move("[3]"),  RES) .
move('_S_',Game, RES):-             py_call(Game:prolog_move("[2]"),  RES) .
move('_SW_',Game, RES):-            py_call(Game:prolog_move("[1]"),  RES) .
move('_W_',Game, RES):-             py_call(Game:prolog_move("[4]"),  RES) .
move('_NW_',Game, RES):-            py_call(Game:prolog_move("[7]"),  RES) .
move('_UP_',Game, RES):-            py_call(Game:prolog_move("up"),  RES) .
move('_DOWN_',Game, RES):-          py_call(Game:prolog_move("down"), RES) .
move('_WAIT_',Game, RES):-          py_call(Game:prolog_move("."), RES) .
move('_OPEN_',Game, RES):-          py_call(Game:prolog_move("o"), RES) .
move('_KICK_',Game, RES):-          py_call(Game:prolog_move("K"), RES) .
move('_SEARCH_',Game, RES):-        py_call(Game:prolog_move("s"), RES) .
move('_EAT_',Game, RES):-           py_call(Game:prolog_move("e"), RES) .
move('_ESC_',Game,RES):-            py_call(Game:prolog_move("backspace"), RES) .
move('_INV_',Game,RES):-            py_call(Game:prolog_move("i"), RES) .
move('_QUAFF_',Game,RES):-          py_call(Game:prolog_move("q"), RES) .
move('_PICKUP_',Game,RES):-         py_call(Game:prolog_move("[+]"), RES) .
move('_APPLY_',Game,RES):-          py_call(Game:prolog_move("a"), RES) .
move('_CAST_',Game,RES):-           py_call(Game:prolog_move("Z"), RES) .
move('_CLOSE_',Game,RES):-          py_call(Game:prolog_move("c"), RES) .
move('_DROP_',Game,RES):-           py_call(Game:prolog_move("d"), RES) .
move('_FIRE_',Game,RES):-           py_call(Game:prolog_move("f"), RES) .
move('_MOVE_',Game,RES):-           py_call(Game:prolog_move("m"), RES) .
move('_PAY_',Game,RES):-            py_call(Game:prolog_move("p"), RES) .
move('_PUTON_',Game,RES):-          py_call(Game:prolog_move("P"), RES) .
move('_READ_',Game,RES):-           py_call(Game:prolog_move("r"), RES) .
move('_REMOVE_',Game,RES):-         py_call(Game:prolog_move("R"), RES) .
move('_RUSH_',Game,RES):-           py_call(Game:prolog_move("g"), RES) .
move('_SWAP_',Game,RES):-           py_call(Game:prolog_move("x"), RES) .
move('_TAKEOFF_',Game,RES):-        py_call(Game:prolog_move("T"), RES) .
move('_TAKEOFFALL_',Game,RES):-     py_call(Game:prolog_move("A"), RES) .
move('_THROW_',Game,RES):-          py_call(Game:prolog_move("t"), RES) .
move('_TWOWEAPON_',Game,RES):-      py_call(Game:prolog_move("X"), RES) .
move('_VERSIONSHORT_',Game,RES):-   py_call(Game:prolog_move("v"), RES) .
move('_WEAR_',Game,RES):-           py_call(Game:prolog_move("W"), RES) .
move('_WIELD_',Game,RES):-          py_call(Game:prolog_move("w"), RES) .
move('_ZAP_',Game,RES):-            py_call(Game:prolog_move("z"), RES) .
move('_HISTORY_',Game,RES):-        py_call(Game:prolog_move("V"), RES) .
move('_PRAY_',Game,RES):-           py_call(Game:prolog_move("ctrl+p"), RES) .
move('_QUIT_',Game,RES):-           py_call(Game:prolog_move("ctrl+q"), RES) .


letter_to_action("a",'_APPLY_').
letter_to_action("b",'_SW_').
letter_to_action("c",'_CLOSE_').
letter_to_action("d",'_DROP_').
letter_to_action("e",'_EAT_').
letter_to_action("f",'_FIRE_').
letter_to_action("g",'_RUSH_').
letter_to_action("h",'_W_').
letter_to_action("i",'_INV_').
letter_to_action("j",'_S_').
letter_to_action("k",'_N_').
letter_to_action("l",'_E_').
letter_to_action("m",'_MOVE_').
letter_to_action("n",'_SE_').
letter_to_action("o",'_OPEN_').
letter_to_action("p",'_PAY_').
letter_to_action("q",'_QUAFF_').
letter_to_action("r",'_READ_').
letter_to_action("s",'_SEARCH_').
letter_to_action("t",'_THROW_').
letter_to_action("u",'_NE_').
letter_to_action("v",'_VERSIONSHORT_').
letter_to_action("w",'_WIELD_').
letter_to_action("x",'_SWAP_').
letter_to_action("y",'_NW_').
letter_to_action("z",'_ZAP_').