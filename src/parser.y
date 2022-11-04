%{
#include <stdlib.h>

extern int yylex(void);
int yyerror(char const *s);
%}
%token PROGRAM IDENTIFICADOR BEGIN END VAR CONST ENTERO

%%
programa:
    PROGRAM IDENTIFICADOR '(' identificador_lista ')' ';' declaraciones subprograma_declaraciones instruccion_compuesta '.'
    ;
identificador_lista:
    IDENTIFICADOR
    | identificador_lista ',' IDENTIFICADOR
    ;
declaraciones:
    declaraciones_variables
    | declaraciones_constantes
    ;
declaraciones_variables:
    declaraciones_variables VAR identificador_lista ':' tipo ';'
    | /* empty */
    ;
tipo:
    estandar_tipo
    | ARRAY '[' ENTERO ".." ENTERO ']' OF estandar_tipo
    ;
declaraciones_constantes:
    declaraciones_constantes CONST IDENTIFICADOR '=' constante_entera ';'
    | declaraciones_constantes CONST IDENTIFICADOR '=' constante_real ';'
    | declaraciones_constantes CONST IDENTIFICADOR '=' constante_cadena ';'
    | /* empty */
    ;
subprograma_declaraciones:
    subprograma_declaraciones subprograma_declaracion ';'
    | /* empty */
    ;
instruccion_compuesta:
    BEGIN instrucciones_opcionales END
    ;
%%

int yyerror(char const *s)
{
    exit(1);
    return 0;
}