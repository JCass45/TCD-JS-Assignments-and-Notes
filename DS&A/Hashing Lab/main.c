/*
	Author: Jack Cassidy
	Student No: 14320816
	Date: 28/07/2016
*/
#include <stdio.h>
#include <string.h>
#include <math.h>

// Constants
#define _CRT_SECURE_NO_WARNINGS
#define NUM_TEST_STRINGS 35
#define MAX_KEY_LENGTH 15 // Must be at least 1 bigger than actual max key length to accomodate the \0 character
#define HASH_TABLE_SIZE 34 // Must be greater than 2 for double hashing

// Globals
char hashTable[HASH_TABLE_SIZE][MAX_KEY_LENGTH];
int totalProbes = 0;
int numEntries = 0;

// Linear Probing Method
int hashFunction1(const char* key, int table_size);

// Double Hashing Method
int hashFunction2(const char* key, int table_size);

// Returns highest common factor of two numbers
int hcf(int a, int h);

int main()
{
	char testStrings[NUM_TEST_STRINGS][MAX_KEY_LENGTH] = { "prince adam",
															"orko",
															"cringer",
															"teela",
															"aleet",
															"princess adora",
															"orko" ,
															"Benita",
															"Cruz",
															"Ella",
															"Georgann",
															"Harris",
															"Dorinda",
															"Maryanne",
															"Kristi",
															"Dante",
															"Kai",
															"Rona",
															"Yolando",
															"Shaneka",
															"Norberto",
															"Joseph",
															"Mafalda",
															"Mari",
															"Stormy",
															"Jordan",
															"Destiny",
															"Raphael",
															"Santina",
															"Trinh",
															"Eleanora",
															"Micheal",
															"Libbie",
															"Ching",
															"Gianna"};

	for (int i = 0; i < NUM_TEST_STRINGS; i++)
	{
		//int index = hashFunction1(testStrings[i], HASH_TABLE_SIZE);
		int index = hashFunction2(testStrings[i], HASH_TABLE_SIZE);

		if (index == -1)
		{
			printf("Hash Table full! \n");
			getchar();
			return 0;
		}

		for (int j = 0; j < strlen(testStrings[i]); j++)
		{
			hashTable[index][j] = testStrings[i][j];
		}
	}

	printf("\nTotal number of probes: %i\n", totalProbes);
	printf("Load: %f\n", ((double)numEntries/(double)HASH_TABLE_SIZE));
	getchar();
}
/*
	Linear Probing Method
	Straight forward linear probe, if key produces an index that is occupied increment index until
	an empty spot is found.
*/
int hashFunction1(const char * key, int table_size)
{
	int index = 0;
	int probes = 1;

	for (int i = 0; i < strlen(key); i++)
	{
		index += key[i];
	}
	index = index % table_size;
	
	if (strcmp(hashTable[index], key) == 0) // Prevent identical entries
		return index;

	while (hashTable[index][0] != '\0')
	{
		index = (index + 1) % table_size;
		probes++;

		if (probes > table_size)
		{
			return -1;
		}
	}

	numEntries++;
	printf("Key: %-18s", key);
	printf("Index: %-5i", index);
	printf("Probes: %-5i\n", probes);
	totalProbes += probes;
	return index;
}

/*
	Double Hashing Method
	Ensures offset is relatively prime to the table size, preventing infinite looping
	while looking for an empty index
 */
 int hashFunction2(const char * key, int table_size)
{
	int index = 0;
	int probes = 1;

	for (int i = 0; i < strlen(key); i++)
	{
		index += key[i];
	}
	index = index % table_size;

	if (strcmp(hashTable[index], key) == 0)	// Prevent identical entries
		return index;

	int offset = table_size / 2;

	while (hcf(table_size, offset) != 1) // Ensures the offset is relatively prime to the table size, hence why 
	{									 // table size of 2 won't work for double hasing
		offset--;
	}

	// Double Hashing
	while (hashTable[index][0] != '\0')
	{
		index = (index + offset) % table_size;
		probes++;

		if (probes > table_size * 3) // Table is probably full
			return -1;
	}

	numEntries++;
	printf("Key: %-18s", key);
	printf("Index: %-5i", index);
	printf("Probes: %-5i\n", probes);
	totalProbes += probes;
	return index;
}

// Calculates highest common factor of two numbers
int hcf(int a, int h) 
{
	int temp;
	while (1)
	{
		temp = a%h;
		if (temp == 0)
			return h;
		a = h;
		h = temp;
	}
}