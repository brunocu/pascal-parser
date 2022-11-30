%code top {
    #include <stdlib.h>
    #include <stdio.h>
}

%code requires {
    #include "tree.h"
    #include "hash_map.h"
}

%code {
    extern int yylex(void);
    int yyerror(char const *s);
}

%define api.value.type union
%token
<int>
    ARRAY
    ASSIGNMENT
    CONST
    DO
    ELSE
    END
    FOR
    FUNCTION
    IF
    NOT
    OF
    PBEGIN
    PROCEDURE
    PROGRAM
    READ
    READLN
    THEN
    TOK_AND
    TOK_BOOLEAN
    TOK_DOWNTO
    TOK_INTEGER
    TOK_OR
    TOK_REAL
    TOK_STRING
    TOK_TO
    TWO_DOTS
    VAR
    WHILE
    WRITE
    WRITELN
<char*>
    CADENA
    TOK_IDENTIFICADOR
<long>
    ENTERO
<double>
    REAL
%token <int>
    '+'
    '-'
    '*'
    '/'
%type
<struct tree_node*>
    programa
    argumentos
    constante_cadena
    constante_entera
    constante_real
    declaraciones
    declaraciones_constantes
    declaraciones_variables
    escritura_instruccion
    identificador_lista
    if_instruccion
    instruccion_compuesta
    instrucciones
    instrucciones_lista
    instrucciones_opcionales
    lectura_instruccion
    parametros_lista
    repeticion_instruccion
    subprograma_declaracion
    subprograma_declaraciones
    subprograma_encabezado
    tipo
    variable_asignacion
    for_asignacion
    variable
    procedure_instruccion
    relop_expresion
    relop_and
    relop_not
    relop_paren
    relop_expresion_simple
    expresion_lista
    expresion
    termino
    factor
    llamado_funcion
<int>
    estandar_tipo
    relop
    addop
    mulop
    signo

%code {
    struct tree_node* root;
    list_ptr symbol_table[TABLE_SIZE];

    long max_scope = 0;
    long last_scope = 0;
    long curr_scope = 0;

    #define INC_SCOPE() do {        \
        last_scope = curr_scope;    \
        curr_scope = ++max_scope;   \
    } while(0)
    #define DEC_SCOPE() do {        \
        curr_scope = last_scope;    \
    } while(0)

    /**
     * Try to insert IDENTIFICADOR into symbol table in current scope.
     * Calls yyerror if duplicated symbol.
     * 
     * Uses global variables `symbol_table`, `curr_scope`
    */
    void try_table_insert(char*);
    void try_table_find(char*);
}

%%
programa:
    PROGRAM TOK_IDENTIFICADOR
    {
        /* midrule */
        try_table_insert($TOK_IDENTIFICADOR);
    }
    '(' identificador_lista ')' ';' declaraciones subprograma_declaraciones instruccion_compuesta '.'
    {
        root = tree_make_node();
        root->tipo = PROGRAMA;
        root->identificador = $TOK_IDENTIFICADOR;   /* scope 0 */
        tree_add_child(root, $identificador_lista);
        tree_add_child(root, $declaraciones);
        tree_add_child(root, $subprograma_declaraciones);
        tree_add_child(root, $instruccion_compuesta);
        $$ = root;
    };
identificador_lista:
    TOK_IDENTIFICADOR
    {
        try_table_insert($TOK_IDENTIFICADOR);

        struct tree_node* id_lista = tree_make_node();
        id_lista->tipo = IDENTIFICADOR_LISTA;
        struct tree_node* identificador_nodo = tree_make_node();
        identificador_nodo->tipo = IDENTIFICADOR;
        identificador_nodo->identificador = $TOK_IDENTIFICADOR;
        tree_add_child(id_lista, identificador_nodo);
        $$ = id_lista;
    }
    | identificador_lista ',' TOK_IDENTIFICADOR
    {
        try_table_insert($TOK_IDENTIFICADOR);

        struct tree_node* identificador_nodo = tree_make_node();
        identificador_nodo->tipo = IDENTIFICADOR;
        identificador_nodo->identificador = $TOK_IDENTIFICADOR;
        tree_add_child($1, identificador_nodo);
        $$ = $1;
    }
    ;
