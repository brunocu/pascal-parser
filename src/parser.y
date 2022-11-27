%{
#include <stdlib.h>
#include <stdio.h>
#include "tree.h"
#include <string.h>

struct tree_node* root;
extern int yylex(void);
int yyerror(char const *s);
%}
%token PROGRAM TOK_IDENTIFICADOR PBEGIN END VAR CONST ENTERO OF 
TOK_INTEGER TOK_REAL TOK_STRING TOK_BOOLEAN WHILE DO FOR TO DOWNTO READ READLN WRITE WRITELN CADENA
IF THEN ELSE TWO_DOTS ASSIGNMENT TOK_OR TOK_AND NOT FUNCTION PROCEDURE ARRAY

%%
programa:
    PROGRAM TOK_IDENTIFICADOR '(' identificador_lista ')' ';' declaraciones subprograma_declaraciones instruccion_compuesta '.'
    {
        root = malloc(sizeof(struct tree_node));
        root->tipo = PROGRAMA;
        root->identificador = strdup($TOK_IDENTIFICADOR);
        tree_add_child(root, $identificador_lista);
        tree_add_child(root, $declaraciones);
        tree_add_child(root, $subprograma_declaraciones);
        tree_add_child(root, $subprograma_declaraciones);
        tree_add_child(root, $instruccion_compuesta);
        $$ = root;
    };
identificador_lista:
    TOK_IDENTIFICADOR
    {
        struct tree_node* id_lista = malloc(sizeof(struct tree_node));
        id_lista->tipo = IDENTIFICADOR_LISTA;
        struct tree_node* identificador_nodo = malloc(sizeof(struct tree_node));
        id_lista->tipo = IDENTIFICADOR;
        identificador_nodo->identificador = strdup($TOK_IDENTIFICADOR);
        tree_add_child(id_lista, identificador);
        $$ = id_lista;
    }
    | identificador_lista ',' TOK_IDENTIFICADOR
    {
        struct tree_node* identificador_nodo = malloc(sizeof(struct tree_node));
        id_lista->tipo = IDENTIFICADOR;
        identificador_nodo->identificador = strdup($TOK_IDENTIFICADOR);
        identificador_nodo->right_sibling = ($1)->left_child;
        tree_add_child($1, identificador_nodo);
        $$ = $1;
    }
    ;
declaraciones:
    declaraciones_variables
    {
        $$ = $1;
    }
    | declaraciones_constantes
    {
        $$ = $1;
    }
    ;
declaraciones_variables:
    declaraciones_variables VAR identificador_lista ':' tipo ';'
    {
        struct tree_node* dec_variables = malloc(sizeof(struct tree_node));
        dec_variables->tipo = DECLARACIONES_VARIABLES;
        tree_add_child(dec_variables, $1);
        tree_add_child(dec_variables, $3);
        tree_add_child(dec_variables, $5);
        $$ = dec_variables;

    }
    | %empty
    {
        struct tree_node* empty_node = malloc(sizeof(struct tree_node));
        empty_node->tipo = EMPTY;
        $$ = empty_node;
    }
    ;
tipo:
    estandar_tipo
    {
        struct tree_node* est_tipo = malloc(sizeof(struct tree_node));
        est_tipo->tipo = ESTANDAR_TIPO;
        est_tipo->data_tipo = $1;
        $$ = est_tipo;
    }
    | ARRAY '[' ENTERO TWO_DOTS ENTERO ']' OF estandar_tipo
    {
        struct tree_node* arr_tipo = malloc(sizeof(struct tree_node));
        struct tree_node* est_tipo = malloc(sizeof(struct tree_node));
        arr_tipo->tipo = ARREGLO_TIPO;
        est_tipo->tipo = ESTANDAR_TIPO;
        est_tipo->data_tipo = $6;
        tree_add_child(arr_tipo, est_tipo);
        $$ = arr_tipo;
    }
    ;
estandar_tipo:
    TOK_INTEGER
    {
        $$ = INTEGER;
    }
    | TOK_REAL
    {
        $$ = REAL;
    }
    | TOK_STRING 
    {
        $$ = STRING;
    }
    | TOK_BOOLEAN
    {
        $$ = BOOLEAN;
    }
    ;
