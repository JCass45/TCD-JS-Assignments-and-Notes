//	Jack Cassidy
//	Student Number: 1432 0816
#include "QuickSort.h"

void Swap(char* array, int a, int b)
{
	char temp = array[a];
	array[a] = array[b];
	array[b] = temp;
}

int QSPartition(char * array, int left, int pivot)
{
	int wall = left - 1;

	for (int j = left; j < pivot; j++)
	{
		if (array[j] <= array[pivot])
		{
			wall++;
			Swap(array, wall, j);
		}
	}
	Swap(array, wall + 1, pivot);
	return (wall + 1);
}

void QuickSort(char * array, int size, int left, int right)
{
	if (left < right)
	{
		int pivotPoint = QSPartition(array, left, right);
		QuickSort(array, size, left, pivotPoint - 1);
		QuickSort(array, size, pivotPoint + 1, right);
	}
}