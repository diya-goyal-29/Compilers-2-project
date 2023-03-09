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


"break"                 { strcpy(yylval.ast_node.name,(yytext)); print_tokens("BREAK")          ; return (BREAK);}
"continue"              { strcpy(yylval.ast_node.name,(yytext)); print_tokens("CONTINUE")       ; return (CONTINUE);}
"accept"				{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("ACCEPT")         ; return (ACCEPT);}
"double"                { strcpy(yylval.ast_node.name,(yytext)); print_tokens("DOUBLE")         ; return (DOUBLE);}
"string"				{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("STRING")         ; return (STRING);}
"else"                  { strcpy(yylval.ast_node.name,(yytext)); print_tokens("ELSE")           ; return (ELSE);}
"if"                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("IF")             ; return (IF);}
"loop"                 	{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("LOOP")        	; return (LOOP);}
"fbreak"				{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("FUNCTION_BREAK") ; return (FUNCTION_BREAK);}
"date"					{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("DATE")			; return (DATE);}
"month"					{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("MONTH")		 	; return (MONTH);}
"int"                   { strcpy(yylval.ast_node.name,(yytext)); print_tokens("INT")            ; return (INT);}
"+="                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("ADD_ASSIGN")     ; return (ADD_ASSIGN);}
"-="                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("SUB_ASSIGN")     ; return (SUB_ASSIGN);}
"*="                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("MUL_ASSIGN")     ; return (MUL_ASSIGN);}
"/="                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("DIV_ASSIGN")     ; return (DIV_ASSIGN);}
"%="                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("MOD_ASSIGN")     ; return (MOD_ASSIGN);}
"++"                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("INC_OP")         ; return (INC_OP);}
"--"                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("DEC_OP")         ; return (DEC_OP);}
"&"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("AND_OP")         ; return (AND_OP);}
"|"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("OR_OP")          ; return (OR_OP);}
"<="                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("LE_OP")          ; return (LE_OP);}
">="                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("GE_OP")          ; return (GE_OP);}
"=="                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("EQ_OP")          ; return (EQ_OP);}
"!="                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("NE_OP")          ; return (NE_OP);}
";"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("STM_DELIM")      ; return (STM_DELIM);}
"{"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("L_BRACE")        ; return (L_BRACE);}
"}"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("R_BRACE")        ; return (R_BRACE);}
":"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("COLON_OP")       ; return (COLON_OP);}
"="                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("ASSIGN")         ; return (ASSIGN);}
"("                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("L_PAREN")        ; return (L_PAREN);}
")"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("R_PAREN")        ; return (R_PAREN);}
"["                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("L_BRAKET")       ; return (L_BRAKET);}
"]"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("R_BRAKET")       ; return (R_BRAKET);}
","                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("COMMA_OP")       ; return (COMMA_OP);}
"!"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("NOT_OP")         ; return (NOT_OP);}
"-"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("SUBTRACT_OP")    ; return (SUBTRACT_OP);}
"+"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("ADDITION_OP")    ; return (ADDITION_OP);}
"*"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("MULTI_OP")       ; return (MULTI_OP);}
"/"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("DIV_OP")         ; return (DIV_OP);}
"%"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("MOD_OP")         ; return (MOD_OP);}
"<"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("LESSER_OP")      ; return (LESSER_OP);}
">"                     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("GREATER_OP")     ; return (GREATER_OP);}
"^"						{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("POWER")			; return (POWER);}
"->"					{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("ARROW")			; return (ARROW);}
"display"				{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("DISPLAY")		; return (DISPLAY);}
{D}{D}"_"{D}{D}"_"{D}{D}{D}{D}		{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("DATE")	; return (DATE);}
{D}{D}"_"{D}{D}{D}{D}			{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("MONTH")	; return (MONTH);}

"$$".*             { print_tokens("COMMENT"); }

"$/"						{ /*printf("Multi-line comment starts here\n");*/ mult_line_check();}

L?\"(\\.|[^\\"])*\"     { strcpy(yylval.ast_node.name,(yytext)); print_tokens("STRING_LITERAL"); return (STRING_LITERAL);} // yylval.str = strdup(yytext);
{L}({L}|{D}|"_")*           { strcpy(yylval.ast_node.name,(yytext)); print_tokens("IDENTIFIER"); return (IDENTIFIER);}
{D}+                    { strcpy(yylval.ast_node.name,(yytext)); print_tokens("NUMBER"); return (NUMBER);}  // sscanf(yytext, "%d", &yylval.ival);
{D}*"."{D}+({E})?		{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("DOUBLE_CONST"); return (DOUBLE_CONST);}
{D}+"."{D}*({E})?		{ strcpy(yylval.ast_node.name,(yytext)); print_tokens("DOUBLE_CONST"); return (DOUBLE_CONST);}

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
	printf("Token Type=%s, Line=%d, Length=%d, Text='%s'\n", c, line_count, yyleng, yytext);
}

int yywrap() {
	return 1;
}
