
char* search_type(char* name)
{
    for(int i = 0; i < count; i++)
    {
        if(strcmp(symbol_table[i].id_name, name) == 0)
        {
            return symbol_table[i].data_type;
        }
    }
    return "null";
}

void check_decls(char* c)
{
    q = search(c);
    if(q == 0)
    {
        sprintf(error_list[semantic_err], "Line %d: Variable \"%s\" Using undeclared variable...\n", line_count, c);
        semantic_err++;
    }
}

int check_type(char* a, char* b)
{
    int result;
    // if datatypes not compatible result = -2 

    if( !strcmp(a, b)) result = 0;
    else if( !strcmp(a, "int") && !strcmp(b, "double"))
    {
        result = 1;
    }
    else if( !strcmp(a, "double") && !strcmp(b, "int"))
    {
        result = 2;
    }
    else
    {
        result = -2;
        sprintf(error_list[semantic_err], "Line %d: Operands of different types (%s, %s)\n", line_count, a, b);
        semantic_err++;
    }
    return result;
}

void check_function(char* name, int num, int type)
{
    if(type == 0) //input
    {
        int c = symbol_table[search_id(name)].param_cnt_ip;
        if(c != num)
        {
            sprintf(error_list[semantic_err], "Line %d: Number of input parameters for \"%s\" do not match. Expected: %d, Given: %d\n", line_count, name, c, num);
            semantic_err++;
        }
    }
    else { //output
        int c = symbol_table[search_id(name)].param_cnt_op;
        if(c != num)
        {
            sprintf(error_list[semantic_err], "Line %d: Number of output parameters for \"%s\" do not match. Expected: %d, Given: %d\n", line_count, name, c, num);
            semantic_err++;
        }
    }
}