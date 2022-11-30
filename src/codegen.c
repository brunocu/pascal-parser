#include "codegen.h"
#include "parser.tab.h"
#include "lexer.lex.h"
#include <stdio.h>

void process_program(tree_ptr root)
{
    fprintf(yyout, "#include <stdio.h>\ntypedef char *string;\n\n");
    char *program_name = root->identificador;
    tree_ptr id_lista = root->left_child;
    tree_ptr declaraciones = id_lista->right_sibling;
    tree_ptr sub_decl = declaraciones->right_sibling;
    tree_ptr instruccion = sub_decl->right_sibling;

    // subprogramas
    tree_ptr subprograma = sub_decl->left_child;
    if (subprograma)
    {
        process_subprograma(subprograma);
        while (subprograma = subprograma->right_sibling)
            process_subprograma(subprograma);
    }

    // program
    fprintf(yyout, "void %s(", program_name);
    tree_ptr param = id_lista->left_child;
    if (param)
        fprintf(yyout, "FILE *%s", param->identificador);
    while (param = param->right_sibling)
    {
        fprintf(yyout, ",FILE *%s", param->identificador);
    }
    fprintf(yyout, ")\n{\n");
    process_node(declaraciones);
    process_node(instruccion);
    fprintf(yyout, "}\n");
}

void process_subprograma(tree_ptr root)
{
    tree_ptr header, decl, sub_decl, instruccion;
    header = root->left_child;
    decl = header->right_sibling;
    sub_decl = decl->right_sibling;
    instruccion = sub_decl->right_sibling;

    // subprogramas
    tree_ptr subprograma = sub_decl->left_child;
    if (subprograma)
    {
        process_subprograma(subprograma);
        while (subprograma = subprograma->right_sibling)
            process_subprograma(subprograma);
    }

    // subprogram
    tree_ptr args, tipo;
    args = header->left_child;
    tipo = args->right_sibling;
    if (tipo)
        process_node(tipo);
    else
        fprintf(yyout, "void ");
    fprintf(yyout, "%s(", header->identificador);
    process_node(args);
    fprintf(yyout, ")\n{\n");
    process_node(decl);
    process_node(instruccion);
    fprintf(yyout, "}\n\n");
}

