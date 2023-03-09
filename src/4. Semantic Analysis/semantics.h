int label = 0;
char buff[100];

char error_list[30][100];
char reserved[17][30] = {"int", "double", "char", "if", "else", "loop", "execute", "break", "fbreak", "continue", 
    "date", "month", "display", "SIPmaturity", "simpleIntrst", "compoundIntrst", "SIPmaturityDeets"};
int semantic_err = 0;

void check_decls(char*);
int check_type(char*, char*);
char* search_type(char*);
void check_function(char*, int, int);