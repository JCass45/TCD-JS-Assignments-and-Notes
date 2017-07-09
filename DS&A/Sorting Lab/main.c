#include "sort.h"
#include <time.h>

#define _CRT_SECURE_NO_WARNINGS

void FillArray(int* array, int size);

int main()
{
	int intArray[10000];
	int size = sizeof(intArray) / sizeof(int);
	FillArray(intArray, size);
	PrintArray(intArray, size);

	//InsertionSort(intArray, size);
	QuickSort(intArray, size, 0, size - 1);

	PrintArray(intArray, size);
	printf("Probes: %i\n", probes);

	getchar();
	return 0;
}

void FillArray(int * array, int size)
{
	time_t t;
	srand((unsigned)time(&t));

	for (int i = 0; i < size; i++)
	{
		array[i] = rand() % 101;
		//array[i] = i;
	}
}
