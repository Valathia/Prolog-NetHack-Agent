% action list
/**
 * Executes a step in the environment based on the given action.
 
 * @param ENV The game environment object.
 * @param RES The result after performing the step.
 */
move('_STOP_', ENV, RES):-   sleep(0.25), py_call(prolog_gui:step(ENV,14), RES), sleep(0.25).
move('_N_', ENV, RES):-      sleep(0.25), py_call(prolog_gui:step(ENV,1), RES), sleep(0.25).
move('_NE_', ENV, RES):-     sleep(0.25), py_call(prolog_gui:step(ENV,5), RES), sleep(0.25).
move('_E_', ENV, RES):-      sleep(0.25), py_call(prolog_gui:step(ENV,2), RES), sleep(0.25).
move('_SE_', ENV, RES):-     sleep(0.25), py_call(prolog_gui:step(ENV,6), RES), sleep(0.25).
move('_S_', ENV, RES):-      sleep(0.25), py_call(prolog_gui:step(ENV,3), RES), sleep(0.25).
move('_SW_', ENV, RES):-     sleep(0.25), py_call(prolog_gui:step(ENV,7), RES), sleep(0.25).
move('_W_', ENV, RES):-      sleep(0.25), py_call(prolog_gui:step(ENV,4), RES), sleep(0.25).
move('_NW_', ENV, RES):-     sleep(0.25), py_call(prolog_gui:step(ENV,8), RES), sleep(0.25).
move('_UP_', ENV, RES):-     sleep(0.25), py_call(prolog_gui:step(ENV,9), RES), sleep(0.25).
move('_DOWN_', ENV, RES):-   sleep(0.25), py_call(prolog_gui:step(ENV,10), RES), sleep(0.25).
move('_WAIT_', ENV, RES):-   sleep(0.25), py_call(prolog_gui:step(ENV,11), RES), sleep(0.25).
move('_KICK_', ENV, RES):-   sleep(0.25), py_call(prolog_gui:step(ENV,13), RES), sleep(0.25).
move('_SEARCH_', ENV, RES):- sleep(0.25), py_call(prolog_gui:step(ENV,14), RES), sleep(0.25).
move('_EAT_', ENV, RES):-    sleep(0.25), py_call(prolog_gui:step(ENV,15), RES), sleep(0.25).
move('_ESC_',ENV,RES):-      sleep(0.25), py_call(prolog_gui:step(ENV,16), RES), sleep(0.25).
move('_INV_',ENV,RES):-      sleep(0.25), py_call(prolog_gui:step(ENV,17), RES), sleep(0.25).
move('_QUAFF_',ENV,RES):-    sleep(0.25), py_call(prolog_gui:step(ENV,18), RES), sleep(0.25).
move('_PICKUP_',ENV,RES):-   sleep(0.25), py_call(prolog_gui:step(ENV,19), RES), sleep(0.25).
