%{
#include <stdlib.h>

extern int yylex(void);
int yyerror(char const *s);
%}
%token PROGRAM IDENTIFICADOR

%%
programa:
    PROGRAM IDENTIFICADOR '(' identificador_lista ')' ';' declaraciones subprograma_declaraciones instruccion_compuesta '.'
    ;
identificador_lista:
    IDENTIFICADOR
    | identificador_lista ',' IDENTIFICADOR
    ;
%%

int yyerror(char const *s)
{
    exit(1);
    return 0;
}