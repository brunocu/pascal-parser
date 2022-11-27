#include "Tree_cpp.h"

 using std::string;

TreeNode::TreeNode(const string key, const int weight, TreeNode* parent)
    : key(key)
    , parent(parent)
    , leftChild(nullptr)
    , rightSibling(nullptr)
{
    if (parent)
    {
        cost = parent->cost + weight;
        if (!(parent->leftChild))
            parent->leftChild = this;
            
        else
        {
            TreeNode* sibling = parent->leftChild;
            while (sibling->rightSibling)
                sibling = sibling->rightSibling;
            sibling->rightSibling = this;
        }
        depth = parent->depth + 1;
    }
    else
    {
        depth = 0;
        cost = weight;
    }
}

TreeNode::TreeNode(const string key, TreeNode* parent)
    : TreeNode(key, 0, parent)
{};

string TreeNode::pathFromRoot()
{
    string path{};
    if(this && this->parent) {
        pathHelper(this, path);
    }
    else
    {
        path = "NO PATH";
    }
    return path;
}

void TreeNode::pathHelper(TreeNode *node, string& path)
{
    if (node->parent)
    {
        pathHelper(node->parent, path);
        path += " " + node->key;
    }
    else
    {
        path = node->key;
    }
}

TreeNode* Tree::getRoot()
{
    return this->root;
}

bool Tree::isAncestor(TreeNode* leaf, string key)
{
    while (leaf)
    {
        if (leaf->key == key)
            return true;
        leaf = leaf->parent;
    }
    return false;
}
