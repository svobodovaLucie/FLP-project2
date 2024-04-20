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


/** testuje znak na EOF nebo LF */
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).


read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
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






%%%%%%%%%%%%%%%%%% my implementation %%%%%%%%%%%%%%%%%%
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


start :-
	prompt(_, ''),
	read_lines(LL), % read lines from stdin
	split_lines(LL, Cube), % split lines into a list representing the Rubik's cube
	print_cube(Cube), % print the Rubik's cube
	halt.
	