relop:
    TOK_AND
    {
        $$ = AND;
    }
    | TOK_OR
    {
        $$ = OR;
    }
    ;
addop:
    '+' | '-'
    ;
mulop:
    '*' | '/'
    ;
declaraciones_constantes:
    declaraciones_constantes CONST TOK_IDENTIFICADOR '=' constante_entera ';'
    {
        struct tree_node* dec_const = malloc(sizeof(struct tree_node));
        dec_const->tipo = DECLARACIONES_CONSTANTES;
        dec_const->identificador = strdup($TOK_IDENTIFICADOR);
        tree_add_child(dec_const, $1);
        tree_add_child(dec_const, $5);
        $$ = dec_const;
    }
    | declaraciones_constantes CONST TOK_IDENTIFICADOR '=' constante_real ';'
    {
        struct tree_node* dec_const = malloc(sizeof(struct tree_node));
        dec_const->tipo = DECLARACIONES_CONSTANTES;
        dec_const->identificador = strdup($TOK_IDENTIFICADOR);
        tree_add_child(dec_const, $1);
        tree_add_child(dec_const, $5);
        $$ = dec_const;
    }
    | declaraciones_constantes CONST TOK_IDENTIFICADOR '=' constante_cadena ';'
    {
        struct tree_node* dec_const = malloc(sizeof(struct tree_node));
        dec_const->tipo = DECLARACIONES_CONSTANTES;
        dec_const->identificador = strdup($TOK_IDENTIFICADOR);
        dec_const->cadena = strdup($5);
        tree_add_child(dec_const, $1);
        
        $$ = dec_const;
    }
    | %empty
    {
        struct tree_node* empty_node = malloc(sizeof(struct tree_node));
        empty_node->tipo = EMPTY;
        $$ = empty_node;
    }
    ;
subprograma_declaraciones:
    subprograma_declaraciones subprograma_declaracion ';'
    {
        tree_add_child($1, $2);
        $$ = $1;
    }
    | %empty
    {
        struct tree_node* sub_dec_lista = malloc(sizeof(struct tree_node));
        sub_dec_lista->tipo = SUBPROGRAMA_DECLARACIONES;
        $$ = sub_dec_lista;
    }
    ;
subprograma_declaracion:
    subprograma_encabezado declaraciones subprograma_declaraciones instruccion_compuesta
    {
        struct tree_node* sub_declaracion = malloc(sizeof(struct tree_node));
        sub_declaracion->tipo = SUBPROGRAMA_DECLARACION;
        tree_add_child(sub_declaracion, $1);
        tree_add_child(sub_declaracion, $2);
        tree_add_child(sub_declaracion, $3);
        tree_add_child(sub_declaracion, $4);
        $$ = sub_declaracion;
    }
    ;
subprograma_encabezado:
    FUNCTION TOK_IDENTIFICADOR argumentos ':' estandar_tipo ';'
    {
        struct tree_node* sub_encabezado = malloc(sizeof(struct tree_node));
        sub_encabezado->identificador = strdup($TOK_IDENTIFICADOR);
        sub_encabezado->tipo = SUBPROGRAMA_ENCABEZADO;

        struct tree_node* est_tipo = malloc(sizeof(struct tree_node));
        est_tipo->tipo = ESTANDAR_TIPO;
        est_tipo->data_tipo = $5;
        
        tree_add_child(sub_declaracion, $3);
        tree_add_child(sub_declaracion, est_tipo);
        $$ = sub_encabezado;
    }
    | PROCEDURE TOK_IDENTIFICADOR argumentos ';'
    {
        struct tree_node* sub_encabezado = malloc(sizeof(struct tree_node));
        sub_encabezado->identificador = strdup($TOK_IDENTIFICADOR);
        sub_encabezado->tipo = SUBPROGRAMA_ENCABEZADO;
        tree_add_child(sub_declaracion, $3);        
        $$ = sub_encabezado;
    }
    ;
