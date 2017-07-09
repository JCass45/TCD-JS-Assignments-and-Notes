//	Jack Cassidy
//	Student Number: 1432 0816
#pragma once
#include <stdlib.h>
#include <stdio.h>
#include "QuickSort.h"

typedef struct BST_Node BST_Node;

struct BST_Node
{
	char data;
	BST_Node *left, *right;
};

// Node by node search using < and > inequalities to find correct location for insertion
void InsertNode(BST_Node *root, char data);

// Node by node search using < and > inequalities, returns pointer to found node
BST_Node* TreeSearch(BST_Node *root, char searchVal);

// In order print of each node
void PrintSorted(BST_Node *root);

// Post order deletion of every node
void DeleteTree(BST_Node *root);

// Builds a balanced tree from an array and returns a pointer to the root of new tree
// Divide & Conquer type method as the array is halved into partitions recursively
BST_Node* BuildBalanced(char* array, int first, int last);