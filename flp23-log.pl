% Project:     Rubik's Cube (implemented in Prolog)
% Course:      Functional and Logic Programming
% Author:      Lucie Svobodova, xsvobo1x@stud.fit.vutbr.cz 
% Year:        2023/2024
% University:  Brno University of Technology, Faculty of Information Technology
%
% Description: This project implements a Rubik's Cube solver in Prolog. The solver performs 
%              an Iterative Deepening Search (IDS) algorithm to find a solution for a given 
%              Rubik's Cube, which is read from standard input. Upon finding a solution, 
%              the solver prints the sequence of moves required to solve the cube.

/**
 * start
 *
 * Starts the program. Loads a Rubik's cube from the input and performs an iterative 
 * deepening search to find a solution.
 */
start :-
	prompt(_, ''),
	read_input_cube(_, InitialCubeState),
	print_cube(InitialCubeState),
	iterative_deepening_search(InitialCubeState),
	halt.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input Handling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/**
 * read_input_cube(+Input, -Cube)

 * Reads the Rubik's cube from standard input.
 * @arg Input input from standard input
 * @arg Cube  loaded Rubik's cube  
 */
read_input_cube(Input, Cube) :-
	read_lines(Input),
	flatten_list(Input, Cube).

/**
 * read_line(-Line, +Char)
 *
 * Reads a single line from standard input.
 *
 * @arg Line  list representing the read line
 * @arg Char  character read from input
 */
read_line(L,C) :-
	get_char(C),
	( C == ' ' -> read_line(L,_)
	; ( isEOFEOL(C), L = [], !;
			read_line(LL,_),
			[C|LL] = L)
	).

/**
 * isEOFEOL(+Char)
 *
 * Checks if the character represents end of file or end of line.
 * @arg Char character to check
 */
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).

/**
 * read_lines(-Lines)
 *
 * Reads all lines from standard input.
 * @arg Lines list of lines read from input
 */
read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file ; C == ' ' ; C == '\t', Ls = [] ;
		read_lines(LLs), Ls = [L|LLs]
	).

/**
 * flatten_list(+List, -FlatList)
 *
 * Flattens a list of lists.
 * @arg List  list of lists
 * @arg Flat  flattened list
 */
flatten_list([], []).
flatten_list([L|Ls], FlatList) :-
	flatten_list(Ls, FlatLs),
	append(L, FlatLs, FlatList).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Search Algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/**
 * depth_limited_search(+InitialCube, +State, +DepthLimit, ?Moves)
 *
 * Performs depth-limited search to find a solution within a specified depth limit
 * and prints the found solution.
 * @arg InitialCube the initial state of the Rubik's cube
 * @arg State       the current state of the Rubik's cube
 * @arg DepthLimit  the depth limit for the search
 * @arg Moves       list of moves made to reach the current state
 */
depth_limited_search(InitialCube, State, _, Moves) :-
	test_if_solved(State),
	print_solution_moves(InitialCube, Moves).

depth_limited_search(InitialCube, State, DepthLimit, Moves) :-
	DepthLimit > 0,
	NextDepthLimit is DepthLimit - 1,
	move(State, NextState, Move),
	append(Moves, [Move], NewMoves),
	depth_limited_search(InitialCube, NextState, NextDepthLimit, NewMoves).

/**
 * iterative_deepening_search(+Start)
 *
 * Performs an iterative deepening search to find a solution.
 * @arg Start the initial state of the Rubik's cube
 */
iterative_deepening_search(Start) :-
	iterative_deepening_search_iter(Start, Start, 0, []).
		
/**
 * iterative_deepening_search_iter(+InitialCube, +Start, +DepthLimit, ?Moves)
 *
 * Helper predicate for performing iterative deepening search.
 * @arg InitialCube the initial state of the Rubik's cube
 * @arg Start       the current state of the Rubik's cube
 * @arg DepthLimit  the current depth limit for the search
 * @arg Moves       list of moves made to reach the current state
 */
iterative_deepening_search_iter(InitialCube, Start, DepthLimit, Moves) :-
	depth_limited_search(InitialCube, Start, DepthLimit, Moves).

