% Project:     Rubik's Cube (implemented in Prolog)
% Course:      Functional and Logic Programming
% Author:      Lucie Svobodova, xsvobo1x@stud.fit.vutbr.cz 
% Year:        2023/2024
% University:  Brno University of Technology, Faculty of Information Technology
% 
% Description: This project involves the implementation of a Rubik's Cube solver in Prolog.
%              


/** FLP 2020
Toto je ukazkovy soubor zpracovani vstupu v prologu.
Tento soubor muzete v projektu libovolne pouzit.

autor: Martin Hyrs, ihyrs@fit.vutbr.cz
preklad: swipl -q -g start -o flp19-log -c input2.pl
*/


/** cte radky ze standardniho vstupu, konci na LF nebo EOF */
read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
		read_line(LL,_),% atom_codes(C,[Cd]),
		[C|LL] = L).


nread_line(L,C) :-
	get_char(C),
	(
		C == ' ' -> nread_line(L,_)
		;
		(isEOFEOL(C), L = [], !;
		nread_line(LL,_),% atom_codes(C,[Cd]),
		[C|LL] = L)
	).


/** testuje znak na EOF nebo LF */
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).


read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	).

nread_lines(Ls) :-
	nread_line(L,C),
	( C == end_of_file ; C == ' ' ; C == '\t', Ls = [] ;
		nread_lines(LLs), Ls = [L|LLs]
	).


/** rozdeli radek na podseznamy */
split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).    % aby to fungovalo i s retezcem na miste seznamu
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]). % G je prvni seznam ze seznamu seznamu G|S1


/** vstupem je seznam radku (kazdy radek je seznam znaku) */
split_lines([],[]).
split_lines([L|Ls],[H|T]) :- split_lines(Ls,T), split_line(L,H).



% TODO
% nacist vstup
% vygenerovat vsechna mozna reseni 
% test jestli je dane reseni validni krok
% na nejake vygenerovane hodnote zastavit
% dynamicke predikaty pouzit na frontu closed
% IDS nebo DLS, maximalni hloubka asi cca 10






%%%%%%%%%%%%%%%%%% print cube %%%%%%%%%%%%%%%%%%
/** prints a list representing a Rubik's cube in the format of the input cube */
print_cube([]).
print_cube([Row|Rows]) :-
	print_row(Row),
	nl,
	print_cube(Rows).

/** prints a single row of the Rubik's cube */
print_row([]).
print_row([Cell|Cells]) :-
	write_cell(Cell),
	print_row(Cells).

/** writes a single cell of the Rubik's cube */
write_cell([X1, X2, X3]) :-
	format('~w~w~w ', [X1, X2, X3]).





%%%%%%%%%%%%%%%%%% representation of the cube %%%%%%%%%%%%%%%%%%
in_cb([
	[[5,5,3]],
	[[5,5,3]],
	[[5,5,4]],
	[[2,2,5],[3,2,2],[6,4,4],[1,1,1]],
	[[1,1,5],[3,2,2],[6,3,3],[4,4,4]],
	[[1,1,5],[3,2,2],[6,3,3],[4,4,4]],
	[[6,6,2]],
	[[6,6,1]],
	[[6,6,1]]]).

s_cb([
	[[5,5,5]],
	[[5,5,5]],
	[[5,5,5]],
	[[1,1,1],[2,2,2],[3,3,3],[4,4,4]],
	[[1,1,1],[2,2,2],[3,3,3],[4,4,4]],
	[[1,1,1],[2,2,2],[3,3,3],[4,4,4]],
	[[6,6,6]],
	[[6,6,6]],
	[[6,6,6]]]).

%%%%%%%%%%%%%%%%%% test if solved %%%%%%%%%%%%%%%%%%
solved_cube([
	[[5,5,5]],
	[[5,5,5]],
	[[5,5,5]],
	[[1,1,1],[2,2,2],[3,3,3],[4,4,4]],
	[[1,1,1],[2,2,2],[3,3,3],[4,4,4]],
	[[1,1,1],[2,2,2],[3,3,3],[4,4,4]],
	[[6,6,6]],
	[[6,6,6]],
	[[6,6,6]]]
).

test_cube(Cube) :-
	solved_cube(SolvedCube),
	Cube = SolvedCube.

/** Test if the input Rubik's cube is in the final solved state */
test_if_solved :-
	in_cb(X),
	InputCube = X,
  ( is_solved_cube(InputCube) ->
		writeln('The Rubik\'s cube is in the final solved state.')
	;   
		writeln('The Rubik\'s cube is not in the final solved state.')
	).


%%%%%%%%%%%%%%%%%% moves %%%%%%%%%%%%%%%%%%
% Define a predicate for clockwise rotation of the upper face (U)
rotate_upper_clockwise(Cube, NewCube) :-
    % Extract the upper face of the cube
    Cube = [UpperFace | Rest],
    % Rotate the upper face clockwise
    rotate_face_clockwise(UpperFace, RotatedUpperFace),
    % Assemble the new cube with the rotated upper face
    NewCube = [RotatedUpperFace | Rest].

