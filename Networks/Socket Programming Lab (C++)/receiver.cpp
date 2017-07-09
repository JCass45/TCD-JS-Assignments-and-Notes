#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <cstring>
#include <string>
#include <iostream>
#include <fstream>
#include <bitset>
#include <sstream>

#include <unistd.h>
#include <errno.h>
#include <netdb.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

using namespace std;

// Data frame constants
const int HEADER_SIZE = 16;
const int PAYLOAD_SIZE = 32;
const int TRAILER_SIZE = 16;
const int MAX_PACKET_SIZE = 64;
const int MAX_NUM_PACKETS = 256;
string rawDataOut;
bool allPacketsRcvd;
ofstream outFile;

struct Frame
{
	bitset<HEADER_SIZE> header;
	bitset<PAYLOAD_SIZE> payload;
	bitset<TRAILER_SIZE> trailer;

	string fullPacket;
};

struct sockaddr_in serverAddr, clientAddr;
int serverSocket, result;
int sendCode;
int recvCode;

const int SENDER_PORT = 12001;
const int RECEIVER_PORT = 12000;
const int BUFFER_SIZE = 1024;
char buffer[BUFFER_SIZE];

void StartListening();
void ReceiveFrame();
void SendResponse(string resp);
bitset<TRAILER_SIZE> CRC(string data);
void JoinFileContents(string data);


// Linked List implementation
//class LinkedList
//{
//private:
//	struct Node
//	{
//		Frame data;
//		Node* next;
//	};
//
//	Node *head, *tail;
//
//public:
//	LinkedList();
//	void AddNode(Frame frame);
//	void DeleteFrameN(int N);
//	int SizeOfList();
//	Frame FindFrameByNum(int N);
//};
//
//LinkedList::LinkedList()
//{
//	head = NULL;
//	tail = NULL;
//}
//
//void LinkedList::AddNode(Frame frame)
//{
//	Node* temp = new Node;
//	temp->data = frame;
//	temp->next = NULL;
//
//	if (head == NULL)
//	{
//		head = temp;
//		tail = temp;
//	}
//
//	else                                                                        // Else reassign tail and add new item                          
//	{
//		tail->next = temp;
//		tail = temp;
//	}
//}
//
//void LinkedList::DeleteFrameN(int N)
//{
//	Node *curr, *prev;
//	(int)head->data.header.to_ulong();
//
//	if (head == NULL)
//		return;
//
//	while (curr != NULL)
//	{
//		if ((int)curr->data.header.to_ulong() == N)
//		{
//			if (curr == head)
//			{
//				head = curr->next;
//			}
//
//			else
//			{
//				prev->next = curr->next;
//
//				if (curr == tail)
//				{
//					tail = prev;
//				}
//			}
//
//			cout << "Frame: " << N << " deleted ...." << endl;
//			delete(curr);
//			return;
//		}
//
//		else
//		{
//			prev = curr;
//			curr = curr->next;
//		}
//	}
//
//	cout << "Frame: " << N << " not found ...." << endl;
//}
//
//int LinkedList::SizeOfList()
//{
//	Node *curr = head;
//	int counter = 0;
//
//	while (curr != NULL)
//	{
//		curr = curr->next;
//		counter++;
//	}
//
//	return counter;
//}
//
//Frame LinkedList::FindFrameByNum(int N)
//{
//	Node *curr = head;
//
//	while ((int)curr->data.header.to_ulong() != N)
//	{
//		curr = curr->next;
//
//		if ((int)curr->data.header.to_ulong() == N)
//		{
//			return curr->data;
//		}
//	}
//
//	cout << "Could not find that frame ...." << endl;
//}
//
//LinkedList ACKList;
//LinkedList NAKList;

int main()
{
	outFile.open("data_out.txt");
	allPacketsRcvd = false;
	StartListening();

	while (!allPacketsRcvd)
	{
		ReceiveFrame();
		usleep(1000);
	}

	outFile << rawDataOut;
	outFile.close();
	close(serverSocket);
	getchar();
}

