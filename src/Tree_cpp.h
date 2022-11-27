#ifndef TREE_H
#define TREE_H
#include <string>

struct TreeNode
{
	std::string key;
	int cost;
	TreeNode* parent, * leftChild, * rightSibling;
	int depth;

	TreeNode(const std::string key, const int weight, TreeNode* parent);
	TreeNode(const std::string key, TreeNode* parent);
	
	std::string pathFromRoot();
private:
	static void pathHelper(TreeNode* node, std::string& path);
};

class Tree
{
private:
	TreeNode* root;
public:
	Tree()
		: root(nullptr)
	{};
	Tree(const std::string src) 
		: root(new TreeNode(src, nullptr))
	{};

	TreeNode* getRoot();
	bool isAncestor(TreeNode* leaf, std::string key);
};

#endif // !TREE_H