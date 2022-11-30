#ifndef TREE_H
#define TREE_H
#include <stdbool.h>

enum tipo_nodo{
    EMPTY,
    PROGRAMA,
    IDENTIFICADOR,
    //NODOS PROGRAMA    
    IDENTIFICADOR_LISTA,
    SUBPROGRAMA_DECLARACIONES,
    INSTRUCCION_COMPUESTA, //{}
    //NODOS DECLARACIONES
    DECLARACIONES_VARIABLES,
    DECLARACIONES_CONSTANTES,
    ESTANDAR_TIPO,
    ARREGLO_TIPO,
    CONSTANTE_ENTERA,
    CONSTANTE_REAL,
    CONSTANTE_CADENA,
    //NODOS SUBPROGRAMA
    SUBPROGRAMA_DECLARACION,
    SUBPROGRAMA_ENCABEZADO, //función   
    //NODOS ARGUMENTOS
    PARAMETROS_LISTA,
    PARAMETRO,
    //NODOS INSTRUCCION COMPUESTA
    INSTRUCCIONES_LISTA,
    //NODOS INSTRUCCIONES
    VARIABLE_ASIGNACION,
    PROCEDURE_INSTRUCCION,    
    IF_INSTRUCCION,
    REPETICION_WHILE,
    REPETICION_FOR,
    LECTURA_INSTRUCCION,
    ESCRITURA_WRITE,
    ESCRITURA_WRITELN,
    //NODOS VARIABLE ASIGNACIÓN
    VARIABLE,
    EXPRESION,
    TERMINO,
    FACTOR,
    //NODOS FACTOR
    LLAMADO_FUNCION,
    EXPRESION_LISTA,
    //NODOS IF INSTRUCCION
    RELOP_EXPRESION,
    RELOP_AND,
    RELOP_NOT,
    RELOP_PAREN,
    RELOP_EXPRESION_SIMPLE,
};

typedef struct tree_node *tree_ptr;
struct tree_node
{
    enum tipo_nodo tipo;
    char* identificador;
    union
    {
        int tok_val;
        char* cadena;
        int entero;
        double real;
    };

    struct tree_node * parent, * left_child, * right_sibling;
};

struct tree_node* tree_make_node();
void tree_add_child(struct tree_node* parent, struct tree_node* child);
void print_tree(struct tree_node* root);
char* get_text_from_enum(int idx);
void showNodes (const char* padding, char* pointer, struct tree_node* node, bool rightSibling);

#endif // !TREE_H