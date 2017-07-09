#pragma once
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#define _CRT_SECURE_NO_WARNINGS


// Global vars
int probes;


//	Helper Functions
bool Sorted(int* array, int size);
void Swap(int* array, int a, int b);
void PrintArray(int* array, int size);

int QSPartition(int* array, int left, int pivot);


//	Sorting Functions

/* 
	Divides array into sorted and unsorted portions, with the first value starting in the sorted portion. 
	Each value in the unsorted portion is placed, in order, in the sorted portion. Each value in the sorted portion
	that is greater than the current value is shifted to the right until the current value finds its place.
*/
void InsertionSort(int* array, int size);

/*
	Splits array recursively. Chooses a pivot point at the last index and a "wall" at the first index of each sub array. Values
	less than the pivot go to the left of the wall and values greater than go to the right of the wall. At the end of each 
	partition the pivot is swapped with the index next to the wall. As sub arrays get smaller values are put in correct place
*/
void QuickSort(int* array, int size, int left, int right);