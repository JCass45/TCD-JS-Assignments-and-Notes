//	Jack Cassidy
//	14320816
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <math.h>

#define MAX_VERTICES 12
#define MAX_CONNECTIONS 4


typedef struct Edge
{
	struct Vertex* to;
	int weight;
} Edge;

typedef struct Vertex
{
	char name;
	int numConnections;
	bool visited;

	struct Vertex* parent;
	int tentative;
	
	Edge* connections[MAX_CONNECTIONS];
} Vertex;

typedef struct Graph
{
	int numVertices;
	Vertex* vertices[MAX_VERTICES];
} Graph;

Graph* CreateGraph()
{
	Graph* new = (Graph*)malloc(sizeof(Graph));
	new->numVertices = 0;
	 
	return new; 
}

Vertex* CreateVertex(char c)
{
	Vertex* new = (Vertex*)malloc(sizeof(Vertex));
	new->name = c;
	new->numConnections = 0;
	new->visited = false;

	new->parent = NULL;
	new->tentative = 999;
	
	return new;
}

Edge* CreateEdge(Vertex* to, int w)
{
	Edge* new = (Edge*)malloc(sizeof(Edge));
	new->to = to;
	new->weight = w;
	
	return new;
}

void AddVertex(Graph* graph, char c)
{
	int index = graph->numVertices;
	graph->numVertices += 1;
	
	graph->vertices[index] = CreateVertex(c);
}

// Add undirected, weighted edge to both Vertices
void AddEdge(Vertex* from, Vertex* to, int w)
{
	for(int i = 0; i < from->numConnections; i++)
	{
		if(from->connections[i]->to->name == to->name)
		{
			printf("Connection between %c and %c already exists\n", from->connections[i]->to->name, to->name);
			return;	
		}
	}
	
	// Edge from A to B
	Edge* fromTo = CreateEdge(to, w);
	// Edge from B to A
	Edge* toFrom = CreateEdge(from, w);
	
	int indexFrom = from->numConnections;
	int indexTo = to->numConnections;
	
	from->numConnections += 1;
	to->numConnections += 1;
	
	// Add edge to A's list of connections 
	from->connections[indexFrom] = fromTo;
	
	// Add edge to B's list of connections  
	to->connections[indexTo] = toFrom;
}

void ResetVisited(Graph* graph)
{
	for (int i = 0; i < graph->numVertices; i++)
	{
		graph->vertices[i]->visited = false;
		graph->vertices[i]->parent = NULL;
		graph->vertices[i]->tentative = 999;
	}

	printf("Reset all vertices in graph\n");
}

bool DFS(Vertex* v, char search)
{
	printf("%c ", v->name);
	
	if(v->name == search)
		return true;
		
	bool found = false;
	v->visited = true;	// Mark as visited
	
	
	for(int i = 0; i < v->numConnections; i++)	// Look through each connection to the current vertex
	{
		if(v->connections[i]->to->visited == false)	// If the connection we're examining hasn't been visited. Prevents infinite recursion loops caused by undirected edges
			found = DFS(v->connections[i]->to, search);
		if(found)
			return true;	// If the connection just examined contained the search value break out of recursion
	}
	
	return false;
}

bool Dij(Graph* graph, Vertex* startVertex, char search)
{
	bool found = false;

	Vertex* visitedSet[MAX_VERTICES];
	int numinVstSet = 0;

	Vertex* curr;
	Vertex* neighbour;

	int currPathDist;
	int minNextPath;

	curr = startVertex;
	curr->tentative = 0;	// Start vertex has 0 tentative distance
	curr->parent = NULL;	// No parent to start vertex

	while (curr && !found)
	{
		printf("%c ", curr->name);

		currPathDist = curr->tentative;

		if (curr->name == search)
			found = true;

		for (int j = 0; j < curr->numConnections; j++)
		{
			neighbour = curr->connections[j]->to;
			// If the neighbours tentative is greater than the path from the current vertex to it, then
			// replace it's tentative with this new path
			if (neighbour->tentative > currPathDist + curr->connections[j]->weight)
			{
				neighbour->tentative = currPathDist + curr->connections[j]->weight;	// Reset neighbours tentative
				neighbour->parent = curr;	// Make the current node the neighbours parent
			}
		}

		curr->visited = true;
		visitedSet[numinVstSet] = curr;
		numinVstSet++;

		curr = NULL;
		minNextPath = 999;

		for (int k = 0; k < graph->numVertices; k++)	// Find the next vertex with the shortest path from the set of all vertices
		{
			if (graph->vertices[k]->tentative < minNextPath && graph->vertices[k]->visited == false)
			{
				curr = graph->vertices[k];
				minNextPath = graph->vertices[k]->tentative;
			}
		}
		
	}

	printf("\nDijkstra path from %c\n", startVertex->name);
	for (int i = 1; i < numinVstSet; i++)
	{
		printf("%c length %i, parent %c\n", visitedSet[i]->name, visitedSet[i]->tentative, visitedSet[i]->parent->name);
	}

	return found;
}

