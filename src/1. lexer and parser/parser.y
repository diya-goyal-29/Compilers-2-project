%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
        #include<ctype.h>
        #include"lex.yy.c"

	void yyerror();
	int yylex();
%}

%token
  // END  0  "end of file"
  ASSIGN  '='
  SUBTRACT_OP   '-'
  ADDITION_OP    '+'
  MULTI_OP    '*'
  DIV_OP   '/'
  AND_OP '&'
  L_PAREN  '('
  R_PAREN  ')'
  MOD_OP '%'
  OR_OP '|'
  COMMA_OP ','
  STM_DELIM ';'
  COLON_OP ':'
  L_BRACE '{'
  R_BRACE '}'
  L_BRAKET '['
  R_BRAKET ']'
  INC_OP "++"
  DEC_OP "--"
  ADD_ASSIGN "+="
  SUB_ASSIGN "-="
  MUL_ASSIGN "*="
  DIV_ASSIGN "/="
  MOD_ASSIGN "%="
  LESSER_OP "<"
  GREATER_OP ">"
  NE_OP "!="
  EQ_OP "=="
  GE_OP ">="
  LE_OP "<="
  ARROW "->"
  BREAK "break"
  CONTINUE "continue"
  FUNCTION_BREAK "fbreak"
  IF "if"
  ELSE "else"
  LOOP "loop"
;

%token
  INT "int"
  DOUBLE "double"
  CHAR "char"
  STRING "string"
  DATE "date"
  MONTH "month"
  ARRAY "array" 
;

%token
  IDENTIFIER 
  NUMBER
  DOUBLE_CONST
  STRING_LITERAL
  NOT_OP
  POWER
  ERROR
  DISPLAY
;

/* Operator precedence */
%left  COMMA_OP
%right '?' COLON_OP ASSIGN ADD_ASSIGN SUB_ASSIGN
%left  OR_OP
%left  AND_OP
%left  EQ_OP NE_OP
%left  LESSER_OP GREATER_OP GE_OP LE_OP
%left  ADDITION_OP SUBTRACT_OP
%left  MULTI_OP DIV_OP MOD_OP POWER
%right INC_OP DEC_OP
%left  L_PAREN L_BRAKET

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
%start program;

program: declarations ;
declarations: declarations declaration { }
|             %empty
;

declaration: function
|            vardec_stmt STM_DELIM 
;

function: IDENTIFIER COLON_OP L_PAREN paramdecls R_PAREN "->" L_PAREN paramdecls R_PAREN compound_stmt R_BRACE 
;

paramdecls: paramdecl
|           %empty
;

paramdecl:  paramdecl COMMA_OP typename IDENTIFIER 
|           typename IDENTIFIER 
;

typename: INT 
|         CHAR 
|         DOUBLE 
|         STRING 
|         DATE 
|         MONTH 
;

print_list: %empty
|           print_list COMMA_OP exprs 
;

print_stmt: DISPLAY L_PAREN STRING_LITERAL print_list R_PAREN STM_DELIM
;

stmt: compound_stmt R_BRACE 
|     selection_stmt
|     jump_stmt
|     expression_stmt
|     empty_stmt
|     vardec_stmt STM_DELIM 
|     iteration_stmt
|     print_stmt
;

expression_stmt: exprs STM_DELIM 
;

jump_stmt: CONTINUE STM_DELIM 
|          BREAK STM_DELIM  
|          FUNCTION_BREAK STM_DELIM                  
;

empty_stmt: STM_DELIM
;

vardec_stmt: typename vardec1 
|            vardec_stmt COMMA_OP vardec1 
;

vardec1: IDENTIFIER ASSIGN initializer 
|        IDENTIFIER 
; 

initializer: expr
|            L_BRACE initializer_list R_BRACE 
;
initializer_list: initializer 
|                 initializer_list COMMA_OP initializer 
;

compound_stmt:  L_BRACE 
|               compound_stmt stmt 
;

selection_stmt: IF p_expr stmt %prec LOWER_THAN_ELSE  
|               IF p_expr stmt ELSE stmt   
;

iteration_stmt: LOOP p_expr stmt   
;

p_expr: L_PAREN expr R_PAREN 
;

exprs: expr                     
|      exprs COMMA_OP expr         
;

expr: NUMBER         
|     DOUBLE_CONST             
|     STRING_LITERAL  
|     DATE
|     MONTH          
|     IDENTIFIER                 
|     L_PAREN exprs R_PAREN             
|     expr L_BRAKET exprs R_BRAKET      
|     expr L_PAREN R_PAREN              
|     expr L_PAREN exprs R_PAREN
|     expr ASSIGN expr             
|     expr ADDITION_OP expr             
|     expr SUBTRACT_OP expr %prec ADDITION_OP   
|     expr MULTI_OP expr             
|     expr DIV_OP expr %prec MULTI_OP    
|     expr MOD_OP expr             
|     expr "+=" expr             
|     expr "-=" expr             
|     "++" expr                  
|     "--" expr %prec INC_OP       
|     expr "++"                  
|     expr "--" %prec INC_OP       
|     expr LESSER_OP expr
|     expr GREATER_OP expr
|     expr OR_OP expr         
|     expr AND_OP expr             
|     expr EQ_OP expr           
|     expr NE_OP expr %prec EQ_OP 
|     expr POWER expr                
|     MULTI_OP expr           
|     SUBTRACT_OP expr       
|     '!' expr       
;

%%


int main() {
	return yyparse();
}

void yyerror () {

	fprintf(stderr, "Parsing failed here.\nSyntax Error!\n");
} 
