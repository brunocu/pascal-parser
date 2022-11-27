#include "tree.h"

void tree_add_child( struct tree_node* parent, struct tree_node* child){
    child->parent = parent;
    if(!(parent->left_child))
        parent->left_child = child;
    else
    {
        struct tree_node* sibling = parent->left_child;
        while(sibling->right_sibling)
            sibling = sibling->right_sibling;
        sibling->right_sibling = child;
    }
}