iterative_deepening_search_iter(InitialCube, Start, DepthLimit, Moves) :-
	NextDepthLimit is DepthLimit + 1,
	iterative_deepening_search_iter(InitialCube, Start, NextDepthLimit, Moves).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cube Printing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/**
 * print_cube(+Cube)
 *
 * Prints the Rubik's cube representation.
 * @arg Cube list representing the Rubik's cube
 */
print_cube([]).
print_cube([U1,U2,U3,U4,U5,U6,U7,U8,U9,F1,F2,F3,R1,R2,R3,B1,B2,B3,L1,L2,L3,F4,F5,F6,R4,R5,
		R6,B4,B5,B6,L4,L5,L6,F7,F8,F9,R7,R8,R9,B7,B8,B9,L7,L8,L9,D1,D2,D3,D4,D5,D6,D7,D8,D9]) :-
	format('~w~w~w~n', [U1,U2,U3]),
	format('~w~w~w~n', [U4,U5,U6]),
	format('~w~w~w~n', [U7,U8,U9]),
	format('~w~w~w ~w~w~w ~w~w~w ~w~w~w~n', [F1,F2,F3,R1,R2,R3,B1,B2,B3,L1,L2,L3]),
	format('~w~w~w ~w~w~w ~w~w~w ~w~w~w~n', [F4,F5,F6,R4,R5,R6,B4,B5,B6,L4,L5,L6]),
	format('~w~w~w ~w~w~w ~w~w~w ~w~w~w~n', [F7,F8,F9,R7,R8,R9,B7,B8,B9,L7,L8,L9]),
	format('~w~w~w~n', [D1,D2,D3]),
	format('~w~w~w~n', [D4,D5,D6]),
	format('~w~w~w~n', [D7,D8,D9]).

/**
 * print_solution_moves(+Start, +Moves)
 *
 * Prints the sequence of moves made to solve the Rubik's cube.
 *
 * @arg Start the initial state of the Rubik's cube
 * @arg Moves list of moves made to solve the Rubik's cube
 */
print_solution_moves(_, []).

print_solution_moves(Start, [Move | Moves]) :-
	call(Move, Start, NewState),
	nl,
	print_cube(NewState),
	print_solution_moves(NewState, Moves).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Solved Cube %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/**
 * solved_cube(-Cube)
 *
 * Represents the solved state of the Rubik's cube.
 * @arg Cube list representing the solved state of the Rubik's cube
 */
solved_cube([
	'5','5','5',
	'5','5','5',
	'5','5','5',
	'1','1','1', '2','2','2', '3','3','3', '4','4','4',
	'1','1','1', '2','2','2', '3','3','3', '4','4','4',
	'1','1','1', '2','2','2', '3','3','3', '4','4','4',
	'6','6','6',
	'6','6','6',
	'6','6','6']
).

/**
 * test_if_solved(+Cube)
 *
 * Checks if the given cube matches the solved state of the Rubik's cube.
 * @arg Cube the current state of the Rubik's cube
 */
test_if_solved(Cube) :-
	solved_cube(SolvedCube),
	Cube == SolvedCube.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cube Moves %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/**
 * move(+Cube, -NextCube, -Move)
 *
 * Selects and applies a move to the cube to produce the next state.
 * @arg Cube     list representing the current state of the Rubik's cube
 * @arg NextCube list representing the next state of the Rubik's cube after applying the move
 * @arg Move     identifier for the selected move predicate
 */