/* default rules $$ = $1 */
declaraciones:
    declaraciones_variables
    | declaraciones_constantes
    ;
declaraciones_variables:
    declaraciones_variables VAR identificador_lista ':' tipo ';'
    {
        struct tree_node* dec_variables = tree_make_node();
        dec_variables->tipo = DECLARACIONES_VARIABLES;
        tree_add_child(dec_variables, $1);
        tree_add_child(dec_variables, $3);
        tree_add_child(dec_variables, $5);
        $$ = dec_variables;

    }
    | %empty
    {
        struct tree_node* empty_node = tree_make_node();
        empty_node->tipo = EMPTY;
        $$ = empty_node;
    }
    ;
tipo:
    estandar_tipo
    {
        struct tree_node* est_tipo = tree_make_node();
        est_tipo->tipo = ESTANDAR_TIPO;
        est_tipo->tok_val = $1;
        $$ = est_tipo;
    }
    | ARRAY '[' ENTERO TWO_DOTS ENTERO ']' OF estandar_tipo
    {
        struct tree_node* arr_tipo = tree_make_node();
        struct tree_node* est_tipo = tree_make_node();
        arr_tipo->tipo = ARREGLO_TIPO;
        arr_tipo->entero = ($5 - $3);
        est_tipo->tipo = ESTANDAR_TIPO;
        est_tipo->tok_val = $estandar_tipo;
        tree_add_child(arr_tipo, est_tipo);
        $$ = arr_tipo;
    }
    ;
/* return token values */
estandar_tipo:
    TOK_INTEGER
    | TOK_REAL
    | TOK_STRING
    | TOK_BOOLEAN
    ;
relop:
    TOK_AND
    | TOK_OR
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
        try_table_insert($TOK_IDENTIFICADOR);

        struct tree_node* dec_const = tree_make_node();
        dec_const->tipo = DECLARACIONES_CONSTANTES;
        dec_const->identificador = $TOK_IDENTIFICADOR;
        tree_add_child(dec_const, $1);
        tree_add_child(dec_const, $5);
        $$ = dec_const;
    }
    | declaraciones_constantes CONST TOK_IDENTIFICADOR '=' constante_real ';'
    {
        try_table_insert($TOK_IDENTIFICADOR);

        struct tree_node* dec_const = tree_make_node();
        dec_const->tipo = DECLARACIONES_CONSTANTES;
        dec_const->identificador = $TOK_IDENTIFICADOR;
        tree_add_child(dec_const, $1);
        tree_add_child(dec_const, $5);
        $$ = dec_const;
    }
    | declaraciones_constantes CONST TOK_IDENTIFICADOR '=' constante_cadena ';'
    {
        try_table_insert($TOK_IDENTIFICADOR);

        struct tree_node* dec_const = tree_make_node();
        dec_const->tipo = DECLARACIONES_CONSTANTES;
        dec_const->identificador = $TOK_IDENTIFICADOR;
        tree_add_child(dec_const, $1);
        tree_add_child(dec_const, $5);        
        $$ = dec_const;
    }
    | %empty
    {
        struct tree_node* empty_node = tree_make_node();
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
        struct tree_node* sub_dec_lista = tree_make_node();
        sub_dec_lista->tipo = SUBPROGRAMA_DECLARACIONES;
        $$ = sub_dec_lista;
    }
    ;
subprograma_declaracion:
    subprograma_encabezado declaraciones subprograma_declaraciones instruccion_compuesta
    {
        struct tree_node* sub_declaracion = tree_make_node();
        sub_declaracion->tipo = SUBPROGRAMA_DECLARACION;
        tree_add_child(sub_declaracion, $1);
        tree_add_child(sub_declaracion, $2);
        tree_add_child(sub_declaracion, $3);
        tree_add_child(sub_declaracion, $4);
        $$ = sub_declaracion;

        DEC_SCOPE();
    }
    ;