string BitsetToString(string payload)
{
	string output;
	stringstream sstream(payload);

// For some reason an extra null char is added to output unless we add the -1
	for(int i = 0; i < (payload.length() / 8) - 1; i++)
	{
		bitset<8> bits;
		sstream >> bits;
		char c = char(bits.to_ulong());
		output += c;
	}

	bitset<8> bits;
	sstream >> bits;
	char c = char(bits.to_ulong());
	output += c;
	return output;
}

void StartListening()
{
	serverSocket = socket(AF_INET, SOCK_STREAM, 0);
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(RECEIVER_PORT);
	serverAddr.sin_addr.s_addr = INADDR_ANY;

	int bindPort = bind(serverSocket, (struct sockaddr*) &serverAddr, sizeof(serverAddr));

	if (bindPort < 0)
	{
		cout << "Error binding .... Error code: " << errno << endl;
		close(serverSocket);
	}
	else
		cout << "bind success" << endl;
	listen(serverSocket, 5);
	serverSocket = accept(serverSocket, (struct sockaddr*) &clientAddr, (socklen_t *)&clientAddr);
}

void ReceiveFrame()
{
	memset(buffer, 0, sizeof(buffer));
	recvCode = recvfrom(serverSocket, &buffer, BUFFER_SIZE, 0, (struct sockaddr*) &clientAddr, (socklen_t*)&clientAddr);

	if (recvCode > 0)
	{
		cout << "Receiving ...." << endl;
		// Chop up packet
		string fullPacket(buffer), header, payload, trailer;
		header = fullPacket.substr(0, HEADER_SIZE);
		payload = fullPacket.substr(HEADER_SIZE, PAYLOAD_SIZE);
		trailer = fullPacket.substr(HEADER_SIZE + PAYLOAD_SIZE, TRAILER_SIZE);

		bitset<HEADER_SIZE> headerDisp(header);
		bitset<PAYLOAD_SIZE> payloadDisp(payload);
		bitset<TRAILER_SIZE> trailerDisp(trailer);

		cout << "Header: " << headerDisp.to_ulong() << endl;
		cout << "Payload: " << BitsetToString(payload) << endl;
		cout << "Trailer: " << trailerDisp.to_ulong() << endl;

		// Error check, pass payload through crc16 again and see if its return value matches the checksum in the trailer
		bitset<TRAILER_SIZE> crc = CRC(payload);
		bitset<TRAILER_SIZE> trailerCheck(trailer);

		if (crc != trailerCheck)
		{
			SendResponse(("NAK " + to_string(headerDisp.to_ulong())));
		}

		else
		{
			SendResponse(("ACK " + to_string(headerDisp.to_ulong())));
			JoinFileContents(BitsetToString(payload));

		// Processed all packets
			if ((int)headerDisp.to_ulong() == 255)
				allPacketsRcvd = true;
		}

		cout << endl;
	}
}

void SendResponse(string resp)
{
	const char* data = (resp).c_str();
	strcpy(buffer, data);

	sendCode = sendto(serverSocket, &buffer, BUFFER_SIZE, 0, (struct sockaddr*) &clientAddr, sizeof(clientAddr));

	if (sendCode == -1)
	{
		cout << "Error in sending response ...." << "Error code: " << errno << endl;
		close(serverSocket);
	}

	else
	{
		cout << resp << " sent ...." << endl;
	}
}

bitset<TRAILER_SIZE> CRC(string data)
{
	// 0x8005 = 32773(10), the CRC16 polynomial
	bitset<16> polynomial(32773);
	bitset<16> remainder(data);
	bitset<16> divisor(128);

	for (unsigned int bit = 8; bit > 0; bit--)
	{
		//check if uppermost bit is 1
		if ((remainder & divisor) == 1)
		{
			//XOR remainder with divisor
			remainder ^= polynomial;
		}
		//shift bit into remainder
		remainder = (remainder << 1);
	}
	return (remainder >> 4);
}

void JoinFileContents(string data)
{
	rawDataOut += data;
}