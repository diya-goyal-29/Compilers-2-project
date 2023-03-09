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

    typedef struct node {
        struct node *left;
        struct node* right;
        char *token;
    }node;

    node* head;

    void printtree(node*);
    void printInorder(node *);
    void levelTree(node*, int);
    node* make_node(node *left, node *right, char *token);

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

%union {
    struct var_name {
        char name[100];
        struct node* nd;
    } ast_node;
}

%type<ast_node> ASSIGN SUBTRACT_OP ADDITION_OP MULTI_OP DIV_OP AND_OP L_PAREN R_PAREN
MOD_OP OR_OP COMMA_OP STM_DELIM COLON_OP L_BRACE R_BRACE L_BRAKET R_BRAKET INC_OP 
DEC_OP ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN LESSER_OP GREATER_OP 
NE_OP EQ_OP GE_OP LE_OP ARROW BREAK CONTINUE FUNCTION_BREAK IF ELSE LOOP INT DOUBLE
STRING DATE MONTH IDENTIFIER NUMBER DOUBLE_CONST STRING_LITERAL NOT_OP POWER ERROR 
DISPLAY

%type<ast_node> declarations declaration function vardec_stmt paramdecls compound_stmt
paramdecl typename print_list exprs print_stmt stmt selection_stmt jump_stmt expression_stmt
empty_stmt iteration_stmt initializer initializer_list program expr else_stmt

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

function: IDENTIFIER {add('K');} COLON_OP L_PAREN paramdecls R_PAREN "->" L_PAREN paramdecls R_PAREN compound_stmt R_BRACE 
{
    $5.nd->token = "inp_param";
    $9.nd->token = "out_param";
    node* temp = make_node($5.nd, $9.nd, "params");
    $$.nd = make_node(temp,$11.nd , $1.name);
}
;

paramdecls: paramdecl  {$$.nd = make_node($1.nd, NULL, "par_decls"); }
|           %empty { $$.nd = make_node(NULL, NULL, "null"); }
;
paramdecl:  paramdecl COMMA_OP typename IDENTIFIER {
    $4.nd = make_node(NULL, NULL, yytext);
    node* temp = make_node($3.nd, $4.nd, "param");
    $$.nd = make_node($1.nd, temp, "par_decl");
}
|           typename IDENTIFIER {
    $2.nd = make_node(NULL, NULL, yytext);
    $$.nd = make_node($1.nd, $2.nd, "par_decl");
}
;
typename: INT   { insert_type("int");}   {$$.nd = make_node(NULL, NULL, "int");}
|         CHAR   { insert_type("char");}  {$$.nd = make_node(NULL, NULL, "char");}
|         DOUBLE  { insert_type("double");}   {$$.nd = make_node(NULL, NULL, "double");}
|         STRING  { insert_type("string");}   {$$.nd = make_node(NULL, NULL, "string");}
|         DATE  { insert_type("date");}   {$$.nd = make_node(NULL, NULL, "date");}
|         MONTH   { insert_type("month");}   {$$.nd = make_node(NULL, NULL, "month");}
// |         ARRAY 
;

print_list: %empty  { $$.nd = make_node(NULL, NULL, "null"); }
|           print_list COMMA_OP exprs  {$$.nd = make_node($1.nd, $3.nd, "print_l"); }
;

print_stmt: DISPLAY {add('K');} L_PAREN STRING_LITERAL print_list R_PAREN STM_DELIM {
    $4.nd = make_node(NULL, NULL, "str");
    $$.nd = make_node($4.nd, $5.nd, "print");
}
;

stmt: compound_stmt R_BRACE { $$.nd = make_node($1.nd, NULL, "comp_stmt"); }
|     selection_stmt { $$.nd = make_node($1.nd, NULL, "sel_stmt"); }
|     jump_stmt  { $$.nd = make_node($1.nd, NULL, "j_stmt"); }
|     expression_stmt  { $$.nd = make_node($1.nd, NULL, "exp_stmt"); }
|     empty_stmt   {$$.nd = make_node($1.nd, NULL, "emp_stmt"); }
|     vardec_stmt STM_DELIM { $$.nd = make_node($1.nd, NULL, "vdec_stmt"); }
|     iteration_stmt  { $$.nd = make_node($1.nd, NULL, "it_stmt"); }
|     print_stmt  {$$.nd = make_node($1.nd, NULL, "pr_stmt");}
;

