%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    #include "lex.yy.c"
    #include "symbolTable.h"
    #include "ast.h"
    #include "semantics.h"
    #include "symbolTable.c"
    #include "ast.c"
    #include "semantics.c"


    void yyerror();
    int yylex();
   
    extern int line_count;
%}


%token
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
  ACCEPT
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

%union {
    struct var1 {
        char name[100];
        struct node* nd;
    } ast_node;

    struct var2 {
        char name[100];
        struct node* nd;
        char type[30];
    } sem_node;
}


%type<ast_node> ASSIGN SUBTRACT_OP ADDITION_OP MULTI_OP DIV_OP AND_OP L_PAREN R_PAREN
MOD_OP OR_OP COMMA_OP STM_DELIM COLON_OP L_BRACE R_BRACE L_BRAKET R_BRAKET INC_OP 
DEC_OP ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN LESSER_OP GREATER_OP 
NE_OP EQ_OP GE_OP LE_OP ARROW BREAK CONTINUE FUNCTION_BREAK IF ELSE LOOP INT DOUBLE
STRING DATE MONTH IDENTIFIER NUMBER DOUBLE_CONST STRING_LITERAL NOT_OP POWER ERROR 
DISPLAY ACCEPT

%type<ast_node> declarations declaration function vardec_stmt paramdecls compound_stmt
paramdecl typename print_list print_stmt stmt selection_stmt jump_stmt expression_stmt
empty_stmt iteration_stmt program else_stmt inp_stmt inp_list function_call par_list

%type <sem_node> expr exprs initializer initializer_list 

%%
%start program;

program: declarations {
    $$.nd = make_node($1.nd, NULL, "program");
    head = $$.nd;
}; 

declarations: declarations declaration { $$.nd = make_node($1.nd, $2.nd, "decls"); }
|             %empty { $$.nd = make_node(NULL, NULL, "null"); }
;

declaration: function { $$.nd = make_node($1.nd, NULL, "decl"); }
|            vardec_stmt STM_DELIM   {$$.nd = make_node($1.nd, NULL, "decl"); }
;

function: IDENTIFIER {add('F');} COLON_OP L_PAREN paramdecls { symbol_table[search_id($1.name)].param_cnt_ip = param_ip; 
    param_ip = 0;} R_PAREN "->" L_PAREN paramdecls { symbol_table[search_id($1.name)].param_cnt_op = param_ip; param_ip = 0;} R_PAREN compound_stmt R_BRACE 
{
    $5.nd->token = "inp_param";
    $10.nd->token = "out_param";
    node* temp = make_node($5.nd, $10.nd, "params");
    $$.nd = make_node(temp,$13.nd , $1.name);
}
;

paramdecls: paramdecl  {$$.nd = make_node($1.nd, NULL, "par_decls"); }
|           %empty { $$.nd = make_node(NULL, NULL, "null"); }
;
paramdecl:  paramdecl COMMA_OP typename IDENTIFIER {
    add('V');
    param_ip++;
    $4.nd = make_node(NULL, NULL, yytext);
    node* temp = make_node($3.nd, $4.nd, "param");
    $$.nd = make_node($1.nd, temp, "par_decl");
}
|           typename IDENTIFIER {
    add('V');
    param_ip++;
    $2.nd = make_node(NULL, NULL, yytext);
    $$.nd = make_node($1.nd, $2.nd, "par_decl");
}
;

typename: INT   { insert_type("int");}   {$$.nd = make_node(NULL, NULL, "int");}
|         DOUBLE  { insert_type("double");}   {$$.nd = make_node(NULL, NULL, "double");}
|         STRING  { insert_type("string");}   {$$.nd = make_node(NULL, NULL, "string");}
|         DATE  { insert_type("date");}   {$$.nd = make_node(NULL, NULL, "date");}
|         MONTH   { insert_type("month");}   {$$.nd = make_node(NULL, NULL, "month");}
;

print_list: %empty  { $$.nd = make_node(NULL, NULL, "null"); }
|           print_list COMMA_OP exprs  {$$.nd = make_node($1.nd, $3.nd, "print_ls"); }
;

print_stmt: DISPLAY {add('F');} L_PAREN STRING_LITERAL print_list R_PAREN STM_DELIM {
    $4.nd = make_node(NULL, NULL, "str");
    $$.nd = make_node($4.nd, $5.nd, "print");
}
;

