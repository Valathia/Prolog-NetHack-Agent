% action list
/**
 * Executes a step in the environment based on the given action.

 * @param ENV The game environment object.
 * @param RES The result after performing the step.
 */
move('_STOP_', ENV, GAME, RES):-   sleep(0.2), py_call(prolog_gui:step(ENV,14, GAME), RES), sleep(0.2).
move('_N_', ENV,GAME, RES):-      sleep(0.2), py_call(prolog_gui:step(ENV,1, GAME),  RES), sleep(0.2).
move('_NE_', ENV,GAME, RES):-     sleep(0.2), py_call(prolog_gui:step(ENV,5, GAME),  RES), sleep(0.2).
move('_E_', ENV,GAME, RES):-      sleep(0.2), py_call(prolog_gui:step(ENV,2, GAME),  RES), sleep(0.2).
move('_SE_', ENV,GAME, RES):-     sleep(0.2), py_call(prolog_gui:step(ENV,6, GAME),  RES), sleep(0.2).
move('_S_', ENV,GAME, RES):-      sleep(0.2), py_call(prolog_gui:step(ENV,3, GAME),  RES), sleep(0.2).
move('_SW_', ENV,GAME, RES):-     sleep(0.2), py_call(prolog_gui:step(ENV,7, GAME),  RES), sleep(0.2).
move('_W_', ENV,GAME, RES):-      sleep(0.2), py_call(prolog_gui:step(ENV,4, GAME),  RES), sleep(0.2).
move('_NW_', ENV,GAME, RES):-     sleep(0.2), py_call(prolog_gui:step(ENV,8, GAME),  RES), sleep(0.2).
move('_UP_', ENV,GAME, RES):-     sleep(0.2), py_call(prolog_gui:step(ENV,9, GAME),  RES), sleep(0.2).
move('_DOWN_', ENV,GAME, RES):-   sleep(0.2), py_call(prolog_gui:step(ENV,10, GAME), RES), sleep(0.2).
move('_WAIT_', ENV,GAME, RES):-   sleep(0.2), py_call(prolog_gui:step(ENV,11, GAME), RES), sleep(0.2).
move('_KICK_', ENV,GAME, RES):-   sleep(0.2), py_call(prolog_gui:step(ENV,13, GAME), RES), sleep(0.2).
move('_SEARCH_', ENV,GAME, RES):- sleep(0.2), py_call(prolog_gui:step(ENV,14, GAME), RES), sleep(0.2).
move('_EAT_', ENV,GAME, RES):-    sleep(0.2), py_call(prolog_gui:step(ENV,15, GAME), RES), sleep(0.2).
move('_ESC_',ENV,GAME,RES):-      sleep(0.2), py_call(prolog_gui:step(ENV,16, GAME), RES), sleep(0.2).
move('_INV_',ENV,GAME,RES):-      sleep(0.2), py_call(prolog_gui:step(ENV,17, GAME), RES), sleep(0.2).
move('_QUAFF_',ENV,GAME,RES):-    sleep(0.2), py_call(prolog_gui:step(ENV,18, GAME), RES), sleep(0.2).
move('_PICKUP_',ENV,GAME,RES):-   sleep(0.2), py_call(prolog_gui:step(ENV,19, GAME), RES), sleep(0.2).
