#include <errno.h>

#include "parser.tab.h"
#include "lexer.lex.h"
#include "tree.h"
#include "hash_map.h"
#include "codegen.h"


extern struct tree_node* root;
extern list_ptr symbol_table[];


int main(int argc, char *argv[])
{
    char* infilename;
    char* outfilename;
    if (argc > 1)
    {
        infilename = strdup(argv[1]);
        yyin = fopen(infilename, "r");
        if (!yyin)
            return(EINVAL);
        printf("Escaneando: %s\n", infilename);
        int infilelen = strlen(infilename);
        outfilename = malloc((infilelen + 8) * sizeof(char));
        strcpy(outfilename, infilename);
        strcpy(outfilename + infilelen, ".c");
        yyout = fopen(outfilename, "w");
        // yyout = stdout;
    }
    else
        return(1);

    yyparse();
    puts("Entrada válida");
    print_list(symbol_table);
    print_tree(root);
    printf("Generando: %s\n", outfilename);
    process_program(root);
}