inp_list: %empty  { $$.nd = make_node(NULL, NULL, "null"); }
|           inp_list COMMA_OP exprs  {$$.nd = make_node($1.nd, $3.nd, "inp_ls"); }
;

inp_stmt: ACCEPT {add('F');} L_PAREN STRING_LITERAL inp_list R_PAREN STM_DELIM {
    $4.nd = make_node(NULL, NULL, "str");
    $$.nd = make_node($4.nd, $5.nd, "input");
}
;

function_call: IDENTIFIER {check_decls($1.name);} L_PAREN par_list { check_function($1.name, param_ip, 0); param_ip = 0; } R_PAREN "->" L_PAREN par_list { check_function($1.name, param_ip, 1); param_ip = 0; } R_PAREN {
    $$.nd = make_node($4.nd, $9.nd, $1.name);
}
;

par_list: %empty  { $$.nd = make_node(NULL, NULL, "null"); }
|           par_list COMMA_OP expr  { $$.nd = make_node($1.nd, $3.nd, "par_ls"); param_ip++; }
|           expr       { $$.nd = make_node($1.nd, NULL, "par_ls"); param_ip++; }
;

stmt: compound_stmt R_BRACE { $$.nd = make_node($1.nd, NULL, "comp_stmt"); }
|     selection_stmt { $$.nd = make_node($1.nd, NULL, "sel_stmt"); }
|     jump_stmt  { $$.nd = make_node($1.nd, NULL, "j_stmt"); }
|     expression_stmt  { $$.nd = make_node($1.nd, NULL, "exp_stmt"); }
|     empty_stmt   {$$.nd = make_node($1.nd, NULL, "emp_stmt"); }
|     vardec_stmt STM_DELIM { $$.nd = make_node($1.nd, NULL, "vdec_stmt"); }
|     iteration_stmt  { $$.nd = make_node($1.nd, NULL, "it_stmt"); }
|     print_stmt  { $$.nd = make_node($1.nd, NULL, "pr_stmt"); }
|     inp_stmt  { $$.nd = make_node($1.nd, NULL, "inp_stmt"); }
|     function_call { $$.nd = make_node($1.nd, NULL, "func_call"); }
;

expression_stmt: exprs STM_DELIM { $$.nd = make_node($1.nd, NULL,"expr_stm"); }
;

jump_stmt: CONTINUE {add('K');} STM_DELIM  { $$.nd = make_node(NULL, NULL, "continue"); }
|          BREAK {add('K');} STM_DELIM     { $$.nd = make_node(NULL, NULL, "break"); }
|          FUNCTION_BREAK {add('K');} STM_DELIM      { $$.nd = make_node(NULL, NULL, "f_break"); }
;

empty_stmt: STM_DELIM {$$.nd = make_node(NULL,NULL, "NULL");}
;


vardec_stmt: typename IDENTIFIER { yytext = $2.name; add('V'); $2.nd = make_node(NULL, NULL, $2.name);} ASSIGN initializer {
    node* temp = make_node($1.nd, $2.nd, "type_id");
    $$.nd = make_node(temp, $5.nd, "=");
    check_type($1.name, $5.type);
    int x=search_id($2.name);
    if(x!=-1)
    {
        add_value(x,$5.name);
    }
}
|            typename IDENTIFIER { yytext = $2.name; add('V'); $2.nd = make_node(NULL, NULL, $2.name);
    $$.nd = make_node($1.nd, $2.nd, "vardecl");
}
|            vardec_stmt COMMA_OP IDENTIFIER { yytext = $3.name; add('V'); $3.nd = make_node(NULL, NULL, $3.name);} ASSIGN initializer {
    node* temp = make_node($3.nd, $6.nd, "=");
    $$.nd = make_node($1.nd, temp, "vardecl_st");
    check_type(search_type($3.name), $6.type);
     int x=search_id($3.name);
    if(x!=-1)
    {
        add_value(x,$6.name);
    }
}
|            vardec_stmt COMMA_OP IDENTIFIER { 
    yytext = $3.name;
    add('V'); 
    $3.nd = make_node(NULL, NULL, $3.name);
    $$.nd = make_node($1.nd, $3.nd, "vardecl_st");
} 
;

initializer: expr   { $$.nd = make_node($1.nd, NULL, "init"); }
|            L_BRACE initializer_list R_BRACE   { $$.nd = make_node($2.nd, NULL, "init"); }
;