% Define a predicate for clockwise rotation of a single face
rotate_face_clockwise(Face, NewFace) :-
    % Transpose the face matrix
    transpose(Face, TransposedFace),
    % Reverse each row of the transposed face matrix
    maplist(reverse, TransposedFace, NewFace).

% transpose/2 predicate to transpose a matrix
transpose([], []).
transpose([[]|_], []).
transpose(Matrix, [Row|Transposed]) :-
    transpose_row(Matrix, Row, RestMatrix),
    transpose(RestMatrix, Transposed).

transpose_row([], [], []).
transpose_row([[X|Xs]|RestMatrix], [X|FirstColumn], [Xs|RestColumns]) :-
    transpose_row(RestMatrix, FirstColumn, RestColumns).


%%%%%%%%%%%%%%%%%% search algorithm %%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%
var_cube([
	[[U1,U2,U3]],
	[[U4,U5,U6]],
	[[U7,U8,U9]],

	[[F1,F2,F3], [R1,R2,R3], [B1,B2,B3], [L1,L2,L3]],
	[[F4,F5,F6], [R4,R5,R6], [B4,B5,B6], [L4,L5,L6]],
	[[F7,F8,F9], [R7,R8,R9], [B7,B8,B9], [L7,L8,L9]],

	[[D1,D2,D3]],
	[[D4,D5,D6]],
	[[D7,D8,D9]]
]).



%%%%%%%%%%%%%%%%%%%% representation of the cube using variables %%%%%%%%%%%%%%%%%%%%
ncube([
	U1,U2,U3,
	U4,U5,U6,
	U7,U8,U9,

	F1,F2,F3, R1,R2,R3, B1,B2,B3, L1,L2,L3,
	F4,F5,F6, R4,R5,R6, B4,B5,B6, L4,L5,L6,
	F7,F8,F9, R7,R8,R9, B7,B8,B9, L7,L8,L9,

	D1,D2,D3,
	D4,D5,D6,
	D7,D8,D9]
).

nsolved_cube([
	5,5,5,
	5,5,5,
	5,5,5,
	1,1,1, 2,2,2, 3,3,3, 4,4,4,
	1,1,1, 2,2,2, 3,3,3, 4,4,4,
	1,1,1, 2,2,2, 3,3,3, 4,4,4,
	6,6,6,
	6,6,6,
	6,6,6]
).

flatten_list([], []).
flatten_list([L|Ls], Flat) :-
    flatten_list(Ls, FlatLs),
    append(L, FlatLs, Flat).

% read_cube(Cube) :-
%     read_lines(Lines),
%     flatten_list(Lines, Flat),
%     maplist(atom_number, Flat, Cube).







%%%%%%%%%%%%%%% start %%%%%%%%%%%%%%%%
% start :-
% 	prompt(_, ''),
% 	read_lines(LL), % read lines from stdin
% 	split_lines(LL, Cube), % split lines into a list representing the Rubik's cube
% 	print_cube(Cube), % print the Rubik's cube
% 	write(Cube),
% 	halt.



/** prints a list representing a Rubik's cube in the format of the input cube */
% print_cube([]).
% print_cube([Row|Rows]) :-
% 	print_row(Row),
% 	nl,
% 	print_cube(Rows).

% /** prints a single row of the Rubik's cube */
% print_row([]).
% print_row([Cell|Cells]) :-
% 	write_cell(Cell),
% 	print_row(Cells).

/** writes a single cell of the Rubik's cube */
% nprint_cube([U1,U2,U3,U4,U5,U6,U7,U8,U9,F1,F2,F3, R1,R2,R3, B1,B2,B3, L1,L2,L3,	F4,F5,F6, 
% 						 R4,R5,R6, B4,B5,B6, L4,L5,L6, F7,F8,F9, R7,R8,R9, B7,B8,B9, L7,L8,L9,D1,D2,D3,D4,D5,D6,D7,D8,D9]) :-
% 	format('~w~w~w ', U1,U2,U3),
% 	format('~w~w~w ', U4,U5,U6),
% 	format('~w~w~w ', U7,U8,U9).


start :-
    prompt(_, ''),
    % read_cube(Cube), % read the Rubik's cube from stdin
		nread_lines(LL),
		flatten_list(LL, R),
		write(R),
		nl,
		nl,
		nprint_cube(R), % print the Rubik's cube
    halt.


nprint_cube([]).
nprint_cube([U1,U2,U3,U4,U5,U6,U7,U8,U9,F1,F2,F3,R1,R2,R3,B1,B2,B3,L1,L2,L3,F4,F5,F6,R4,R5,R6,B4,B5,B6,L4,L5,L6,F7,F8,F9,R7,R8,R9,B7,B8,B9,L7,L8,L9,D1,D2,D3,D4,D5,D6,D7,D8,D9]) :-
	format('~w~w~w~n', [U1,U2,U3]), % Print the top face
	format('~w~w~w~n', [U4,U5,U6]), % Print the top face
	format('~w~w~w~n', [U7,U8,U9]), % Print the top face
	format('~w~w~w ~w~w~w ~w~w~w ~w~w~w~n', [F1,F2,F3,R1,R2,R3,B1,B2,B3,L1,L2,L3]), % Print the left side
	format('~w~w~w ~w~w~w ~w~w~w ~w~w~w~n', [F4,F5,F6,R4,R5,R6,B4,B5,B6,L4,L5,L6]), % Print the left side
	format('~w~w~w ~w~w~w ~w~w~w ~w~w~w~n', [F7,F8,F9,R7,R8,R9,B7,B8,B9,L7,L8,L9]), % Print the left side
	format('~w~w~w~n', [D1,D2,D3]), % Print the bottom face
	format('~w~w~w~n', [D4,D5,D6]), % Print the middle layer
	format('~w~w~w~n', [D7,D8,D9]). % Print the middle layer


