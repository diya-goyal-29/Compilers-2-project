%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include<ctype.h>
    #include"lex.yy.c"
    void yyerror();
    int yylex();
   

    struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        char * value ; //edit 
        int line_no;
        int val_i;
        double val_d;
        
    } symbol_table[100];

    int count = 0;
    int q;
    char type[20];
    char value[50];
    
    // symbol table functions
    void insert_type();
    void add_value(int count, char *value);
    void add(char c);
    int search(char *type);
    extern int line_count;
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

function: IDENTIFIER {add('K');} COLON_OP L_PAREN paramdecls R_PAREN "->" L_PAREN paramdecls R_PAREN compound_stmt R_BRACE 
;
paramdecls: paramdecl
|           %empty
;
paramdecl:  paramdecl COMMA_OP typename IDENTIFIER 
|           typename IDENTIFIER 
;
typename: INT   { insert_type("int");}
|         CHAR   { insert_type("char");}
|         DOUBLE  { insert_type("double");}
|         STRING  { insert_type("string");}
|         DATE  { insert_type("date");}
|         MONTH   { insert_type("month");}
// |         ARRAY 
;

print_list: %empty
|           print_list COMMA_OP exprs 
;

print_stmt: DISPLAY {add('K');} L_PAREN STRING_LITERAL print_list R_PAREN STM_DELIM
;

stmt: compound_stmt R_BRACE 
|     selection_stmt1
|     jump_stmt
|     expression_stmt
|     empty_stmt
|     vardec_stmt STM_DELIM 
|     iteration_stmt
|     print_stmt
;

expression_stmt: exprs STM_DELIM 
;

jump_stmt: CONTINUE {add('K');} STM_DELIM 
|          BREAK {add('K');} STM_DELIM  
|          FUNCTION_BREAK {add('K');} STM_DELIM                  
;

empty_stmt: STM_DELIM
;




vardec_stmt: typename IDENTIFIER { add('V');} vardec1 
|            vardec_stmt COMMA_OP vardec1 
;
vardec1:  ASSIGN initializer 
|         %empty
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

/*
selection_stmt: IF p_expr stmt %prec LOWER_THAN_ELSE  
|               IF p_expr stmt ELSE {add('K');} stmt   
;
*/

selection_stmt: p_expr stmt %prec LOWER_THAN_ELSE  
|               p_expr stmt ELSE {add('K');} stmt   
;

selection_stmt1 : IF {add('K');} selection_stmt ;

iteration_stmt: LOOP {add('K');} p_expr stmt          
;
p_expr: L_PAREN expr R_PAREN 
;
exprs: expr                     
|      exprs COMMA_OP expr         
;


expr: IDENTIFIER               {strcpy(value, yytext);add_value(count-1,value);}
|     NUMBER                  {strcpy(value, yytext);add_value(count-1,value);} 
|     DOUBLE_CONST             { strcpy(value, yytext);add_value(count-1,value);}
|     STRING_LITERAL          { strcpy(value, yytext);add_value(count-1,value);}
|     DATE                    {strcpy(value, yytext);add_value(count-1,value); printf("\n\n-----heloo-----%s\n",yytext);}
|     MONTH                   { strcpy(value, yytext);add_value(count-1,value);} 
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
	yyparse();
    printf("\n\n");
    printf("\nSYMBOL          DATATYPE         TYPE                  LINENO      VALUE  \n");
    for(int i = 0; i < count; i++)
    {
        if(! strcmp(symbol_table[i].type, "keyword"))
        {
            // printf("keyword\n");
            symbol_table[i].value = NULL;
        }
        printf("%s \t\t%s \t\t%s \t\t%d \t\t %s\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no , symbol_table[i].value);
    }

    for(int i = 0; i < count; i++)
    {
        free(symbol_table[i].id_name);
        free(symbol_table[i].type);
    }

    printf("\n\n");
}
int search(char *type)
{
    int i;
    for(i = count-1; i >= 0; i--)
    {
        if(strcmp(symbol_table[i].id_name, type) == 0)
        {
            return -1;
            // break;
        }
    }
    return 0;
}





void add(char c)
{
    q = search(yytext);
    if(!q)
    {
        if(c == 'K')
        {
            symbol_table[count].id_name = strdup(yytext);
            symbol_table[count].data_type = strdup("N/A");
            symbol_table[count].line_no = line_count;
            symbol_table[count].type = strdup("keyword");
            symbol_table[count].value = 0;
            count++;
        }
        else if(c == 'V')
        {
            symbol_table[count].id_name = strdup(yytext);
            symbol_table[count].data_type = strdup(type);
            symbol_table[count].line_no = line_count;
            symbol_table[count].type = strdup("variable");
            symbol_table[count].value = 0;
            count++;
        }
        else if(c == 'F')
        {
            symbol_table[count].id_name = strdup(yytext);
            symbol_table[count].data_type = strdup(type);
            symbol_table[count].line_no = line_count;
            symbol_table[count].type = strdup("function");
            symbol_table[count].value = 0;
            count++;
        }
    }
}

void insert_type(char *s)
{
    strcpy(type, s);
}

void add_value(int count, char *value)
{
    symbol_table[count].value = strdup(value);
    // printf("\n----INside function-------%s   %d\n" , yytext, symbol_table[count-1].line_no);
   
}

void yyerror () {
   
	fprintf(stderr, "Parsing failed here.\nSyntax Error!\n");
    
} 