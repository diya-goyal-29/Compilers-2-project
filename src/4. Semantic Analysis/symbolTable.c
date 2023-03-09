void add(char c)
{
    if(c == 'V' || c == 'F')
    {
        for(int i = 0; i < 17; i++)
        {
            if( !strcmp(reserved[i], strdup(yytext)))
            {   if(c == 'F')
                {
                    if(!strcmp(yytext, "display") || !strcmp(yytext, "execute") || !strcmp(yytext, "accept"))
                    {
                        break;
                    }
                }
                if(c == 'V')
                    sprintf(error_list[semantic_err], "Line %d: Variable used here \"%s\" is a keyword.\n", line_count, yytext);
                else {
                    sprintf(error_list[semantic_err], "Line %d: Function used here \"%s\" is a keyword.\n", line_count, yytext);
                }
                semantic_err++;
                return;
            }
        }
    }

    q = search(yytext);
    if(!q)
    {
        if(c == 'K')
        {
            symbol_table[count].id_name = strdup(yytext);
            symbol_table[count].data_type = strdup("N/A");
            symbol_table[count].line_no = line_count;
            symbol_table[count].type = strdup("keyword\t");
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
            symbol_table[count].data_type = strdup("null");
            symbol_table[count].line_no = line_count;
            symbol_table[count].type = strdup("function");
            symbol_table[count].value = 0;
            count++;
        }
    }
    else if((c == 'V') && q)
    {
        sprintf(error_list[semantic_err], "Line %d: Multiple declarations of \"%s\" \n", line_count, yytext);
        semantic_err++;
    }
}

int search(char *temp)
{
    int i;
    for(i = count-1; i >= 0; i--)
    {
        if(strcmp(symbol_table[i].id_name, temp) == 0)
        {
            return -1;
        }
    }
    return 0;
}

void insert_type(char *s)
{
    strcpy(type, s);
}

void add_value(int count1, char *value)
{
    symbol_table[count1].value = strdup(value);
}

int search_id(char* name)
{
    for(int i = 0; i < count; i++)
    {
        if(strcmp(symbol_table[i].id_name, name) == 0)
        {
            return i;
        }
    }
    return -1;
}
