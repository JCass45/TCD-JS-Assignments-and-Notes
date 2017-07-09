#include "sort.h"

#define _CRT_SECURE_NO_WARNINGS

int probes = 0;

bool Sorted(int* array, int size)
{

	for (int i = 0; i < size - 1; i++)
	{
		if (array[i] > array[i + 1])
			return false;
	}

	return true;
}

void Swap(int* array, int a, int b)
{
	int temp = array[a];
	array[a] = array[b];
	array[b] = temp;
}

void PrintArray(int* array, int size)
{
	for (int i = 0; i < size; i++)
	{
		printf("%i ", array[i]);
	}
	printf("\n");
}

int QSPartition(int * array, int left, int pivot)
{
	int wall = left - 1;

	for (int j = left; j < pivot; j++)
	{
		probes++;
		if (array[j] <= array[pivot])
		{
			wall++;
			Swap(array, wall, j);
		}
	}

	Swap(array, wall + 1, pivot);
	return (wall + 1);
}

void InsertionSort(int* array, int size)
{
	for (int i = 1; i < size; i++)
	{
		/*if (Sorted(array, size))
			return;*/
	
		int j = i;
		int element = array[j];

		while (array[j] < array[j - 1] && j > 0)
		{
			probes++;
			Swap(array, j, j - 1);
			j--;
		}
		array[j] = element;
		probes++;
	}
}

void QuickSort(int * array, int size, int left, int right)
{
	/*if (Sorted(array, size))
		return;*/
	if (left < right)
	{
		int pivotPoint = QSPartition(array, left, right);
		QuickSort(array, size, left, pivotPoint - 1);
		QuickSort(array, size, pivotPoint + 1, right);
	}
}