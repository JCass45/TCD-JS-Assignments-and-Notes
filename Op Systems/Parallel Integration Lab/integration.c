#include <pthread.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <math.h>
#include <pthread.h>

#define STEP 100
#define NUM_THREADS 100

double integral = 0;
pthread_mutex_t mutex;
pthread_t threads[NUM_THREADS];

// y = 1-sqrt(x^2)
double Function(double x)
{
	return sqrt(1-pow(x,2));
}

void* Integrate(void* t)
{
	int threadID = (int)t;

	pthread_mutex_lock(&mutex);
	//printf("Thread:%d has mutex and is working\n", threadID);
	for(int i = 0; i <= STEP/NUM_THREADS; i++)
	{
		double param = i + (STEP/NUM_THREADS * threadID); // Cuts integration into blocks by how many threads are running
		integral += 2*Function(param/STEP);
	}
	pthread_mutex_unlock(&mutex);
	//printf("Thread:%d is now finished\n", threadID);
	pthread_exit((void*)0);
}

void main()
{
	pthread_attr_t attr; // used for joining threads, joining the threads will sync them so main exits when they are all finished

	int err;
	double pi = 0;

	void* status; // joining threads

	pthread_mutex_init(&mutex, NULL); // mutex locking
	pthread_attr_init(&attr); // joining threads
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE); // joining threads

	printf("Number of threads being used:%d\n", NUM_THREADS);
	for(int i = 0; i < NUM_THREADS; i++)
	{
		err = pthread_create(&threads[i], &attr, Integrate, (void*)i);

		if(err != 0)
		{
			printf("Error creating thread:%d\n", i);
			return;
		}
	}

	pthread_attr_destroy(&attr);

	for(int i = 0; i < NUM_THREADS; i++)
	{
		err = pthread_join(threads[i], &status);

		if(err != 0)
		{
			printf("Error rejoining thread:%d\n", i);
			return;
		}
	}

	integral = integral/(2*STEP);
	pi = integral * 4;

	printf("The approximate value of PI is %0.10f", pi);
	pthread_mutex_destroy(&mutex);
	pthread_exit(NULL);
}