argumentos:
    '(' parametros_lista ')'
    {
        $$ = $2;
    }
    | %empty
    {
        struct tree_node* empty_node = malloc(sizeof(struct tree_node));
        empty_node->tipo = EMPTY;
        $$ = empty_node;
    }
    ;
parametros_lista:
    identificador_lista ':' tipo 
    {
        struct tree_node* param_lista = malloc(sizeof(struct tree_node));
        id_lista->tipo = PARAMETROS_LISTA;
        struct tree_node* param_nodo = malloc(sizeof(struct tree_node));
        id_lista->tipo = PARAMETRO;        
        tree_add_child(param_nodo, $1);
        tree_add_child(param_nodo, $3);
        tree_add_child(param_lista, param_nodo);
        $$ = param_lista;
    }
    | parametros_lista ';' identificador_lista ':' tipo
    {
        struct tree_node* param_nodo = malloc(sizeof(struct tree_node));
        id_lista->tipo = PARAMETRO;        
        tree_add_child(param_nodo, $3);
        tree_add_child(param_nodo, $5);
        tree_add_child($1, param_nodo);
        $$ = $1;
    }
    ;
instruccion_compuesta:
    PBEGIN instrucciones_opcionales END
    {
        struct tree_node* inst_compuesta = malloc(sizeof(struct tree_node));
        inst_compuesta->tipo = INSTRUCCION_COMPUESTA;
        tree_add_child(param_nodo, $2);
        $$ = inst_compuesta;
    }
    ;
instrucciones_opcionales:
    instrucciones_lista
    {
        $$ = $1;
    }
    | %empty
    {
        struct tree_node* empty_node = malloc(sizeof(struct tree_node));
        empty_node->tipo = EMPTY;
        $$ = empty_node;
    }
    ;
instrucciones_lista:
    instrucciones
    {
        struct tree_node* inst_lista = malloc(sizeof(struct tree_node));
        id_lista->tipo = INSTRUCCIONES_LISTA;
        tree_add_child(inst_lista, $1);
        $$ = inst_lista;
    }
    | instrucciones_lista ';' instrucciones
    {     
        tree_add_child($1, $3);
        $$ = $1;
    }
    ;
instrucciones:
    /*De manera predeterminada se devuelve el primer valor. $$ = $1*/
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
    {
        struct tree_node* rep_while = malloc(sizeof(struct tree_node));
        id_lista->tipo = REPETICION_WHILE;
        tree_add_child(rep_while, $2);
        tree_add_child(rep_while, $4);
        $$ = rep_while;
    }
    | FOR for_asignacion TO expresion DO instrucciones
    {
        struct tree_node* rep_for = malloc(sizeof(struct tree_node));
        id_lista->tipo = REPETICION_FOR;
        id_lista->for_tipo = TO;
        tree_add_child(rep_for, $2);
        tree_add_child(rep_for, $4);
        tree_add_child(rep_for, $6);
        $$ = rep_for;
    }
    | FOR for_asignacion DOWNTO expresion DO instrucciones
    {
        struct tree_node* rep_for = malloc(sizeof(struct tree_node));
        id_lista->tipo = REPETICION_FOR;
        id_lista->for_tipo = DOWNTO;
        tree_add_child(rep_for, $2);
        tree_add_child(rep_for, $4);
        tree_add_child(rep_for, $6);
        $$ = rep_for;
    }
    ;
lectura_instruccion:
    READ '(' TOK_IDENTIFICADOR ')'
    {
        struct tree_node* read = malloc(sizeof(struct tree_node));
        read->identificador = strdup($TOK_IDENTIFICADOR);
        read->tipo = LECTURA_INSTRUCCION;
        $$ = read;
    }
    | READLN '(' TOK_IDENTIFICADOR ')'
    {
        struct tree_node* read = malloc(sizeof(struct tree_node));
        read->identificador = strdup($TOK_IDENTIFICADOR);
        read->tipo = LECTURA_INSTRUCCION;
        $$ = read;
    }
    ;