move(Cube, NextCube, Move) :-
	  u_move(Cube, NextCube),  Move = 'u_move'
	; uR_move(Cube, NextCube), Move = 'uR_move'
	; d_move(Cube, NextCube),  Move = 'd_move'
	; dR_move(Cube, NextCube), Move = 'dR_move'
	; r_move(Cube, NextCube),  Move = 'r_move'
	; rR_move(Cube, NextCube), Move = 'rR_move'
	; l_move(Cube, NextCube),  Move = 'l_move'
	; lR_move(Cube, NextCube), Move = 'lR_move'
	; f_move(Cube, NextCube),  Move = 'f_move'
	; fR_move(Cube, NextCube), Move = 'fR_move'
	; b_move(Cube, NextCube),  Move = 'b_move'
	; bR_move(Cube, NextCube), Move = 'bR_move'
	; m_move(Cube, NextCube),  Move = 'm_move'
	; mR_move(Cube, NextCube), Move = 'mR_move'
	; e_move(Cube, NextCube),  Move = 'e_move'
	; eR_move(Cube, NextCube), Move = 'eR_move'
	; s_move(Cube, NextCube),  Move = 's_move'
	; sR_move(Cube, NextCube), Move = 'sR_move'
	.

/**
 * u_move(+State, -NewState)
 *
 * Predicate representing a clockwise rotation of the upper face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
u_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

       [W7,W4,W1, 
				W8,W5,W2, 
				W9,W6,W3,
        R1,R2,R3, B1,B2,B3, O1,O2,O3, G1,G2,G3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9]
).

/**
 * uR_move(+State, -NewState)
 *
 * Predicate representing a counterclockwise rotation of the upper face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
uR_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

       [W3,W6,W9, 
				W2,W5,W8, 
				W1,W4,W7,
        O1,O2,O3, G1,G2,G3, R1,R2,R3, B1,B2,B3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9]
).

/**
 * d_move(+State, -NewState)
 *
 * Predicate representing a clockwise rotation of the downer face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
d_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

			 [W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        O7,O8,O9, G7,G8,G9, R7,R8,R9, B7,B8,B9,
        Y7,Y4,Y1, 
				Y8,Y5,Y2, 
				Y9,Y6,Y3]
).

/**
 * dR_move(+State, -NewState)
 *
 * Predicate representing a counterclockwise rotation of the downer face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
dR_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

			 [W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        R7,R8,R9, B7,B8,B9, O7,O8,O9, G7,G8,G9,
        Y3,Y6,Y9, 
				Y2,Y5,Y8, 
				Y1,Y4,Y7]
).

/**
 * r_move(+State, -NewState)
 *
 * Predicate representing a clockwise rotation of the right face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
r_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

       [W1,W2,G3, 
				W4,W5,G6, 
				W7,W8,G9,
        G1,G2,Y3, R7,R4,R1, W9,B2,B3, O1,O2,O3,
        G4,G5,Y6, R8,R5,R2, W6,B5,B6, O4,O5,O6,
        G7,G8,Y9, R9,R6,R3, W3,B8,B9, O7,O8,O9,
        Y1,Y2,B1, 
				Y4,Y5,B4, 
				Y7,Y8,B7]
).

/**
 * rR_move(+State, -NewState)
 *
 * Predicate representing a counterclockwise rotation of the right face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
rR_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

       [W1,W2,B7, 
				W4,W5,B4, 
				W7,W8,B1,
        G1,G2,W3, R3,R6,R9, Y9,B2,B3, O1,O2,O3,
        G4,G5,W6, R2,R5,R8, Y6,B5,B6, O4,O5,O6,
        G7,G8,W9, R1,R4,R7, Y3,B8,B9, O7,O8,O9,
        Y1,Y2,G3, 
				Y4,Y5,G6, 
				Y7,Y8,G9]
).

/**
 * l_move(+State, -NewState)
 *
 * Predicate representing a clockwise rotation of the left face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
l_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

			 [B9,W2,W3, 
				B6,W5,W6, 
				B3,W8,W9,
        W1,G2,G3, R1,R2,R3, B1,B2,Y7, O7,O4,O1,
        W4,G5,G6, R4,R5,R6, B4,B5,Y4, O8,O5,O2,
        W7,G8,G9, R7,R8,R9, B7,B8,Y1, O9,O6,O3,
        G1,Y2,Y3, 
				G4,Y5,Y6, 
				G7,Y8,Y9]
).

/**
 * lR_move(+State, -NewState)
 *
 * Predicate representing a counterclockwise rotation of the left face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
lR_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

		   [G1,W2,W3, 
				G4,W5,W6, 
				G7,W8,W9,
        Y1,G2,G3, R1,R2,R3, B1,B2,W7, O3,O6,O9,
        Y4,G5,G6, R4,R5,R6, B4,B5,W4, O2,O5,O8,
        Y7,G8,G9, R7,R8,R9, B7,B8,W1, O1,O4,O7,
        B9,Y2,Y3, 
				B6,Y5,Y6, 
				B3,Y8,Y9]
).

/**
 * f_move(+State, -NewState)
 *
 * Predicate representing a clockwise rotation of the front face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
f_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

			 [W1,W2,W3, 
				W4,W5,W6, 
				O9,O6,O3,
        G7,G4,G1, W7,R2,R3, B1,B2,B3, O1,O2,Y1,
        G8,G5,G2, W8,R5,R6, B4,B5,B6, O4,O5,Y2,
        G9,G6,G3, W9,R8,R9, B7,B8,B9, O7,O8,Y3,
        R7,R4,R1, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9]
).

/**
 * fR_move(+State, -NewState)
 *
 * Predicate representing a counterclockwise rotation of the front face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
fR_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

			 [W1,W2,W3, 
				W4,W5,W6, 
				R1,R4,R7,
        G3,G6,G9, Y3,R2,R3, B1,B2,B3, O1,O2,W9,
        G2,G5,G8, Y2,R5,R6, B4,B5,B6, O4,O5,W8,
        G1,G4,G7, Y1,R8,R9, B7,B8,B9, O7,O8,W7,
        O3,O6,O9, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9]
).

/**
 * b_move(+State, -NewState)
 *
 * Predicate representing a clockwise rotation of the back face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
b_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

			 [R3,R6,R9, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,Y9, B7,B4,B1, W3,O2,O3,
        G4,G5,G6, R4,R5,Y8, B8,B5,B2, W2,O5,O6,
        G7,G8,G9, R7,R8,Y7, B9,B6,B3, W1,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				O1,O4,O7]
).

/**
 * bR_move(+State, -NewState)
 *
 * Predicate representing a counterclockwise rotation of the back face of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
bR_move([W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,R3, B1,B2,B3, O1,O2,O3,
        G4,G5,G6, R4,R5,R6, B4,B5,B6, O4,O5,O6,
        G7,G8,G9, R7,R8,R9, B7,B8,B9, O7,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9],

			 [O7,O4,O1, 
				W4,W5,W6, 
				W7,W8,W9,
        G1,G2,G3, R1,R2,W1, B3,B6,B9, Y7,O2,O3,
        G4,G5,G6, R4,R5,W2, B2,B5,B8, Y8,O5,O6,
        G7,G8,G9, R7,R8,W3, B1,B4,B7, Y9,O8,O9,
        Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				R9,R6,R3]
).

/**
 * m_move(+State, -NewState)
 *
 * Predicate representing a clockwise rotation of the middle vertical slice of a Rubik's cube 
 * parallel to the left and right faces.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
m_move([Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,O2,O3, B1,B2,B3, R1,R2,R3,
        G4,G5,G6, O4,O5,O6, B4,B5,B6, R4,R5,R6,
        G7,G8,G9, O7,O8,O9, B7,B8,B9, R7,R8,R9,
        W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9],

			 [Y1,B8,Y3, 
				Y4,B5,Y6, 
				Y7,B2,Y9,
        G1,Y2,G3, O1,O2,O3, B1,W8,B3, R1,R2,R3,
        G4,Y5,G6, O4,O5,O6, B4,W5,B6, R4,R5,R6,
        G7,Y8,G9, O7,O8,O9, B7,W2,B9, R7,R8,R9,
        W1,G2,W3, 
				W4,G5,W6, 
				W7,G8,W9]
).

/**
 * mR_move(+State, -NewState)
 *
 * Predicate representing a counterclockwise rotation of the middle vertical slice of a Rubik's cube 
 * parallel to the left and right faces.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
mR_move([Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,O2,O3, B1,B2,B3, R1,R2,R3,
        G4,G5,G6, O4,O5,O6, B4,B5,B6, R4,R5,R6,
        G7,G8,G9, O7,O8,O9, B7,B8,B9, R7,R8,R9,
        W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9],

			 [Y1,G2,Y3, 
				Y4,G5,Y6, 
				Y7,G8,Y9,
        G1,W2,G3, O1,O2,O3, B1,Y8,B3, R1,R2,R3,
        G4,W5,G6, O4,O5,O6, B4,Y5,B6, R4,R5,R6,
        G7,W8,G9, O7,O8,O9, B7,Y2,B9, R7,R8,R9,
        W1,B8,W3, 
				W4,B5,W6, 
				W7,B2,W9]
).

/**
 * e_move(+State, -NewState)
 *
 * Predicate representing a clockwise rotation of the middle horizontal slice of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
e_move([Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,O2,O3, B1,B2,B3, R1,R2,R3,
        G4,G5,G6, O4,O5,O6, B4,B5,B6, R4,R5,R6,
        G7,G8,G9, O7,O8,O9, B7,B8,B9, R7,R8,R9,
        W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9],

			 [Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,O2,O3, B1,B2,B3, R1,R2,R3,
        R4,R5,R6, G4,G5,G6, O4,O5,O6, B4,B5,B6,
        G7,G8,G9, O7,O8,O9, B7,B8,B9, R7,R8,R9,
        W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9]
).

/**
 * eR_move(+State, -NewState)
 *
 * Predicate representing a counterclockwise rotation of the middle horizontal slice of a Rubik's cube.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
eR_move([Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,O2,O3, B1,B2,B3, R1,R2,R3,
        G4,G5,G6, O4,O5,O6, B4,B5,B6, R4,R5,R6,
        G7,G8,G9, O7,O8,O9, B7,B8,B9, R7,R8,R9,
        W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9],

			 [Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,O2,O3, B1,B2,B3, R1,R2,R3,
        O4,O5,O6, B4,B5,B6, R4,R5,R6, G4,G5,G6,
        G7,G8,G9, O7,O8,O9, B7,B8,B9, R7,R8,R9,
        W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9]
).

/**
 * s_move(+State, -NewState)
 *
 * Predicate representing a clockwise rotation of the middle vertical slice of a Rubik's cube 
 * parallel to the front and back faces.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
s_move([Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,O2,O3, B1,B2,B3, R1,R2,R3,
        G4,G5,G6, O4,O5,O6, B4,B5,B6, R4,R5,R6,
        G7,G8,G9, O7,O8,O9, B7,B8,B9, R7,R8,R9,
        W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9],

			 [Y1,Y2,Y3, 
				R2,R5,R8, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,Y4,O3, B1,B2,B3, R1,W4,R3,
        G4,G5,G6, O4,Y5,O6, B4,B5,B6, R4,W5,R6,
        G7,G8,G9, O7,Y6,O9, B7,B8,B9, R7,W6,R9,
        W1,W2,W3, 
				O8,O5,O2, 
				W7,W8,W9]
).

/**
 * sR_move(+State, -NewState)
 *
 * Predicate representing a counterclockwise rotation of the middle vertical slice of a Rubik's cube 
 * parallel to the front and back faces.
 * @arg State    the current state of the Rubik's cube
 * @arg NewState the new state of the Rubik's cube after performing the move
 */
sR_move([Y1,Y2,Y3, 
				Y4,Y5,Y6, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,O2,O3, B1,B2,B3, R1,R2,R3,
        G4,G5,G6, O4,O5,O6, B4,B5,B6, R4,R5,R6,
        G7,G8,G9, O7,O8,O9, B7,B8,B9, R7,R8,R9,
        W1,W2,W3, 
				W4,W5,W6, 
				W7,W8,W9],

			 [Y1,Y2,Y3, 
				O2,O5,O8, 
				Y7,Y8,Y9,
        G1,G2,G3, O1,W6,O3, B1,B2,B3, R1,Y6,R3,
        G4,G5,G6, O4,W5,O6, B4,B5,B6, R4,Y5,R6,
        G7,G8,G9, O7,W4,O9, B7,B8,B9, R7,Y4,R9,
        W1,W2,W3, 
				R2,R5,R8, 
				W7,W8,W9]
).
