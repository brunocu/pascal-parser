#include "tree.h"
#include <stdlib.h>

struct tree_node *tree_make_node()
{
    struct tree_node *new_node = (struct tree_node *)malloc(sizeof(struct tree_node));
    new_node->identificador = NULL;
    new_node->parent = NULL;
    new_node->left_child = NULL;
    new_node->right_sibling = NULL;
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