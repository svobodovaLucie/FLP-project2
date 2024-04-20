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
		C == ' ' -> read_line(L,_)
		;
		(isEOFEOL(C), L = [], !;
		read_line(LL,_),% atom_codes(C,[Cd]),
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
	read_line(L,C),
	( C == end_of_file ; C == ' ' ; C == '\t', Ls = [] ;
		read_lines(LLs), Ls = [L|LLs]
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




%%%%%%%%%%%%%%%%%%%% representation of the cube using variables %%%%%%%%%%%%%%%%%%%%
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

% nsolved_cube([
% 	5,5,5,
% 	5,5,5,
% 	5,5,5,
% 	1,1,1, 2,2,2, 3,3,3, 4,4,4,
% 	1,1,1, 2,2,2, 3,3,3, 4,4,4,
% 	1,1,1, 2,2,2, 3,3,3, 4,4,4,
% 	6,6,6,
% 	6,6,6,
% 	6,6,6]
% ).

% flatten_list([], []).
% flatten_list([L|Ls], Flat) :-
%     flatten_list(Ls, FlatLs),
%     append(L, FlatLs, Flat).

% read_cube(Cube) :-
%     read_lines(Lines),
%     flatten_list(Lines, Flat),
%     maplist(atom_number, Flat, Cube).







%%%%%%%%%%%%%%% start %%%%%%%%%%%%%%%%
start :-
	prompt(_, ''),
	read_lines(LL), % read lines from stdin
	split_lines(LL, Cube), % split lines into a list representing the Rubik's cube
	print_cube(Cube), % print the Rubik's cube
	halt.



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

% /** writes a single cell of the Rubik's cube */
% nprint_cube([U1,U2,U3,U4,U5,U6,U7,U8,U9,F1,F2,F3, R1,R2,R3, B1,B2,B3, L1,L2,L3,	F4,F5,F6, 
% 						 R4,R5,R6, B4,B5,B6, L4,L5,L6, F7,F8,F9, R7,R8,R9, B7,B8,B9, L7,L8,L9,D1,D2,D3,D4,D5,D6,D7,D8,D9]) :-
% 	format('~w~w~w ', U1,U2,U3),
% 	format('~w~w~w ', U4,U5,U6),
% 	format('~w~w~w ', U7,U8,U9).


% start :-
%     prompt(_, ''),
%     % read_cube(Cube), % read the Rubik's cube from stdin
% 		read_lines(LL),
% 		flatten_list(LL, R),
% 		write(R),
% 		nl,
% 		nl,
% 		nprint_cube(R), % print the Rubik's cube
%     halt.