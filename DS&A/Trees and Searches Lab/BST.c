//	Jack Cassidy
//	Student Number: 1432 0816
#include "BST.h"

void InsertNode(BST_Node *root, char data)
{
	char lastBranch = '0';
	BST_Node *curr = root;
	BST_Node *parent = NULL;

	BST_Node *newNode = (BST_Node*)malloc(sizeof(BST_Node));
	newNode->data = data;
	newNode->left = NULL;
	newNode->right = NULL;

	while (curr)
	{
		parent = curr;

		if (data < curr->data)
		{
			curr = curr->left;
			lastBranch = 'L';		// remembers the last direction taken 
		}

		else if (data > curr->data)
		{
			curr = curr->right;
			lastBranch = 'R';
		}

		else if (data == curr->data)
		{
			printf("The value %c is already in the tree!\n", data);
			return;
		}
	}

	if (lastBranch == 'L')
		parent->left = newNode;
	else if (lastBranch == 'R')
		parent->right = newNode;
	else
		printf("Something weird has happened...\n");
}

BST_Node * TreeSearch(BST_Node * root, char searchVal)
{
	BST_Node* curr = root;

	while (curr)
	{
		if (curr->data == searchVal)
		{
			printf("\nFound %c!\n", searchVal);
			return curr;
		}


		else if (curr->data > searchVal)
			curr = curr->left;

		else if (curr->data < searchVal)
			curr = curr->right;
	}

	printf("\nCould not find %c\n", searchVal);
	return NULL;
}

void PrintSorted(BST_Node * root)
{
	if (root != NULL)
	{
		PrintSorted(root->left);			// go as far left as possible
		printf("%c ", root->data);			// visit node
		PrintSorted(root->right);			// go as far right as possible
	}
}

void DeleteTree(BST_Node * root)
{
	if (root != NULL)
	{
		DeleteTree(root->left);
		DeleteTree(root->right);
		free(root);
		root = NULL;
	}
}

BST_Node* BuildBalanced(char * array, int left, int right)
{
	if (left > right)
		return NULL;

	int mid = left + (right - left) / 2;
	BST_Node* node = (BST_Node*)malloc(sizeof(BST_Node));

	node->data = array[mid];
	node->left = BuildBalanced(array, left, mid - 1);
	node->right = BuildBalanced(array, mid + 1, right);

	return node;
}