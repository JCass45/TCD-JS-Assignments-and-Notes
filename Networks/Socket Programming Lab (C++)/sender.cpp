#include <stdlib.h>
#include <stdio.h>
#include <fstream>
#include <string.h>
#include <cstring>
#include <string>
#include <iostream>
#include <bitset>
#include <sstream>
#include <time.h>

#include <unistd.h>
#include <netdb.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>

using namespace std;

// Data frame constants
const int HEADER_SIZE = 16;
const int PAYLOAD_SIZE = 32;
const int TRAILER_SIZE = 16;
const int MAX_PACKET_SIZE = 64;
const int MAX_NUM_PACKETS = 256;
const int MAX_WINDOW_SIZE = 5;
int window;
string rawDataIn;
string packets[MAX_NUM_PACKETS];
bool corruptFrame;

struct Frame
{
	bitset<HEADER_SIZE> header;
	bitset<PAYLOAD_SIZE> payload;
	bitset<TRAILER_SIZE> trailer;

	string fullPacket;
};

bitset<HEADER_SIZE> SetHeader(int sq);
bitset<PAYLOAD_SIZE> SetPayload(string data);
bitset<TRAILER_SIZE> SetTrailer(string data);
string AssembleFullPacket(Frame frame);
void SplitFileContents(string rawData);

// TCP Connection vars
struct sockaddr_in clientAddr, serverAddr;
int clientLen = sizeof(clientAddr);
int serverLen = sizeof(serverAddr);
socklen_t addrLen = sizeof(struct sockaddr);

int clientSocket;
int sendCode;
int recvCode;

const int SENDER_PORT = 12001;
const int RECEIVER_PORT = 12000;
const int BUFFER_SIZE = 1024;
char buffer[BUFFER_SIZE];

// TCP Connection methods
void OpenConnection();
void SendFrame(Frame frame);
void ListenForAck(Frame frame);
bitset<TRAILER_SIZE> CRC(string data);
void Gremlin(bitset<TRAILER_SIZE> &crc);

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
//LinkedList retransmitList;

int main()
{
	ifstream inFile;

	inFile.open("data_in.txt");

	while (!inFile.eof())
	{
		getline(inFile, rawDataIn);
	}

	inFile.close();
	SplitFileContents(rawDataIn);

	Frame frame;
	corruptFrame = false;
	window = MAX_WINDOW_SIZE;

	OpenConnection();
	for (int i = 0; i < MAX_NUM_PACKETS; i++)
	{
		frame.header = SetHeader(i);
		frame.payload = SetPayload(packets[i]);
		frame.trailer = SetTrailer(packets[i]);

		// 1/10 chance of packet corrupting
		if (rand() % 11 == 1)
		{
			Gremlin(frame.trailer);
		}

		frame.fullPacket = AssembleFullPacket(frame);

		SendFrame(frame);
		// If a packet drops we want to keep listening for it and not transmit any more frames
		do
		{
			// Regenerate packet
			if (corruptFrame == true)
			{
				frame.header = SetHeader(i);
				frame.payload = SetPayload(packets[i]);
				frame.trailer = SetTrailer(packets[i]);

				// Still a chance of corruption
				if (rand() % 11 == 1)
				{
					Gremlin(frame.trailer);
				}

				frame.fullPacket = AssembleFullPacket(frame);
			}

			ListenForAck(frame);
			usleep(1000);
		} while (corruptFrame == true);

		usleep(1000);
	}

	cout << "All packets sent! ...." << endl;
	close(clientSocket);
	getchar();
  	return 0;
}

//-------------------- TCP Connection Methods ----------------------------

void OpenConnection()
{
// Establish a socket connection with the receiver
	clientSocket = socket(AF_INET, SOCK_STREAM, 0);
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(RECEIVER_PORT);
	serverAddr.sin_addr.s_addr = INADDR_ANY;

	if (clientSocket < 0)
	{
		printf("Error: Could not open socket");
	}

	if (connect(clientSocket, (struct sockaddr*) &serverAddr, sizeof(serverAddr)) < 0)
	{
		cout << "Error connecting" << endl;
	}
}

