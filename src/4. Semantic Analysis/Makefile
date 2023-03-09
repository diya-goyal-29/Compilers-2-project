CC = gcc

all: p1 p2 p3 

# output: 
t1:  
	./a.out < Test_cases/test1.fns

t2:  
	./a.out < Test_cases/test2.fns

t3:  
	./a.out < Test_cases/test3.fns

e1:  
	./a.out < Test_cases/error1.fns

e2:  
	./a.out < Test_cases/error2.fns

e3:
	./a.out < Test_cases/error3.fns

e4:
	./a.out < Test_cases/error4.fns


# phase 3: generates a.out (parser) 
p3: p2  
	$(CC) parser.tab.c -ll


# phase 2: generates parser.tab files
p2: p1
	bison -d -v parser.y


# phase 1: generates lex.yy.c 	
p1: 
	flex lexer.l


clean:
	rm -f lex.yy.c parser.tab.h parser.tab.c parser.output a.out