% ncube([
% 	U1,U2,U3,
% 	U4,U5,U6,
% 	U7,U8,U9,

% 	F1,F2,F3, R1,R2,R3, B1,B2,B3, L1,L2,L3,
% 	F4,F5,F6, R4,R5,R6, B4,B5,B6, L4,L5,L6,
% 	F7,F8,F9, R7,R8,R9, B7,B8,B9, L7,L8,L9,

% 	D1,D2,D3,
% 	D4,D5,D6,
% 	D7,D8,D9]
% ).

nin_cube([5,5,3,5,5,3,5,5,4,2,2,5,3,2,2,6,4,4,1,1,1,1,1,5,3,2,2,6,3,3,4,4,4,1,1,5,3,2,2,6,3,3,4,4,4,6,6,2,6,6,1,6,6,1]).

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

kostka1(['B','R','R','O','W','W','G','G','G','W','W','W','O','B','B','W','W','O','W','G','R','G','G','Y','R','R','Y','B','B','O','W','O','Y','G','G','Y','R','R','Y','B','B','Y','O','O','Y','R','R','B','Y','Y','B','G','O','O']).
kostka2(['R','W','R','B','W','G','O','W','O','W','R','Y','G','R','B','W','O','Y','B','O','G','W','G','Y','G','R','B','W','B','Y','B','O','G','W','O','Y','G','R','B','W','R','Y','B','O','G','R','Y','R','G','Y','B','O','Y','O']).
kostka3(['O','W','W','O','W','W','G','G','R','O','O','G','Y','G','G','R','R','W','B','B','W','Y','G','G','R','R','W','B','B','W','O','O','G','B','R','R','B','B','W','B','B','G','Y','Y','Y','O','Y','Y','O','Y','Y','O','R','R']).
kostka4(['R','R','G','B','W','G','B','W','W','Y','B','R','B','W','W','O','W','W','G','R','R','Y','G','G','Y','R','R','Y','B','W','O','O','O','Y','G','G','Y','R','R','Y','B','W','O','O','O','B','O','O','B','Y','G','B','Y','G']).
kostka_s(['Y','Y','Y','G','G','G','Y','Y','Y','O','O','O','B','Y','B','R','R','R','G','W','G','O','O','O','B','Y','B','R','R','R','G','W','G','O','O','O','B','Y','B','R','R','R','G','W','G','W','W','W','B','B','B','W','W','W']).
kostka_sR(['Y','Y','Y','R','R','R','Y','Y','Y','B','B','B','R','W','R','G','G','G','O','Y','O','B','B','B','R','W','R','G','G','G','O','Y','O','B','B','B','R','W','R','G','G','G','O','Y','O','W','W','W','O','O','O','W','W','W']).
kostka_e([
	'Y','Y','Y',
	'Y','Y','Y',
	'Y','Y','Y',
	'G','G','G', 'O','O','O', 'B','B','B', 'R','R','R',
	'R','R','R', 'G','G','G', 'O','O','O', 'B','B','B',
	'G','G','G', 'O','O','O', 'B','B','B', 'R','R','R', 
	'W','W','W',
	'W','W','W',
	'W','W','W']).
kostka_eR([
	'Y','Y','Y',
	'Y','Y','Y',
	'Y','Y','Y',
	'B','B','B', 'R','R','R', 'G','G','G', 'O','O','O', 
	'R','R','R', 'G','G','G', 'O','O','O', 'B','B','B', 
	'B','B','B', 'R','R','R', 'G','G','G', 'O','O','O', 
	'W','W','W',
	'W','W','W',
	'W','W','W']).
kostka_m([
	'Y','O','Y',
	'Y','O','Y',
	'Y','O','Y',
	'R','Y','R', 'G','G','G', 'O','W','O', 'B','B','B',
	'R','Y','R', 'G','G','G', 'O','W','O', 'B','B','B',
	'R','Y','R', 'G','G','G', 'O','W','O', 'B','B','B',
	'W','R','W',
	'W','R','W',
	'W','R','W']).
kostka_mR([
	'Y','R','Y',
	'Y','R','Y',
	'Y','R','Y',
	'R','W','R', 'G','G','G', 'O','Y','O', 'B','B','B',
	'R','W','R', 'G','G','G', 'O','Y','O', 'B','B','B',
	'R','W','R', 'G','G','G', 'O','Y','O', 'B','B','B',
	'W','O','W',
	'W','O','W',
	'W','O','W']).