void SendFrame(Frame frame)
{
// Convert string to a cstring so we can point to it with the buffer
	const char* data = (frame.fullPacket).c_str();
	strcpy(buffer, data);

	sendCode = sendto(clientSocket, &buffer, BUFFER_SIZE, 0, (struct sockaddr*) &serverAddr, sizeof(serverAddr));

	if (sendCode == -1)
	{
		cout << "Error in sending frame ...." << "Error code: " << errno << endl;
		close(clientSocket);
	}

	else
	{
		cout << "Frame:"<< frame.header.to_ulong() << " sent ...." << endl;
		//retransmitList.AddNode(frame);
	}
}

void ListenForAck(Frame frame)
{
	cout << "Listening for ACK" << endl;
	memset(buffer, 0, sizeof(buffer));
	recvCode = recvfrom(clientSocket, &buffer, BUFFER_SIZE, 0, (struct sockaddr*) &clientAddr, (socklen_t*)&clientAddr);

// Using string stream to extract the integer ack number
	string Buffer(buffer);
	stringstream ss;
	string ACK;
	int ACKnum;
	ss << Buffer;
	ss >> ACK >> ACKnum;
	if (ACK == "ACK")
	{
		cout << "ACK for Frame:" << ACKnum << " ...." << endl;
		//retransmitList.DeleteFrameN(ACKnum);
		corruptFrame = false;
	}

	else if (ACK == "NAK")
	{
		cout << "NAK for Frame:" << ACKnum << " ...." << endl;
		//Frame searchList = retransmitList.FindFrameByNum(ACKnum);
		SendFrame(frame);
		corruptFrame = true;
		//retransmitList.DeleteFrameN((int)searchList.header.to_ulong());
	}

	else
	{
		cout << "Nothing found" << endl;
	}
	cout << endl;
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

void Gremlin(bitset<TRAILER_SIZE> &crc)
{
// Flip the first bit in the crc checksum
	crc[0] = crc[0] ^ 1;
}

//-------------------- Frame Struct Methods ----------------------------
bitset<HEADER_SIZE> SetHeader(int sq)
{
	return bitset<HEADER_SIZE>(sq);
	/*Header returnVal;
	returnVal.sequenceNum = bitset<(HEADER_SIZE / 2)>(sq);
	returnVal.payloadLength = bitset<(HEADER_SIZE / 2)>(len);

	return returnVal;*/
}

bitset<PAYLOAD_SIZE> SetPayload(string data)
{
	char charArray[data.length()];
//Put contents of string into a char array
	data.copy(charArray, data.length());

	string bits;
// Convert each character to a bitset, reconvert the bits back to a string and add it on the bits string
	for (int i = 0; i < data.length(); i++)
	{
		bitset<8> x(charArray[i]);
		bits += x.to_string();
		cout << x.to_string();
	}
	cout << "end" << endl;
// Returns the string data we wanted to represent into a bitset
	return bitset<PAYLOAD_SIZE>(bits);
}

bitset<TRAILER_SIZE> SetTrailer(string data)
{
	char charArray[data.length()];
	//Put contents of string into a char array
	data.copy(charArray, data.length());

	string bits;
	// Convert each character to a bitset, reconvert the bits back to a string and add it on the bits string
	for (int i = 0; i < data.length(); i++)
	{
		bitset<8> x(charArray[i]);
		bits += x.to_string();
	}
	bitset<TRAILER_SIZE> crc = CRC(bits);
	//Gremlin(crc);
	return crc;
}

string AssembleFullPacket(Frame frame)
{
	string returnVal = frame.header.to_string() + frame.payload.to_string() + frame.trailer.to_string();

	return returnVal;
}

void SplitFileContents(string rawData)
{
	for (int i = 0; i < MAX_NUM_PACKETS; i++) 
	{
		packets[i] = rawData.substr(i * 4, 4);
	}
	//packets[MAX_NUM_PACKETS] = rawData.substr(1020, 4);
}