escritura_instruccion:
    WRITE '(' constante_cadena ',' TOK_IDENTIFICADOR ')'
    {
        struct tree_node* write = malloc(sizeof(struct tree_node));
        write->identificador = strdup($TOK_IDENTIFICADOR);
        write->tipo = ESCRITURA_WRITE;
        write->cadena = strdup($3);
        $$ = write;
    }
    | WRITELN '(' constante_cadena ',' TOK_IDENTIFICADOR ')'
    {
        struct tree_node* writeln = malloc(sizeof(struct tree_node));
        writeln->identificador = strdup($TOK_IDENTIFICADOR);
        writeln->tipo = ESCRITURA_WRITELN;
        writeln->cadena = strdup($3);
        $$ = writeln;
    }
    | WRITE '(' constante_cadena ')'
    {
        struct tree_node* write = malloc(sizeof(struct tree_node));
        write->identificador = NULL;
        write->tipo = ESCRITURA_WRITE;
        write->cadena = strdup($3);
        $$ = write;
    }
    | WRITELN '(' constante_cadena ')'
    {
        struct tree_node* writeln = malloc(sizeof(struct tree_node));
        write->identificador = NULL;
        writeln->tipo = ESCRITURA_WRITELN;
        writeln->cadena = strdup($3);
        $$ = writeln;
    }
    | WRITE '(' constante_cadena ',' expresion ')'
    {
        struct tree_node* write = malloc(sizeof(struct tree_node));
        write->identificador = NULL;
        write->tipo = ESCRITURA_WRITE;
        write->cadena = strdup($3);
        tree_add_child(write, $5);
        $$ = write;
    }
    | WRITELN '(' constante_cadena ',' expresion ')'
    {
        struct tree_node* writeln = malloc(sizeof(struct tree_node));
        write->identificador = NULL;
        writeln->tipo = ESCRITURA_WRITELN;
        writeln->cadena = strdup($3);
        tree_add_child(writeln, $5);
        $$ = writeln;
    }
constante_cadena:
    CADENA
    ;
if_instruccion:
    IF relop_expresion THEN instrucciones
    {
        struct tree_node* if_nodo = malloc(sizeof(struct tree_node));
        if_nodo->tipo = IF_INSTRUCCION;
        tree_add_child(if_nodo, $2);
        tree_add_child(if_nodo, $4);
        $$ = if_nodo;
    }
    | IF relop_expresion THEN instrucciones ELSE instrucciones
    {
        struct tree_node* if_else = malloc(sizeof(struct tree_node));
        if_else->tipo = IF_INSTRUCCION;
        tree_add_child(if_nodo, $2);
        tree_add_child(if_nodo, $4);
        tree_add_child(if_nodo, $6);
        $$ = if_else;
    }
    ;
variable_asignacion:
    variable ASSIGNMENT expresion
    {
        struct tree_node* var = malloc(sizeof(struct tree_node));
        var->tipo = VARIABLE_ASIGNACION;
        tree_add_child(if_nodo, $1);
        tree_add_child(if_nodo, $3);
        $$ = var;
    }
    ;
for_asignacion:
    variable_asignacion
    | variable
    ;
variable:
    TOK_IDENTIFICADOR
    | TOK_IDENTIFICADOR '[' expresion ']'
    ;
procedure_instruccion:
    TOK_IDENTIFICADOR
    | TOK_IDENTIFICADOR '(' expresion_lista ')'
    ;
relop_expresion:
    relop_expresion TOK_OR relop_and
    | relop_and
    ;
relop_and:
    relop_and TOK_AND relop_not
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
    TOK_IDENTIFICADOR '(' expresion_lista ')'
    ;
factor:
    TOK_IDENTIFICADOR
    | TOK_IDENTIFICADOR '[' expresion ']'
    | llamado_funcion
    | constante_entera
    | constante_real
    | signo factor
    | '(' expresion ')'
    ;
signo:
    '+'
    | '-'
    | %empty
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
    | %empty
    ;
%%

int yyerror(char const *    )
{
    printf("Error: %s\n", s);
    exit(1);
    return 0;
}