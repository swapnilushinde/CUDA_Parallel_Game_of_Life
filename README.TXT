													
													README

			Files included - 
					gol.cu 			:	CUDA program
					gol_seq.cu		: 	Sequential program
					Project_3.docx 	: 	project report
					experiment.xlsx : 	experimental results in tabular format.
					gol_64.cu		: 	CUDA program for hardcoded input.
					gol_sql_64.cu	:	Sequential program for hardcoded input.
					seq_64_output 	: 	Output of sequential program
					cuda_64_output 	: 	Output of CUDA program.

Instructions - 
CUDA program : 
	Compilation - nvcc -o gol gol.cu -I/includepath -L/libpath
	Execution   - ./gol
	Note : This code generates random input..
	User inputs - 
					"Enter number of elements - N*N (should be perfect square) " : This should be perfect square (N*N).
					"Enter # of blocks " : Enter number of blocks to be used.
					"Enter # of threads per block " : Enter number of threads per block.
					"Do you want infinite loop('y' or 'n') : " : Enter 'y' if what to execute infinite loop or 'n' for finite generations.
					"Enter # of generations " : Enter finite number of generation.
	This program will execute and shows number of generations asked by user. it gives elapsed time in micro seconds.
	
Sequential program :
	Compilation -  gcc -o gol_seq gol_seq.c -lm -std=c99
	Execution	-  ./gol_seq
	Note : This code generates random input..
	User inputs -
					"Enter number of elements - N*N (should be perfect square) " : This should be perfect square (N*N).
					"Do you want infinite loop('y' or 'n') : " : Enter 'y' if what to execute infinite loop or 'n' for finite generations.
					"Enter # of generations " : Enter finite number of generation.
	This program will execute and shows number of generations asked by user. it gives elapsed time in micro seconds.

__________________________________________________________________________________	
CUDA program for testing hardcoded input :
	Compilation - nvcc -o gol_64 gol_64.cu -I/includepath -L/libpath
	Execution   - ./gol_64
	Note : This code works on hardcoded input for testing. Find for "check[]". 
			You can enter your hardcoded input array in check[] and execute program as explained above.
	
	This program will execute and shows number of generations for user hardcoded input. it gives elapsed time in micro seconds.	
	
Sequential program for testing hardcoded input :
	Compilation -  gcc -o gol_seq_64 gol_seq_64.c -lm -std=c99
	Execution	-  ./gol_seq_64
	Note : This code works on hardcoded input for testing. Find for "check[]". 
			You can enter your hardcoded input array in check[] and execute program as explained above.
	
	This program will execute and shows number of generations for user hardcoded input. it gives elapsed time in micro seconds.	