initializer_list: initializer   { $$.nd = make_node($1.nd, NULL, "init_list"); }
|                 initializer_list COMMA_OP initializer { $$.nd = make_node($1.nd, $3.nd, "init_list"); }
;

compound_stmt:  L_BRACE 
|               compound_stmt stmt  { $$.nd = make_node($1.nd, $2.nd, "stmts"); }
;

else_stmt: ELSE {add('K');} stmt   { $$.nd = make_node($3.nd, NULL, "else"); }
|          %empty               { $$.nd = make_node(NULL, NULL, "null"); }
;

selection_stmt : IF {add('K');} L_PAREN expr R_PAREN stmt else_stmt  { 
    node* temp = make_node($4.nd, $6.nd, "if"); 
    $$.nd = make_node(temp, $7.nd, "select_stm");
}
;

iteration_stmt: LOOP {add('K');} L_PAREN expr R_PAREN stmt       {
    $$.nd = make_node($4.nd, $6.nd, "loop");
}   
;


exprs: expr     { $$.nd = make_node($1.nd, NULL, "expr" ); strcpy($$.type,$1.type); strcpy($$.name,$1.name);}               
|      exprs COMMA_OP expr      { $$.nd = make_node($1.nd, $3.nd, "expr"); }
;


expr: IDENTIFIER              { strcpy(value, yytext); char* id_type = search_type($1.name); strcpy($$.type, id_type); check_decls($1.name); $$.nd = make_node(NULL, NULL, yytext); }
|     NUMBER                  { strcpy(value, yytext); $$.nd = make_node(NULL, NULL, yytext); strcpy($$.type, "int"); } 
|     DOUBLE_CONST            { strcpy(value, yytext); $$.nd = make_node(NULL, NULL, yytext); strcpy($$.type, "double");}
|     STRING_LITERAL          { strcpy(value, yytext); $$.nd = make_node(NULL, NULL, yytext); strcpy($$.type , "string"); }
|     DATE                    { strcpy(value, yytext); $$.nd = make_node(NULL, NULL, yytext); strcpy($$.type, "date"); }
|     MONTH                   { strcpy(value, yytext); $$.nd = make_node(NULL, NULL, yytext); strcpy($$.type, "month"); } 
|     L_PAREN exprs R_PAREN        { $$.nd = make_node($2.nd, NULL, "exprs"); strcpy($$.type,$2.type);char* temp=strcat($1.name,$2.name); strcpy($$.name,strcat(temp,$3.name));}
|     expr ASSIGN expr             { $$.nd = make_node($1.nd, $3.nd, "="); check_type($1.type, $3.type); int x=search_id($1.name);  if(x!=-1){ add_value(x,$3.name); }}
|     expr ADDITION_OP expr        { $$.nd = make_node($1.nd, $3.nd, "+"); check_type($1.type, $3.type);char* temp=strcat($1.name,"+"); strcpy($$.name,strcat(temp,$3.name));}
|     expr SUBTRACT_OP expr %prec ADDITION_OP   { $$.nd = make_node($1.nd, $3.nd, "-"); check_type($1.type, $3.type); char* temp=strcat($1.name,"-"); strcpy($$.name,strcat(temp,$3.name)); }
|     expr MULTI_OP expr                { $$.nd = make_node($1.nd, $3.nd, "*"); check_type($1.type, $3.type); char* temp=strcat($1.name,"*"); strcpy($$.name,strcat(temp,$3.name));}
|     expr DIV_OP expr %prec MULTI_OP   { $$.nd = make_node($1.nd, $3.nd, "/"); check_type($1.type, $3.type); char* temp=strcat($1.name,"/"); strcpy($$.name,strcat(temp,$3.name));}
|     expr MOD_OP expr          { $$.nd = make_node($1.nd, $3.nd, "%"); check_type($1.type, $3.type); char* temp=strcat($1.name,"%"); strcpy($$.name,strcat(temp,$3.name));}
|     expr "+=" expr            { $$.nd = make_node($1.nd, $3.nd, "+="); check_type($1.type, $3.type);int x=search_id($1.name); char* temp=strcat($1.name,"+"); strcpy($$.name,strcat(temp,$3.name)); if(x!=-1){ add_value(x,$$.name); }}
|     expr "-=" expr            { $$.nd = make_node($1.nd, $3.nd, "-="); check_type($1.type, $3.type);int x=search_id($1.name); char* temp=strcat($1.name,"-"); strcpy($$.name,strcat(temp,$3.name)); if(x!=-1){ add_value(x,$$.name); }}
|     "++" expr                 { $$.nd = make_node( NULL,$2.nd, "++"); check_type($2.type, "int") ; int x=search_id($2.name); char* temp=strcat($2.name,"+"); strcpy($$.name,strcat(temp,"1")); if(x!=-1){ add_value(x,$$.name); }}
|     "--" expr %prec INC_OP    { $$.nd = make_node(NULL, $2.nd, "--"); check_type($2.type, "int") ; int x=search_id($2.name);   char* temp=strcat($2.name,"-"); strcpy($$.name,strcat(temp,"1"));if(x!=-1){ add_value(x,$$.name); }}
|     expr "++"                 { $$.nd = make_node($1.nd, NULL, "++"); check_type($1.type, "int") ; int x=search_id($1.name); char* temp=strcat($1.name,"+"); strcpy($$.name,strcat(temp,"1")); if(x!=-1){ add_value(x,$$.name);} }
|     expr "--" %prec INC_OP    { $$.nd = make_node($1.nd, NULL, "--"); check_type($1.type, "int") ; int x=search_id($1.name); char* temp=strcat($1.name,"-"); strcpy($$.name,strcat(temp,"1"));  if(x!=-1){ add_value(x,$$.name); }}
|     expr LESSER_OP expr       { $$.nd = make_node($1.nd, $3.nd, "<"); check_type($1.type, $3.type); }
|     expr GREATER_OP expr      { $$.nd = make_node($1.nd, $3.nd, ">"); check_type($1.type, $3.type); }
|     expr GE_OP expr           { $$.nd = make_node($1.nd, $3.nd, ">="); check_type($1.type, $3.type);}
|     expr LE_OP expr           { $$.nd = make_node($1.nd, $3.nd, "<="); check_type($1.type, $3.type);}
|     expr OR_OP expr           { $$.nd = make_node($1.nd, $3.nd, "|"); check_type($1.type, $3.type); }
|     expr AND_OP expr          { $$.nd = make_node($1.nd, $3.nd, "&"); check_type($1.type, $3.type); }
|     expr EQ_OP expr           { $$.nd = make_node($1.nd, $3.nd, "=="); check_type($1.type, $3.type); }
|     expr NE_OP expr %prec EQ_OP    { $$.nd = make_node($1.nd, $3.nd, "!="); check_type($1.type, $3.type); }
|     expr POWER expr                { $$.nd = make_node($1.nd, $3.nd, "^"); check_type($1.type, $3.type); char* temp=strcat($1.name,"^"); strcpy($$.name,strcat(temp,$3.name));}               
|     SUBTRACT_OP expr               { $$.nd = make_node(NULL, $2.nd, "neg"); strcpy($$.type, $2.type); printf("%s\n", $2.type); check_type($2.type, "int") ;}
|     NOT_OP expr                    { $$.nd = make_node(NULL, $2.nd, "not"); }
;

%%



int main() {
	yyparse();
    printf("\n\n");
    printf("\nSYMBOL          DATATYPE         TYPE                 LINENO         INP_PARAM       OP_PARAM           VALUE \n");
    printf("--------------------------------------------------------------------------------------------------------------------\n");

    for(int i = 0; i < count; i++)
    {
        printf("%s\t\t%s\t\t%s\t\t%d\t\t%d\t\t%d\t\t%s\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].param_cnt_ip, symbol_table[i].param_cnt_op, symbol_table[i].value);
        printf("--------------------------------------------------------------------------------------------------------------------\n");
    }

    for(int i = 0; i < count; i++)
    {
        free(symbol_table[i].id_name);
        free(symbol_table[i].type);
    }

    printf("\n\n\n\n");
    levelTree(head, 0);
    printf("\n\n\n\n");

    if(semantic_err > 0) 
    {
        printf("%d errors found in semantic analysis.\nErrors are:\n", semantic_err);
        for(int i = 0; i < semantic_err; i++)
        {
            printf("\t %s", error_list[i]);
        }
    }
    else{
        printf("No errors found in semantic analysis.\n");
    }
}


void yyerror () {   
	fprintf(stderr, "Parsing failed here.\nSyntax Error!\n");    
} 