subprograma_encabezado:
    FUNCTION TOK_IDENTIFICADOR
    {
        /* midrule */
        INC_SCOPE();
        try_table_insert($TOK_IDENTIFICADOR);
    }
    argumentos ':' estandar_tipo ';'
    {
        struct tree_node* sub_encabezado = tree_make_node();
        sub_encabezado->identificador = $TOK_IDENTIFICADOR;
        sub_encabezado->tipo = SUBPROGRAMA_ENCABEZADO;

        struct tree_node* est_tipo = tree_make_node();
        est_tipo->tipo = ESTANDAR_TIPO;
        est_tipo->tok_val = $estandar_tipo;
        
        tree_add_child(sub_encabezado, $argumentos);
        tree_add_child(sub_encabezado, est_tipo);
        $$ = sub_encabezado;
    }
    | PROCEDURE TOK_IDENTIFICADOR
    {
        /* midrule */
        INC_SCOPE();
        try_table_insert($TOK_IDENTIFICADOR);
    }
    argumentos ';'
    {
        struct tree_node* sub_encabezado = tree_make_node();
        sub_encabezado->identificador = $TOK_IDENTIFICADOR;
        sub_encabezado->tipo = SUBPROGRAMA_ENCABEZADO;
        tree_add_child(sub_encabezado, $argumentos);        
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
        struct tree_node* empty_node = tree_make_node();
        empty_node->tipo = EMPTY;
        $$ = empty_node;
    }
    ;
parametros_lista:
    identificador_lista ':' tipo 
    {
        struct tree_node* param_lista = tree_make_node();
        param_lista->tipo = PARAMETROS_LISTA;
        struct tree_node* param_nodo = tree_make_node();
        param_nodo->tipo = PARAMETRO;        
        tree_add_child(param_nodo, $1);
        tree_add_child(param_nodo, $3);
        tree_add_child(param_lista, param_nodo);
        $$ = param_lista;
    }
    | parametros_lista ';' identificador_lista ':' tipo
    {
        struct tree_node* param_nodo = tree_make_node();
        param_nodo->tipo = PARAMETRO;
        tree_add_child(param_nodo, $3);
        tree_add_child(param_nodo, $5);
        tree_add_child($1, param_nodo);
        $$ = $1;
    }
    ;
instruccion_compuesta:
    PBEGIN instrucciones_opcionales END
    {
        struct tree_node* inst_compuesta = tree_make_node();
        inst_compuesta->tipo = INSTRUCCION_COMPUESTA;
        tree_add_child(inst_compuesta, $2);
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
        struct tree_node* empty_node = tree_make_node();
        empty_node->tipo = EMPTY;
        $$ = empty_node;
    }
    ;
instrucciones_lista:
    instrucciones
    {
        struct tree_node* inst_lista = tree_make_node();
        inst_lista->tipo = INSTRUCCIONES_LISTA;
        tree_add_child(inst_lista, $1);
        $$ = inst_lista;
    }
    | instrucciones_lista ';' instrucciones
    {     
        tree_add_child($1, $3);
        $$ = $1;
    }
    ;
/*De manera predeterminada se devuelve el primer valor. $$ = $1*/
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
    {
        struct tree_node* rep_while = tree_make_node();
        rep_while->tipo = REPETICION_WHILE;
        tree_add_child(rep_while, $2);
        tree_add_child(rep_while, $4);
        $$ = rep_while;
    }
    | FOR for_asignacion TOK_TO expresion DO instrucciones
    {
        struct tree_node* rep_for = tree_make_node();
        rep_for->tipo = REPETICION_FOR;
        rep_for->tok_val = $TOK_TO;
        tree_add_child(rep_for, $2);
        tree_add_child(rep_for, $4);
        tree_add_child(rep_for, $6);
        $$ = rep_for;
    }
    | FOR for_asignacion TOK_DOWNTO expresion DO instrucciones
    {
        struct tree_node* rep_for = tree_make_node();
        rep_for->tipo = REPETICION_FOR;
        rep_for->tok_val = $TOK_DOWNTO;
        tree_add_child(rep_for, $2);
        tree_add_child(rep_for, $4);
        tree_add_child(rep_for, $6);
        $$ = rep_for;
    }
    ;
