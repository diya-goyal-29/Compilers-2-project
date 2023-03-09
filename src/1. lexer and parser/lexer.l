%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "parser.tab.h"

	void print_tokens(char* c);
	static void mult_line_check(void);

	int line_count = 1;

%}

D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+

%%


"break"                 { print_tokens("BREAK")          ; return (BREAK);}
"char"                  { print_tokens("CHAR")           ; return (CHAR);}
"continue"              { print_tokens("CONTINUE")       ; return (CONTINUE);}
"double"                { print_tokens("DOUBLE")         ; return (DOUBLE);}
"else"                  { print_tokens("ELSE")           ; return (ELSE);}
"if"                    { print_tokens("IF")             ; return (IF);}
"loop"                 	{ print_tokens("LOOP")        	 ; return (LOOP);}
"fbreak"				{ print_tokens("FUNCTION_BREAK") ; return (FUNCTION_BREAK);}
"date"					{ print_tokens("DATE")			 ; return (DATE);}
"month"					{ print_tokens("MONTH")		 	 ; return (MONTH);}
"array"					{ print_tokens("ARRAY")		 	 ; return (ARRAY);}
"int"                   { print_tokens("INT")            ; return (INT);}
"+="                    { print_tokens("ADD_ASSIGN")     ; return (ADD_ASSIGN);}
"-="                    { print_tokens("SUB_ASSIGN")     ; return (SUB_ASSIGN);}
"*="                    { print_tokens("MUL_ASSIGN")     ; return (MUL_ASSIGN);}
"/="                    { print_tokens("DIV_ASSIGN")     ; return (DIV_ASSIGN);}
"%="                    { print_tokens("MOD_ASSIGN")     ; return (MOD_ASSIGN);}
"++"                    { print_tokens("INC_OP")         ; return (INC_OP);}
"--"                    { print_tokens("DEC_OP")         ; return (DEC_OP);}
"&"                     { print_tokens("AND_OP")         ; return (AND_OP);}
"|"                     { print_tokens("OR_OP")          ; return (OR_OP);}
"<="                    { print_tokens("LE_OP")          ; return (LE_OP);}
">="                    { print_tokens("GE_OP")          ; return (GE_OP);}
"=="                    { print_tokens("EQ_OP")          ; return (EQ_OP);}
"!="                    { print_tokens("NE_OP")          ; return (NE_OP);}
";"                     { print_tokens("STM_DELIM")      ; return (STM_DELIM);}
"{"                     { print_tokens("L_BRACE")        ; return (L_BRACE);}
"}"                     { print_tokens("R_BRACE")        ; return (R_BRACE);}
":"                     { print_tokens("COLON_OP")       ; return (COLON_OP);}
"="                     { print_tokens("ASSIGN")         ; return (ASSIGN);}
"("                     { print_tokens("L_PAREN")        ; return (L_PAREN);}
")"                     { print_tokens("R_PAREN")        ; return (R_PAREN);}
"["                     { print_tokens("L_BRAKET")       ; return (L_BRAKET);}
"]"                     { print_tokens("R_BRAKET")       ; return (R_BRAKET);}
","                     { print_tokens("COMMA_OP")       ; return (COMMA_OP);}
"!"                     { print_tokens("NOT_OP")         ; return (NOT_OP);}
"-"                     { print_tokens("SUBTRACT_OP")    ; return (SUBTRACT_OP);}
"+"                     { print_tokens("ADDITION_OP")    ; return (ADDITION_OP);}
"*"                     { print_tokens("MULTI_OP")       ; return (MULTI_OP);}
"/"                     { print_tokens("DIV_OP")         ; return (DIV_OP);}
"%"                     { print_tokens("MOD_OP")         ; return (MOD_OP);}
"<"                     { print_tokens("LESSER_OP")      ; return (LESSER_OP);}
">"                     { print_tokens("GREATER_OP")      ; return (GREATER_OP);}
"^"						{ print_tokens("POWER")			 ; return (POWER);}
"->"					{ print_tokens("ARROW")			 ; return (ARROW);}
"display"				{ print_tokens("DISPLAY")		; return (DISPLAY);}
{D}{D}"_"{D}{D}"_"{D}{D}{D}{D}		{ print_tokens("DATE")	; return (DATE);}
{D}{D}"_"{D}{D}{D}{D}			{ print_tokens("MONTH")	; return (MONTH);}

"$$".*             { print_tokens("COMMENT"); }

"$/"						{ printf("Multi-line comment starts here\n"); mult_line_check();}

L?\"(\\.|[^\\"])*\"     { print_tokens("STRING_LITERAL"); return (STRING_LITERAL);} // yylval.str = strdup(yytext);
{L}({L}|{D}|"_")*           { print_tokens("IDENTIFIER"); return (IDENTIFIER);}
{D}+                    { print_tokens("NUMBER"); return (NUMBER);}  // sscanf(yytext, "%d", &yylval.ival);
{D}*"."{D}+({E})?		{ print_tokens("DOUBLE_CONST"); return (DOUBLE_CONST);}
{D}+"."{D}*({E})?		{ print_tokens("DOUBLE_CONST"); return (DOUBLE_CONST);}

[ \t\v]                 { /*eat_up_white_spaces();*/ }
[\n]				{ line_count++;}
.                   { printf("ERROR: Invalid character %s at line number %d\n",yytext,line_count); return (ERROR); }

%%

int column = 0;

static void mult_line_check(void)
{
	int c;
	int line = line_count+1;

	while(1)
	{
		int loop = 0;
		switch(input())
		{
			case '\0':
				printf("ERROR: Unterminated comment at line %d\n", line);
				exit(-1);
				loop = -1;
				break;

			case '/':
				if((c = input()) == '$')
				{
					loop = -1;
					printf("Multi-line comments terminated.\n");
					break;
				}
				unput(c);
				break;
			
			case '\n':
				line_count++;

			default:
				break;
		}

		if(loop == -1) 
		{
			break;
		}
	}
}

void print_tokens(char* c) 
{
	printf("Token Type=%s, Line=%d, Length=%d, Text='%s'\n", c, line_count,yyleng, yytext);
}

int yywrap() {
	return 1;
}