void process_node(tree_ptr node)
{
    switch (node->tipo)
    {
    case EMPTY:
        /* continue */
        break;
    case DECLARACIONES_VARIABLES:
    {
        tree_ptr prev_decl, id_lista, tipo, iden;
        prev_decl = node->left_child;
        process_node(prev_decl);
        id_lista = prev_decl->right_sibling;
        tipo = id_lista->right_sibling;
        iden = id_lista->left_child;
        process_node(tipo);
        if (tipo->tipo == ESTANDAR_TIPO)
        {
            fprintf(yyout, "%s", iden->identificador);
            while (iden = iden->right_sibling)
            {
                fprintf(yyout, ", %s", iden->identificador);
            }
        }
        else
        {
            fprintf(yyout, "%s[%d]", iden->identificador, iden->entero);
            while (iden = iden->right_sibling)
            {
                fprintf(yyout, ", %s[%d]", iden->identificador, iden->entero);
            }
        }
        fprintf(yyout, ";\n");
        break;
    }
    case DECLARACIONES_CONSTANTES:
    {
        tree_ptr prev_decl, const_val;
        prev_decl = node->left_child;
        process_node(prev_decl);
        const_val = prev_decl->right_sibling;
        fprintf(yyout, "const ");
        switch (const_val->tipo)
        {
        case CONSTANTE_ENTERA:
        {
            fprintf(yyout, "int %s = %d;\n", node->identificador, const_val->entero);
            break;
        }
        case CONSTANTE_REAL:
        {
            fprintf(yyout, "double %s = %f;\n", node->identificador, const_val->real);
            break;
        }
        case CONSTANTE_CADENA:
        {
            fprintf(yyout, "string %s = %s;\n", node->identificador, const_val->cadena);
            break;
        }
        }
    }
    case ARREGLO_TIPO:
    {
        process_node(node->left_child);
        break;
    }
    case ESTANDAR_TIPO:
    {
        switch (node->tok_val)
        {
        case TOK_INTEGER:
        case TOK_BOOLEAN:
            fprintf(yyout, "int ");
            break;
        case TOK_REAL:
            fprintf(yyout, "double ");
            break;
        case TOK_STRING:
            fprintf(yyout, "string ");
            break;
        }
        break;
    }
    case INSTRUCCION_COMPUESTA:
    {
        fprintf(yyout, "{\n");
        process_node(node->left_child);
        fprintf(yyout, "}\n");
        break;
    }
    case INSTRUCCIONES_LISTA:
    {
        tree_ptr instruct = node->left_child;
        while (instruct)
        {
            process_node(instruct);
            fprintf(yyout, ";\n");
            instruct = instruct->right_sibling;
        }
        break;
    }
    case VARIABLE_ASIGNACION:
    {
        tree_ptr var = node->left_child;
        fprintf(yyout, "%s = ", var->identificador);
        process_node(var->right_sibling);
        break;
    }
    case PROCEDURE_INSTRUCCION:
    {
        fprintf(yyout, "%s(", node->identificador);
        if (node->left_child)
            process_node(node->left_child);
        fprintf(yyout, ")");
        break;
    }
    case IF_INSTRUCCION:
    {
        tree_ptr relop = node->left_child;
        fprintf(yyout, "if (");
        process_node(relop);

        tree_ptr then = relop->right_sibling;
        fprintf(yyout, ")\n{\n");
        process_node(then);
        fprintf(yyout, "}\n");

        tree_ptr else_n = then->right_sibling;
        if (else_n)
        {
            fprintf(yyout, "else\n{\n");
            process_node(else_n);
            fprintf(yyout, "}\n");
        }
        break;
    }
    case REPETICION_FOR:
    case REPETICION_WHILE:
        break;
    case EXPRESION:
    {
        tree_ptr expr = node->left_child;
        process_node(expr);
        fprintf(yyout, " %c ", node->tok_val);
        tree_ptr term = expr->right_sibling;
        process_node(term);
        break;
    }
    case FACTOR:
    {
        if (node->identificador)
        {
            fprintf(yyout, "%s", node->identificador);
            tree_ptr expr = node->left_child;
            if (expr)
            {
                fprintf(yyout, "[");
                process_node(expr);
                fprintf(yyout, "]");
            }
        }
        else
        {
            if (node->tok_val)
            {
                fprintf(yyout, "%c ");
                process_node(node->left_child);
            }
            else
            {
                fprintf(yyout, "(");
                process_node(node->left_child);
                fprintf(yyout, ")");
            }
        }
        break;
    }
    case LLAMADO_FUNCION:
    {
        fprintf(yyout, "%s(", node->identificador);
        process_node(node->left_child);
        fprintf(yyout, ")");
        break;
    }
    case EXPRESION_LISTA:
    {
        tree_ptr expr = node->left_child;
        if (expr)
        {
            process_node(expr);
            expr = expr->right_sibling;
            while (expr)
            {
                fprintf(yyout, ", ");
                process_node(expr);
                expr = expr->right_sibling;
            }
        }
        break;
    }
    case CONSTANTE_ENTERA:
    {
        fprintf(yyout, "%d", node->entero);
        break;
    }
    case CONSTANTE_REAL:
    {
        fprintf(yyout, "%f", node->real);
        break;
    }
    case PARAMETROS_LISTA:
    {
        tree_ptr param_group, param, tipo, id_lst;
        param_group = node->left_child;
        while (param_group)
        {
            id_lst = param_group->left_child;
            tipo = id_lst->right_sibling;
            process_node(tipo);
            param = id_lst->left_child;
            fprintf(yyout, "%s", param->identificador);
            while (param = param->right_sibling)
            {
                fprintf(yyout, ", ");
                process_node(tipo);
                fprintf(yyout, "%s", param->identificador);
            }
            param_group = param_group->right_sibling;
        }
        break;
    }
    case LECTURA_INSTRUCCION:
        break;
    case ESCRITURA_WRITE:
    case ESCRITURA_WRITELN:
    {
        tree_ptr const_str = node->left_child;
        fprintf(yyout, "printf(%s", const_str->cadena);
        if (node->identificador)
            fprintf(yyout, ", %s", node->identificador);
        else
        {
            if (const_str->right_sibling)
            {
                fprintf(yyout, ", ");
                process_node(const_str->right_sibling);
            }
        }
        if (node->tipo == ESCRITURA_WRITE)
            fprintf(yyout, ")");
        else
            fprintf(yyout, "\\n)");
        break;
    }
    }
}
