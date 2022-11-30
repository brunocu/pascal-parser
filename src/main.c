#include <errno.h>

#include "parser.tab.h"
#include "lexer.lex.h"
#include "tree.h"
#include "hash_map.h"


extern struct tree_node* root;
extern list_ptr symbol_table[];


int main(int argc, char *argv[])
{
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
        if (!yyin)
            return(EINVAL);
        printf("Analizando: %s\n", argv[1]);
    }
    else
        return(1);

    yyparse();
    print_tree(root);

    print_list(symbol_table);

    puts("Entrada válida");
}