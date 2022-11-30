#include "tree.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
// #include <stdbool.h>

struct tree_node *tree_make_node()
{
    struct tree_node *new_node = (struct tree_node *)malloc(sizeof(struct tree_node));
    new_node->identificador = NULL;
    new_node->parent = NULL;
    new_node->left_child = NULL;
    new_node->right_sibling = NULL;
    new_node->tok_val = 0;
    return new_node;
}

void tree_add_child(struct tree_node *parent, struct tree_node *child)
{
    child->parent = parent;
    if (!(parent->left_child))
        parent->left_child = child;
    else
    {
        struct tree_node *sibling = parent->left_child;
        while (sibling->right_sibling)
            sibling = sibling->right_sibling;
        sibling->right_sibling = child;
    }
}

void print_tree(struct tree_node* root){    
    struct tree_node* temp;
    if (!root){
        // printf("Padre: %s, Nodo: %s \n", get_text_from_enum(root->parent->tipo), get_text_from_enum(root->tipo));
        printf("");
    }
    else{
        temp = root;
        if(!temp->parent){
            printf("Padre: NULL, Nodo: %s \n", get_text_from_enum(root->tipo));
        }
        while(temp){
            if(temp->parent){
                printf("Padre: %s, Nodo: %s \n", get_text_from_enum(temp->parent->tipo), get_text_from_enum(temp->tipo));
                print_tree(temp->left_child);
            }
            temp = temp->right_sibling;
        }
        print_tree(root->left_child);
    }
 
    // struct tree_node* temp;
    // struct tree_node* siblings;
    // struct tree_node* sons;
    // struct tree_node* sons_sons;
    // bool downing = true;
    // if(!root){
    //     printf("");
    // }
    // else
    // {
    //     printf(get_text_from_enum(root->tipo));
    //     printf("\n");
    //     temp = root;
    //     while (temp)
    //     {
    //         if (downing)
    //         {
    //             if (temp->parent)
    //             {
    //                 depth++;
    //                 for (size_t i = 0; i < depth; i++)
    //                 {
    //                     printf("\t");
    //                 }
    //                 printf(get_text_from_enum(temp->tipo));
    //                 printf("\n");
    //                 if (!temp->left_child)
    //                 {
    //                     siblings = temp;
    //                     downing = false;
    //                     while (siblings)
    //                     {
    //                         if (siblings->right_sibling)
    //                         {
    //                             for (size_t i = 0; i < depth; i++)
    //                             {
    //                                 printf("\t");
    //                             }
    //                             printf(get_text_from_enum(siblings->right_sibling->tipo));
    //                             printf("\n");
    //                         }
    //                         siblings = siblings->right_sibling;
    //                     }
    //                     temp = temp->parent;
    //                     continue;
    //                 }
    //             }
    //             temp = temp->left_child;
    //         }else{
    //             siblings = temp;
    //             depth--;
    //             while (siblings)
    //             {
    //                 for (size_t i = 0; i < depth; i++)
    //                 {
    //                     printf("\t");
    //                 }
    //                 printf(get_text_from_enum(siblings->right_sibling->tipo));
    //                 printf("\n");
    //                 if (siblings->right_sibling->left_child)
    //                 {
    //                     sons = siblings->right_sibling->left_child;
    //                     depth++;
    //                     while (sons)
    //                     {
    //                         for (size_t i = 0; i < depth; i++)
    //                         {
    //                             printf("\t");
    //                         }
    //                         printf(get_text_from_enum(sons->tipo));
    //                         printf("\n");
    //                         if (sons->left_child)
    //                         {
    //                             printf("entra");
    //                             // sons_sons = sons->left_child;
    //                             // while (sons_sons)
    //                             // {
    //                             //     depth++;
    //                             //     for (size_t i = 0; i < depth; i++)
    //                             //     {
    //                             //         printf("\t");
    //                             //     }
    //                             //     printf(get_text_from_enum(sons_sons->tipo));
    //                             //     sons_sons = sons_sons->left_child;
    //                             // }
    //                         }
    //                         sons = sons->right_sibling;
    //                     }
    //                 }
    //                 siblings = siblings->right_sibling;
    //             }
    //             temp = temp->parent;
    //         }
    //     }

    //}
    // printf("%s", get_text_from_enum(root->tipo));
    // char *pointerRight = "└──";
    // char *pointerLeft = root->left_child ? "├──" : "└──";

    //showNodes("",pointerLeft, root->left_child, root->left_child->right_sibling != NULL);
    // showNodes("",pointerRight, root->left_child->right_sibling, false);
}

