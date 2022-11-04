%{
#include <stdlib.h>

extern int yylex(void);
int yyerror(char const *s);
%}
%token PROGRAM IDENTIFICADOR BEGIN END VAR CONST ENTERO OF 
INTEGER REAL STRING BOOLEAN WHILE DO FOR TO DOWNTO READ READLN WRITE WRITELN CADENA
IF THEN ELSE TWO_DOTS ASSIGNMENT OR AND NOT FUNCTION PROCEDURE ARRAY

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
    | ARRAY '[' ENTERO TWO_DOTS ENTERO ']' OF estandar_tipo
    ;
estandar_tipo:
    INTEGER
    | REAL
    | STRING 
    | BOOLEAN
    ;
relop:
    AND | OR
    ;
addop:
    '+' | '-'
    ;
mulop:
    '*' | '/'
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
subprograma_declaracion:
    subprograma_encabezado declaraciones subprograma_declaraciones instruccion_compuesta
    ;
subprograma_encabezado:
    FUNCTION IDENTIFICADOR argumentos ':' estandar_tipo ';'
    | PROCEDURE IDENTIFICADOR argumentos ';'
    ;
argumentos:
    '(' parametros_lista ')'
    | /*empty*/
    ;
parametros_lista:
    identificador_lista ':' tipo 
    | parametros_lista ';' identificador_lista ':' tipo
    ;
instruccion_compuesta:
    BEGIN instrucciones_opcionales END
    ;
instrucciones_opcionales:
    instrucciones_lista 
    | /*empty*/
    ;
instrucciones_lista:
    instrucciones 
    | instrucciones_lista ';' instrucciones
    ;
instrucciones:
    variable_asignacion
    | procedure_instruccion
    | instruccion_compuesta
    | if_instruccion
    | repeticion_instruccion
    | lectura_instruccion
    | escritura_instruccion
    ;
repeticion_instruccion:
    WHILE relop_expresion DO instrucciones
    | FOR for_asignacion TO expresion DO instrucciones
    | FOR for_asignacion DOWNTO expresion DO instrucciones
    ;
lectura_instruccion:
    READ '(' IDENTIFICADOR ')'
    | READLN '(' IDENTIFICADOR ')'
    ;
escritura_instruccion:
    WRITE '(' constante_cadena ',' IDENTIFICADOR ')'
    | WRITELN '(' constante_cadena ',' IDENTIFICADOR ')'
    | WRITE '(' constante_cadena ')'
    | WRITELN '(' constante_cadena ')'
    | WRITE '(' constante_cadena ',' expresion ')'
    | WRITELN '(' constante_cadena ',' expresion ')'
constante_cadena:
    CADENA
    ;
if_instruccion:
    IF relop_expresion THEN instrucciones
    | IF relop_expresion THEN instrucciones ELSE instrucciones
    ;
variable_asignacion:
    variable ASSIGNMENT expresion
    ;
for_asignacion:
    variable_asignacion
    | variable
    ;
variable:
    IDENTIFICADOR
    | IDENTIFICADOR '[' expresion ']'
    ;
procedure_instruccion:
    IDENTIFICADOR
    | IDENTIFICADOR '(' expresion_lista ')'
    ;
relop_expresion:
    relop_expresion OR relop_and
    | relop_and
    ;
relop_and:
    relop_and AND relop_not
    | relop_not
    ;
relop_not:
    NOT relop_not
    | relop_paren
    ;
relop_paren:
    '(' relop_expresion ')' | relop_expresion_simple
    ;
relop_expresion_simple:
    expresion relop expresion
    ;
expresion_lista:
    expresion
    | expresion_lista ',' expresion
    ;
expresion:
    termino
    | expresion addop termino
    ;
termino:
    factor
    | termino mulop factor
    ;
llamado_funcion:
    IDENTIFICADOR '(' expresion_lista ')'
    ;
factor:
    IDENTIFICADOR
    | IDENTIFICADOR '[' expresion ']'
    | llamado_funcion
    | constante_entera
    | constante_real
    | signo factor
    | '(' expresion ')'
    ;
signo:
    '+'
    | '-'
    | /*empty*/
    ;
constante_entera:
    signo ENTERO
    ;
constante_real:
    signo ENTERO '.' ENTERO
    | signo ENTERO '.' ENTERO exponente
    ;
exponente:
    'e' signo ENTERO
    | 'E' signo ENTERO
    | /*empty*/
    ;
%%

int yyerror(char const *s)
{
    exit(1);
    return 0;
}