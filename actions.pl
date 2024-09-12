% action list
/**
 * Executes a step in the environment based on the given action.

 * @param ENV The game environment object.
 * @param RES The result after performing the step.
 */
move('_STOP_', GAME, RES):-   py_call(prolog_gui:step('s', GAME), RES), sleep(0.2).
move('_N_',GAME, RES):-       py_call(prolog_gui:step('[8]', GAME),  RES), sleep(0.2).
move('_NE_',GAME, RES):-      py_call(prolog_gui:step('[9]', GAME),  RES), sleep(0.2).
move('_E_',GAME, RES):-       py_call(prolog_gui:step('[6]', GAME),  RES), sleep(0.2).
move('_SE_',GAME, RES):-      py_call(prolog_gui:step('[3]', GAME),  RES), sleep(0.2).
move('_S_',GAME, RES):-       py_call(prolog_gui:step('[2]', GAME),  RES), sleep(0.2).
move('_SW_',GAME, RES):-      py_call(prolog_gui:step('[1]', GAME),  RES), sleep(0.2).
move('_W_',GAME, RES):-       py_call(prolog_gui:step('[4]', GAME),  RES), sleep(0.2).
move('_NW_',GAME, RES):-      py_call(prolog_gui:step('[7]', GAME),  RES), sleep(0.2).
move('_UP_',GAME, RES):-      py_call(prolog_gui:step('up', GAME),  RES), sleep(0.2).
move('_DOWN_',GAME, RES):-    py_call(prolog_gui:step('down', GAME), RES), sleep(0.2).
move('_WAIT_',GAME, RES):-    py_call(prolog_gui:step('.', GAME), RES), sleep(0.2).
move('_OPEN_',GAME, RES):-    py_call(prolog_gui:step('o', GAME), RES), sleep(0.2).
move('_KICK_',GAME, RES):-    py_call(prolog_gui:step('K', GAME), RES), sleep(0.2).
move('_SEARCH_',GAME, RES):-  py_call(prolog_gui:step('s', GAME), RES), sleep(0.2).
move('_EAT_',GAME, RES):-     py_call(prolog_gui:step('e', GAME), RES), sleep(0.2).
move('_ESC_',GAME,RES):-       py_call(prolog_gui:step('backspace', GAME), RES), sleep(0.2).
move('_INV_',GAME,RES):-       py_call(prolog_gui:step('i', GAME), RES), sleep(0.2).
move('_QUAFF_',GAME,RES):-     py_call(prolog_gui:step('q', GAME), RES), sleep(0.2).
move('_PICKUP_',GAME,RES):-    py_call(prolog_gui:step('[+]', GAME), RES), sleep(0.2).
move('_APPLY_',GAME,RES):-    py_call(prolog_gui:step('a', GAME), RES), sleep(0.2).
move('_CAST_',GAME,RES):-    py_call(prolog_gui:step('Z', GAME), RES), sleep(0.2).
move('_CLOSE_',GAME,RES):-    py_call(prolog_gui:step('c', GAME), RES), sleep(0.2).
move('_DROP_',GAME,RES):-    py_call(prolog_gui:step('d', GAME), RES), sleep(0.2).
move('_FIRE_',GAME,RES):-    py_call(prolog_gui:step('f', GAME), RES), sleep(0.2).
move('_MOVE_',GAME,RES):-    py_call(prolog_gui:step('m', GAME), RES), sleep(0.2).
move('_PAY_',GAME,RES):-    py_call(prolog_gui:step('p', GAME), RES), sleep(0.2).
move('_PUTON_',GAME,RES):-    py_call(prolog_gui:step('P', GAME), RES), sleep(0.2).
move('_READ_',GAME,RES):-    py_call(prolog_gui:step('r', GAME), RES), sleep(0.2).
move('_REMOVE_',GAME,RES):-    py_call(prolog_gui:step('R', GAME), RES), sleep(0.2).
move('_RUSH_',GAME,RES):-    py_call(prolog_gui:step('g', GAME), RES), sleep(0.2).
move('_SWAP_',GAME,RES):-    py_call(prolog_gui:step('x', GAME), RES), sleep(0.2).
move('_TAKEOFF_',GAME,RES):-    py_call(prolog_gui:step('T', GAME), RES), sleep(0.2).
move('_TAKEOFFALL_',GAME,RES):-    py_call(prolog_gui:step('A', GAME), RES), sleep(0.2).
move('_THROW_',GAME,RES):-    py_call(prolog_gui:step('t', GAME), RES), sleep(0.2).
move('_TWOWEAPON_',GAME,RES):-    py_call(prolog_gui:step('X', GAME), RES), sleep(0.2).
move('_VERSIONSHORT_',GAME,RES):-    py_call(prolog_gui:step('v', GAME), RES), sleep(0.2).
move('_WEAR_',GAME,RES):-    py_call(prolog_gui:step('W', GAME), RES), sleep(0.2).
move('_WIELD_',GAME,RES):-    py_call(prolog_gui:step('w', GAME), RES), sleep(0.2).
move('_ZAP_',GAME,RES):-    py_call(prolog_gui:step('z', GAME), RES), sleep(0.2).
move('_HISTORY_',GAME,RES):-    py_call(prolog_gui:step('V', GAME), RES), sleep(0.2).
move('_PRAY_',GAME,RES):-    py_call(prolog_gui:step('ctrl+p', GAME), RES), sleep(0.2).
move('_QUIT_',GAME,RES):-    py_call(prolog_gui:step('ctrl+q', GAME), RES), sleep(0.2).

letter_to_action('a','_APPLY_').
letter_to_action('b','_SW_').
letter_to_action('c','_CLOSE_').
letter_to_action('d','_DROP_').
letter_to_action('e','_EAT_').
letter_to_action('f','_FIRE_').
letter_to_action('g','_RUSH_').
letter_to_action('h','_W_').
letter_to_action('i','_INV_').
letter_to_action('j','_S_').
letter_to_action('k','_N_').
letter_to_action('l','_E_').
letter_to_action('m','_MOVE_').
letter_to_action('n','_SE_').
letter_to_action('o','_OPEN_').
letter_to_action('p','_PAY_').
letter_to_action('q','_QUAFF_').
letter_to_action('r','_READ_').
letter_to_action('s','_SEARCH_').
letter_to_action('t','_THROW_').
letter_to_action('u','_NE_').
letter_to_action('v','_VERSIONSHORT_').
letter_to_action('w','_WIELD_').
letter_to_action('x','_SWAP_').
letter_to_action('y','_NW_').
letter_to_action('z','_ZAP_').