expression_stmt: exprs STM_DELIM { $$.nd = make_node($1.nd, NULL,"expr_stm"); }
;

jump_stmt: CONTINUE {add('K');} STM_DELIM  { $$.nd = make_node(NULL, NULL, "continue"); /*$$.nd = make_node($1.nd, NULL, "jump_stm"); */}
|          BREAK {add('K');} STM_DELIM     { $$.nd = make_node(NULL, NULL, "break"); /*$$.nd = make_node($1.nd, NULL, "jump_stm"); */}
|          FUNCTION_BREAK {add('K');} STM_DELIM      { $$.nd = make_node(NULL, NULL, "f_break"); /*$$.nd = make_node($1.nd, NULL, "jump_stm");*/ }
;

empty_stmt: STM_DELIM {$$.nd = make_node(NULL,NULL, "NULL");}
;


vardec_stmt: typename IDENTIFIER { printf("*************************%s\n", yytext); yytext = $2.name; add('V'); $2.nd = make_node(NULL, NULL, $2.name);} ASSIGN initializer {
    node* temp = make_node($1.nd, $2.nd, "type_id");
    $$.nd = make_node(temp, $5.nd, "=");
}
|            typename IDENTIFIER { yytext = $2.name; add('V'); $2.nd = make_node(NULL, NULL, $2.name);
    $$.nd = make_node($1.nd, $2.nd, "vardecl");

}
|            vardec_stmt COMMA_OP IDENTIFIER { yytext = $3.name; add('V'); $3.nd = make_node(NULL, NULL, $3.name);} ASSIGN initializer {
    node* temp = make_node($3.nd, $6.nd, "=");
    $$.nd = make_node($1.nd, temp, "vardecl_st");
}
|            vardec_stmt COMMA_OP IDENTIFIER { 
    yytext = $3.name;
    add('V'); 
    $3.nd = make_node(NULL, NULL, $3.name);
    $$.nd = make_node($1.nd, $3.nd, "vardecl_st");
} 
;

// vardec1:  ASSIGN initializer {
//     $1.nd = make_node($$.nd, $2.nd, "assign");
// }
// |         %empty  {  }
// ; 

initializer: expr   { $$.nd = make_node($1.nd, NULL, "init"); }
|            L_BRACE initializer_list R_BRACE   { $$.nd = make_node($2.nd, NULL, "init"); }
;

initializer_list: initializer   { $$.nd = make_node($1.nd, NULL, "init_list"); }
|                 initializer_list COMMA_OP initializer { $$.nd = make_node($1.nd, $3.nd, "init_list"); }
;


compound_stmt:  L_BRACE 
|               compound_stmt stmt  { $$.nd = make_node($1.nd, $2.nd, "stmts"); }
;

/*
selection_stmt: IF p_expr stmt %prec LOWER_THAN_ELSE  
|               IF p_expr stmt ELSE {add('K');} stmt   
;
*/

else_stmt: //p_expr stmt %prec LOWER_THAN_ELSE  {printf("***********************%s*********************\n", $1.name)}
           ELSE {add('K');} stmt   { $$.nd = make_node($3.nd, NULL, "else"); }
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

/*
p_expr: L_PAREN expr R_PAREN 
;
*/


exprs: expr     { $$.nd = make_node($1.nd, NULL, "expr" ); }               
|      exprs COMMA_OP expr      { $$.nd = make_node($1.nd, $3.nd, "expr"); }
;