void Search(Graph* graph, char startVertex, char s)
{
	printf("Search direction: ");
	bool found = false;

	//found = DFS(graph->vertices[startVertex % 'A'], s);
	found = Dij(graph, graph->vertices[startVertex % 'A'], s);

	if(found)
		printf("\nFound %c\n", s);
	else
		printf("\nCould not find %c\n", s);

	ResetVisited(graph);
}


int main()
{
	Graph* myGraph = CreateGraph();
	
	for(char c = 'A'; c <= 'L'; c++)
	{
		AddVertex(myGraph, c);
	}
	
	{// Adding connections between vertices. Modulo by A so index postions in the vertices[] array corresponds to the alphabetical value inside it.
		// A connections
		AddEdge(myGraph->vertices['A'%'A'], myGraph->vertices['B'%'A'], 1);
		// B connections
		AddEdge(myGraph->vertices['B'%'A'], myGraph->vertices['C'%'A'], 2);
		AddEdge(myGraph->vertices['B'%'A'], myGraph->vertices['D'%'A'], 2);
		// C connections
	 	AddEdge(myGraph->vertices['C'%'A'], myGraph->vertices['E'%'A'], 3);
	 	AddEdge(myGraph->vertices['C'%'A'], myGraph->vertices['F'%'A'], 2);
		// D connections
	 	AddEdge(myGraph->vertices['D'%'A'], myGraph->vertices['G'%'A'], 2);
		// F connections
	 	AddEdge(myGraph->vertices['F'%'A'], myGraph->vertices['H'%'A'], 1);
	 	AddEdge(myGraph->vertices['F'%'A'], myGraph->vertices['I'%'A'], 2);
	 	AddEdge(myGraph->vertices['F'%'A'], myGraph->vertices['J'%'A'], 4);
		// G connections
	 	AddEdge(myGraph->vertices['G'%'A'], myGraph->vertices['J'%'A'], 1);
	 	AddEdge(myGraph->vertices['G'%'A'], myGraph->vertices['K'%'A'], 2);
	 	AddEdge(myGraph->vertices['G'%'A'], myGraph->vertices['L'%'A'], 3);
		// I connections
	 	AddEdge(myGraph->vertices['I'%'A'], myGraph->vertices['K'%'A'], 11);
		// J connections
	 	AddEdge(myGraph->vertices['J'%'A'], myGraph->vertices['L'%'A'], 5);
	}
	
	{// Print all vertices
		printf("Vertices in myGraph:\n");

		for (int i = 0; i < myGraph->numVertices; i++)
		{
			printf("%c\n", myGraph->vertices[i]->name);
			printf("Connections that Vertex %c has: ", myGraph->vertices[i]->name);

			if (myGraph->vertices[i]->numConnections != 0)
			{
				for (int j = 0; j < myGraph->vertices[i]->numConnections; j++)	// Print all connections associated with each vertex inclusing weight
				{
					printf("%c(%i) ", myGraph->vertices[i]->connections[j]->to->name, myGraph->vertices[i]->connections[j]->weight);
				}
			}

			else
				printf("None");


			printf("\n \n");
		}
	}

	Search(myGraph, 'A', 'X');
	
	printf("\nPress Enter to exit\n");
	getchar();
	return 0;
}