lectura_instruccion:
    READ '(' TOK_IDENTIFICADOR ')'
    {
        try_table_find($TOK_IDENTIFICADOR);

        struct tree_node* read = tree_make_node();
        read->identificador = $TOK_IDENTIFICADOR;
        read->tipo = LECTURA_INSTRUCCION;
        $$ = read;
    }
    | READLN '(' TOK_IDENTIFICADOR ')'
    {
        try_table_find($TOK_IDENTIFICADOR);

        struct tree_node* read = tree_make_node();
        read->identificador = $TOK_IDENTIFICADOR;
        read->tipo = LECTURA_INSTRUCCION;
        $$ = read;
    }
    ;
escritura_instruccion:
    WRITE '(' constante_cadena ',' TOK_IDENTIFICADOR ')'
    {
        try_table_find($TOK_IDENTIFICADOR);

        struct tree_node* write = tree_make_node();
        write->identificador = $TOK_IDENTIFICADOR;
        write->tipo = ESCRITURA_WRITE;
        tree_add_child(write, $3);
        $$ = write;
    }
    | WRITELN '(' constante_cadena ',' TOK_IDENTIFICADOR ')'
    {
        try_table_find($TOK_IDENTIFICADOR);

        struct tree_node* writeln = tree_make_node();
        writeln->identificador = $TOK_IDENTIFICADOR;
        writeln->tipo = ESCRITURA_WRITELN;
        tree_add_child(writeln, $3);
        $$ = writeln;
    }
    | WRITE '(' constante_cadena ')'
    {
        struct tree_node* write = tree_make_node();
        write->tipo = ESCRITURA_WRITE;
        tree_add_child(write, $3);
        $$ = write;
    }
    | WRITELN '(' constante_cadena ')'
    {
        struct tree_node* writeln = tree_make_node();
        writeln->tipo = ESCRITURA_WRITELN;
        tree_add_child(writeln, $3);
        $$ = writeln;
    }
    | WRITE '(' constante_cadena ',' expresion ')'
    {
        struct tree_node* write = tree_make_node();
        write->tipo = ESCRITURA_WRITE;
        tree_add_child(write, $3);
        tree_add_child(write, $5);
        $$ = write;
    }
    | WRITELN '(' constante_cadena ',' expresion ')'
    {
        struct tree_node* writeln = tree_make_node();
        writeln->tipo = ESCRITURA_WRITELN;
        tree_add_child(writeln, $3);
        tree_add_child(writeln, $5);
        $$ = writeln;
    }
constante_cadena:
    CADENA
    {
        struct tree_node* real_const = tree_make_node();
        real_const->tipo = CONSTANTE_CADENA;
        real_const->cadena = $1;
        $$ = real_const;
    }
    ;
if_instruccion:
    IF relop_expresion THEN instrucciones
    {
        struct tree_node* if_nodo = tree_make_node();
        if_nodo->tipo = IF_INSTRUCCION;
        tree_add_child(if_nodo, $2);
        tree_add_child(if_nodo, $4);
        $$ = if_nodo;
    }
    | IF relop_expresion THEN instrucciones ELSE instrucciones
    {
        struct tree_node* if_else = tree_make_node();
        if_else->tipo = IF_INSTRUCCION;
        tree_add_child(if_else, $2);
        tree_add_child(if_else, $4);
        tree_add_child(if_else, $6);
        $$ = if_else;
    }
    ;
