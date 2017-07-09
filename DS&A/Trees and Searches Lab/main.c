//	Jack Cassidy
//	Student Number: 1432 0816
#include "BST.h"
#include "QuickSort.h"

#define _CRT_SECURE_NO_WARNINGS

int main()
{
	int select = 1; // 0 - Build balanced, 1 - Build manually

	char list[] = { 'X', 'Z', 'C', 'B', 'A', 'Y' };
	int size = sizeof(list);
	QuickSort(list, size, 0, size -1);
	BST_Node *myTree;

	switch (select)
	{
	case 0: // Build balanced tree from array
			myTree = BuildBalanced(list, 0, size - 1);
			break;

	case 1: // Build tree incrementally by manually adding data
		myTree = (BST_Node*)malloc(sizeof(BST_Node));
		myTree->data = 'D';
		myTree->left = NULL;
		myTree->right = NULL;

		InsertNode(myTree, 'B');
		InsertNode(myTree, 'A');
		InsertNode(myTree, 'C');
		InsertNode(myTree, 'E');
		InsertNode(myTree, 'J');
		InsertNode(myTree, 'F');
		break;
	}

	PrintSorted(myTree);
	TreeSearch(myTree, 'C');
	TreeSearch(myTree, 'G');

	DeleteTree(myTree);
	myTree = NULL;

	printf("Tree deleted..\n");
	getchar();
}