expr: IDENTIFIER               {strcpy(value, yytext);add_value(count-1,value); $$.nd = make_node(NULL, NULL, yytext); /*$$.nd = make_node($1.nd, NULL, "expr");*/}
|     NUMBER                  {strcpy(value, yytext);add_value(count-1,value); $$.nd = make_node(NULL, NULL, yytext); /*$$.nd = make_node($1.nd, NULL, "expr");*/} 
|     DOUBLE_CONST             { strcpy(value, yytext);add_value(count-1,value); $$.nd = make_node(NULL, NULL, yytext);}
|     STRING_LITERAL          { strcpy(value, yytext);add_value(count-1,value); $$.nd = make_node(NULL, NULL, yytext);}
|     DATE                    {strcpy(value, yytext);add_value(count-1,value); $$.nd = make_node(NULL, NULL, yytext);}
|     MONTH                   { strcpy(value, yytext);add_value(count-1,value); $$.nd = make_node(NULL, NULL, yytext);} 
|     L_PAREN exprs R_PAREN    { $$.nd = make_node($2.nd, NULL, "exprs"); }
//|     expr L_BRAKET exprs R_BRAKET      { $$.nd = make_node($1.nd, $3.nd, "exprs"); }
// |     expr L_PAREN R_PAREN              
// |     expr L_PAREN exprs R_PAREN
|     expr ASSIGN expr             { $$.nd = make_node($1.nd, $3.nd, "="); }
|     expr ADDITION_OP expr         { $$.nd = make_node($1.nd, $3.nd, "+"); }
|     expr SUBTRACT_OP expr %prec ADDITION_OP   { $$.nd = make_node($1.nd, $3.nd, "-"); }
|     expr MULTI_OP expr             { $$.nd = make_node($1.nd, $3.nd, "*"); }
|     expr DIV_OP expr %prec MULTI_OP   { $$.nd = make_node($1.nd, $3.nd, "/"); }
|     expr MOD_OP expr             { $$.nd = make_node($1.nd, $3.nd, "%"); }
|     expr "+=" expr            { $$.nd = make_node($1.nd, $3.nd, "+="); }
|     expr "-=" expr            { $$.nd = make_node($1.nd, $3.nd, "-="); }
|     "++" expr                 { $$.nd = make_node( NULL,$2.nd, "++"); }
|     "--" expr %prec INC_OP      { $$.nd = make_node(NULL, $2.nd, "--"); }
|     expr "++"                 { $$.nd = make_node($1.nd, NULL, "++"); }
|     expr "--" %prec INC_OP      { $$.nd = make_node($1.nd, NULL, "--"); }
|     expr LESSER_OP expr           { $$.nd = make_node($1.nd, $3.nd, "<"); }
|     expr GREATER_OP expr          { $$.nd = make_node($1.nd, $3.nd, ">"); }
|     expr GE_OP expr          { $$.nd = make_node($1.nd, $3.nd, ">="); }
|     expr LE_OP expr          { $$.nd = make_node($1.nd, $3.nd, "<="); }
|     expr OR_OP expr           { $$.nd = make_node($1.nd, $3.nd, "|"); }
|     expr AND_OP expr             { $$.nd = make_node($1.nd, $3.nd, "&"); }
|     expr EQ_OP expr           { $$.nd = make_node($1.nd, $3.nd, "=="); }
|     expr NE_OP expr %prec EQ_OP   { $$.nd = make_node($1.nd, $3.nd, "!="); }
|     expr POWER expr                { $$.nd = make_node($1.nd, $3.nd, "^"); }
// |     MULTI_OP expr                 
|     SUBTRACT_OP expr              { $$.nd = make_node(NULL, $2.nd, "neg"); }
|     NOT_OP expr                  { $$.nd = make_node(NULL, $2.nd, "not"); }
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

    // printf("\n\n");
    // printtree(head);

    printf("\n\n\n\n");
    levelTree(head, 0);
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

node* make_node(node* left, node* right, char *token)
{
    node *newNode = (node*) malloc (sizeof(node));
    char* newToken = (char*) malloc(strlen(token)+1);
    strcpy(newToken, token);
    newNode->left = left;
    newNode->right = right;
    newNode->token = newToken;

    return newNode;
}

void printtree(node* tree) {
	printf("\n\n Inorder traversal of the Parse Tree: \n\n");
	printInorder(tree);
	printf("\n\n");
}

void printInorder(node *tree) {
	int i;
	if (tree->left) {
		printInorder(tree->left);
	}
	printf("%s, ", tree->token);
	if (tree->right) {
		printInorder(tree->right);
	}
}

// void levelTree (node* root, int level)
// {
//     if(root == NULL) {
//         printf("| N/A\n");
//         return ;
//     }
    
//     for(int i = 0; i < level; i++)
//     {
//         printf(i==level-1 ? "| " : " " );
//     }
//     printf("%s\n", root->token);
//     levelTree(root->left, level+1);
//     levelTree(root->right, level+1);
// }

void levelTree(node* root, int space)
{
    if(root == NULL){
        return;
    } 
    space += 10;
    levelTree(root->right, space);
    // printf("\n");
    for(int i = 10; i < space; i++)
    {
        printf(" ");
    }
    printf("%s\n", root->token);
    levelTree(root->left, space);

}

void yyerror () {
   
	fprintf(stderr, "Parsing failed here.\nSyntax Error!\n");
    
} 