variable_asignacion:
    variable ASSIGNMENT expresion
    {
        struct tree_node* var_assgn = tree_make_node();
        var_assgn->tipo = VARIABLE_ASIGNACION;
        tree_add_child(var_assgn, $1);
        tree_add_child(var_assgn, $3);
        $$ = var_assgn;
    }
    ;
/* default action $$ = $1 */
for_asignacion:
    variable_asignacion
    | variable
    ;
variable:
    TOK_IDENTIFICADOR
    {
        try_table_find($TOK_IDENTIFICADOR);

        struct tree_node* var = tree_make_node();
        var->tipo = VARIABLE;
        var->identificador = $TOK_IDENTIFICADOR;
        $$ = var;
    }
    | TOK_IDENTIFICADOR '[' expresion ']'
    {
        try_table_find($TOK_IDENTIFICADOR);

        struct tree_node* var = tree_make_node();
        var->tipo = VARIABLE;
        var->identificador = $TOK_IDENTIFICADOR;
        tree_add_child(var, $3);
        $$ = var;
    }
    ;
procedure_instruccion:
    TOK_IDENTIFICADOR
    {
        try_table_find($TOK_IDENTIFICADOR);
        
        struct tree_node* proc = tree_make_node();
        proc->tipo = PROCEDURE_INSTRUCCION;
        proc->identificador = $TOK_IDENTIFICADOR;
        $$ = proc;
    }
    | TOK_IDENTIFICADOR '(' expresion_lista ')'
    {
        try_table_find($TOK_IDENTIFICADOR);

        struct tree_node* proc = tree_make_node();
        proc->tipo = PROCEDURE_INSTRUCCION;
        proc->identificador = $TOK_IDENTIFICADOR;
        tree_add_child(proc, $3);
        $$ = proc;
    }
    ;
relop_expresion:
    relop_expresion TOK_OR relop_and
    {
        struct tree_node* relop = tree_make_node();
        relop->tipo = RELOP_EXPRESION;
        tree_add_child(relop, $1);
        tree_add_child(relop, $relop_and);
        $$ = relop;
    }
    | relop_and
    {
        struct tree_node* relop = tree_make_node();
        relop->tipo = RELOP_EXPRESION;
        tree_add_child(relop, $relop_and);
        $$ = relop;
    }
    ;
relop_and:
    relop_and TOK_AND relop_not
    {
        struct tree_node* relop = tree_make_node();
        relop->tipo = RELOP_AND;
        tree_add_child(relop, $1);
        tree_add_child(relop, $relop_not);
        $$ = relop;
    }
    | relop_not
    {
        struct tree_node* relop = tree_make_node();
        relop->tipo = RELOP_AND;
        tree_add_child(relop, $relop_not);
        $$ = relop;
    }
    ;
relop_not:
    NOT relop_not
    {
        struct tree_node* relop = tree_make_node();
        relop->tipo = RELOP_NOT;
        tree_add_child(relop, $2);
        $$ = relop;
    }
    | relop_paren /* default rule */
    ;
relop_paren:
    '(' relop_expresion ')'
    {
        struct tree_node* relop = tree_make_node();
        relop->tipo = RELOP_PAREN;
        tree_add_child(relop, $relop_expresion);
        $$ = relop;
    }
    | relop_expresion_simple /* default rule */
    ;
relop_expresion_simple:
    expresion relop expresion
    {
        struct tree_node* relop = tree_make_node();
        relop->tipo = RELOP_EXPRESION_SIMPLE;
        relop->tok_val = $2;
        tree_add_child(relop, $1);
        tree_add_child(relop, $3);
        $$ = relop;
    }
    ;
expresion_lista:
    expresion
    {
        struct tree_node* expr_lista = tree_make_node();
        expr_lista->tipo = EXPRESION_LISTA;
        tree_add_child(expr_lista, $1);
        $$ = expr_lista;
    }
    | expresion_lista ',' expresion
    {
        tree_add_child($1, $3);
        $$ = $1;
    }
    ;
