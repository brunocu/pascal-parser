#include "parser.tab.h"
#include "lexer.lex.h"
#include "tree.h"
#include <errno.h>

extern struct tree_node* root;

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
    puts("Entrada válida");
}