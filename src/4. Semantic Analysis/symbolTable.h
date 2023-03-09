struct dataType {
    char * id_name;
    char * data_type;
    char * type;
    char * value ; 
    int line_no;
    int param_cnt_ip;
    int param_cnt_op;    
} symbol_table[200];

int count = 0;
int q;
char type[30];
char value[70];
int param_ip = 0;
int param_op = 0;  


void insert_type();
void add_value(int count, char *value);
void add(char c);
int search(char *type);
int search_id(char* name);

