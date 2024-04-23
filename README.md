# Rubik's Cube (Project 2, Functional and Logic Programming)

#### Course Information
- **Course**: Functional and Logic Programming (FLP)
- **Author**: Lucie Svobodová
- **Email**:  xsvobo1x@stud.fit.vutbr.cz
- **Year**:   2023/2024
- **University**: Brno University of Technology, Faculty of Information Technology

### Description
This project implements a Rubik's Cube solver in Prolog. It performs an Iterative Deepening Search (IDS) algorithm to find the optimal solution for a given Rubik's Cube. The solver reads the initial state of the cube from standard input and outputs a sequence of moves that leads to the solved state. The Iterative Deepening Search algorithm ensures that the found solution is optimal.

The states of the Rubik's Cube are represented internally as a flat list of values, as shown below:
```
cube([
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
```

### Usage

**Compilation:**
A Makefile is provided in the project directory to compile the program. Alternatively, you can use the following command:
`swipl -q -g start --stack_limit=16g -o flp23-log -c flp23-log.pl`

**Running the Solver:**
`./flp23-log < input_cube`

The `input_cube` should be formatted as follows:
```
553
553
554
225 322 644 111
115 322 633 444
115 322 633 444
662
661
661
```

The solver outputs each move of the cube until the cube is solved. For the above `input_cube`, it returns the following output:
```
553
553
554
225 322 644 111
115 322 633 444
115 322 633 444
662
661
661

555
555
555
222 333 444 111
111 222 333 444
111 222 333 444
666
666
666

555
555
555
111 222 333 444
111 222 333 444
111 222 333 444
666
666
666
```

### Tests
Test inputs are provided in the `test-inputs` directory. Each input file contains the initial configuration of a Rubik's Cube. Corresponding solution files contain the expected output of the solver for the input cubes (e.g., for an input cube in file `cube1.txt`, there is an expected solution in a file called `cube1_solution`). You can use the following command to compare the solver output with the expected solution:
`./flp23-log < cube1.txt > cube1_res.out && diff cube1_res.out cube1_solution.txt`

The time taken to solve each cube (on Merlin) is recorded below:

- `assignment_cube.txt`: 0.012s (2 steps)
- `cube1.txt`: 0m0.154s (4 steps)
- `cube2.txt`: 0m0.090s (4 steps)
- `cube3.txt`: 0m0.033s (4 steps)
- `cube4.txt`: 0m0.198s (5 steps)
- `cube5.txt`: 0m0.229s (5 steps)
- `cube6.txt`: 0m0.040s (4 steps)
- `cube7.txt`: 0m0.021s (2 steps)
- `cube8.txt`: 0m24.432s (6 steps)
- `cube9.txt`: 12m8.517s (7 steps)
- `cube10.txt`: 5m21.638s (7 steps)
- `cube11.txt`: 0m9.717s (6 steps)
- `cube12.txt`: 7m52.474s (7 steps)
- `cube13.txt`: 0m0.016s (2 steps)
- `cube14.txt`: 0m48.350s (6 steps)
- `cube15.txt`: 0m0.206s (4 steps)
- `cube16.txt`: 0m0.024s (3 steps)
- `cube_m.txt`: 0.015s (1 step)
- `cube_mR.txt`: 0.016s (1 step)
- `cube_e.txt`: 0.015s (1 step)
- `cube_eR.txt`: 0.014s (1 step)
- `cube_s.txt`: 0.016s (1 step)
- `cube_sR.txt`: 0.016s (1 step)