expresion:
    termino /* default rule */
    | expresion addop termino
    {
        struct tree_node* expr = tree_make_node();
        expr->tipo = EXPRESION;
        expr->tok_val = $2;
        tree_add_child(expr, $3);
        $$ = expr;
    }
    ;
termino:
    factor /* default rule */
    | termino mulop factor
    {
        struct tree_node* termino = tree_make_node();
        termino->tipo = TERMINO;
        termino->tok_val = $2;
        tree_add_child(termino, $3);
        $$ = termino;
    }
    ;
llamado_funcion:
    TOK_IDENTIFICADOR '(' expresion_lista ')'
    {
        struct tree_node* func = tree_make_node();
        func->tipo = LLAMADO_FUNCION;
        func->identificador = $TOK_IDENTIFICADOR;
        tree_add_child(func, $3);
        $$ = func;
    }
    ;
factor:
    TOK_IDENTIFICADOR
    {
        try_table_find($TOK_IDENTIFICADOR);

        struct tree_node* factor = tree_make_node();
        factor->tipo = FACTOR;
        struct tree_node* identificador_nodo = tree_make_node();
        identificador_nodo->tipo = IDENTIFICADOR;
        identificador_nodo->identificador = $TOK_IDENTIFICADOR;
        tree_add_child(factor, identificador_nodo);
        $$ = factor;
    }
    | TOK_IDENTIFICADOR '[' expresion ']'
    {
        try_table_find($TOK_IDENTIFICADOR);

        struct tree_node* factor = tree_make_node();
        factor->tipo = FACTOR;
        struct tree_node* identificador_nodo = tree_make_node();
        identificador_nodo->tipo = IDENTIFICADOR;
        identificador_nodo->identificador = $TOK_IDENTIFICADOR;
        tree_add_child(factor, identificador_nodo);
        tree_add_child(factor, $3);
        $$ = factor;
    }
    | llamado_funcion   /* default rule */
    | constante_entera
    | constante_real
    | signo factor
    {
        struct tree_node* factor = tree_make_node();
        factor->tipo = FACTOR;
        factor->tok_val = $1;
        tree_add_child(factor, $2);
        $$ = factor;
    }
    | '(' expresion ')'
    {
        struct tree_node* factor = tree_make_node();
        factor->tipo = FACTOR;
        tree_add_child(factor, $2);
        $$ = factor;
    }
    ;
signo:
    '+'
    | '-'
    | %empty { $$ = 0; }
    ;
constante_entera:
    signo ENTERO
    {
        struct tree_node* int_const = tree_make_node();
        int_const->tipo = CONSTANTE_ENTERA;
        if ($1 == '-')
            int_const->tok_val = - $2;
        else
            int_const->tok_val = $2;
        $$ = int_const;
    }
    ;
constante_real:
    REAL
    {
        struct tree_node* real_const = tree_make_node();
        real_const->tipo = CONSTANTE_REAL;
        real_const->real = $1;
        $$ = real_const;
    }
    ;
%%

void try_table_insert(char *key)
{
    struct element item = new_elem(key, curr_scope);

    /* try to insert IDENTIFICADOR into symbol table in current scope */
    if (!map_insert(symbol_table, item)) {
        char *msg;
        asprintf(&msg, "Duplicated symbol:\"%s\"", key);
        yyerror(msg);
    }
}

void try_table_find(char* key)
{
    struct element item = new_elem(key, curr_scope);

    /* try to find key in current scope */
    if (!map_find(symbol_table, item)) {
        /* try to find in global scope */
        if (curr_scope != 0) {
            item.scope = curr_scope;
            if(map_find(symbol_table, item))
                return;
        }
        char *msg;
        asprintf(&msg, "Unknown symbol:\"%s\"", key);
        yyerror(msg);
    }
}

int yyerror(char const *s)
{
    printf("Error: %s\n", s);
    exit(1);
    return 0;
}