void showNodes (const char* padding, char* pointer, struct tree_node* node, bool rightSibling){
    if(node != NULL){
        printf("\n");
        printf(padding);
        printf(pointer);
        printf(get_text_from_enum(node->tipo));

        char* new_str = malloc(3);
        if(rightSibling){
            // printf("│  ");
            strcat(new_str,"│  ");
        }else{
            // printf("   ");
            strcat(new_str,"   ");
        }

        char *pointerRight = "└──";
        char *pointerLeft = node->left_child ? "├──" : "└──";

        showNodes(new_str,pointerLeft, node->left_child, node->left_child->right_sibling != NULL);
        // showNodes(new_str,pointerRight, node->left_child->right_sibling, false);
    }
   
}

char* get_text_from_enum(int idx){
    switch (idx)
    {
    case 0:
        return "EMPTY";
        break;
    case 1:
        return "PROGRAMA";
        break;
    case 2:
        return "IDENTIFICADOR";
        break;
    case 3:
        return "IDENTIFICADOR_LISTA";
        break;
    case 4:
        return "SUBPROGRAMA_DECLARACIONES";
        break;
    case 5:
        return "INSTRUCCION_COMPUESTA";
        break;
    case 6:
        return "DECLARACIONES_VARIABLES";
        break;
    case 7:
        return "DECLARACIONES_CONSTANTES";
        break;
    case 8:
        return "ESTANDAR_TIPO";
        break;
    case 9:
        return "ARREGLO_TIPO";
        break;
    case 10:
        return "CONSTANTE_ENTERA";
        break;
    case 11:
        return "CONSTANTE_REAL";
        break;
    case 12:
        return "CONSTANTE_CADENA";
        break;
    case 13:
        return "SUBPROGRAMA_DECLARACION";
        break;
    case 14:
        return "SUBPROGRAMA_ENCABEZADO";
        break;
    case 15:
        return "PARAMETROS_LISTA";
        break;
    case 16:
        return "PARAMETRO";
        break;
    case 17:
        return "INSTRUCCIONES_LISTA";
        break;
    case 18:
        return "VARIABLE_ASIGNACION";
        break;
    case 19:
        return "PROCEDURE_INSTRUCCION";
        break;
    case 20:
        return "IF_INSTRUCCION";
        break;
    case 21:
        return "REPETICION_WHILE";
        break;
    case 22:
        return "REPETICION_FOR";
        break;
    case 23:
        return "LECTURA_INSTRUCCION";
        break;
    case 24:
        return "ESCRITURA_WRITE";
        break;
    case 25:
        return "ESCRITURA_WRITELN";
        break;
    case 26:
        return "VARIABLE";
        break;
    case 27:
        return "EXPRESION";
        break;
    case 28:
        return "TERMINO";
        break;
    case 29:
        return "FACTOR";
        break;
    case 30:
        return "LLAMADO_FUNCION";
        break;
    case 31:
        return "EXPRESION_LISTA";
        break;
    case 32:
        return "RELOP_EXPRESION";
        break;
    case 33:
        return "RELOP_AND";
        break;
    case 34:
        return "RELOP_NOT";
        break;
    case 35:
        return "RELOP_PAREN";
        break;
    case 36:
        return "RELOP_EXPRESION_SIMPLE";
        break;
    default:
        return "UNDEFINED";
        break;
    }
}