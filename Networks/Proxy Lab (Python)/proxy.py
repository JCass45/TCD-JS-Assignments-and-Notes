import sys
import socket
import os
import threading
import hashlib
import urllib

# Constants
PORT = 8080
MAX_BUFFER = 4096
HOST = 'localhost'
BACKLOG = 5

def main():
# Start socket
    try:
        clientSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        clientSocket.bind((HOST, PORT))
        clientSocket.listen(BACKLOG)
        print 'Proxy running on %s:%d' % (HOST, PORT)

    except socket.error, (message):
        print message
        if clientSocket is not None:
            clientSocket.close()
        sys.exit(1)

        thread = threading.Thread(target=exit)
        thread.start()
    try:
        # Listen for requests
        while 1:
            # conn is the socket we can send and receive to/from the client
            conn, client_addr = clientSocket.accept()
            thread = threading.Thread(target=ProxyThread, args=(conn, client_addr))
            thread.start()

    except KeyboardInterrupt:
        print 'User turned off proxy (From main).. Shutting down ..'
        clientSocket.close()
        sys.exit(1)
#******************End of main*********************

def ProxyThread(conn, client_addr):
    os.chdir('/home/jack/Documents/Networks/Project 2/src/cache')
    serverSocket = None
    try:
        request = conn.recv(MAX_BUFFER)
        method, webserver, port = ParseReq(request)

        #Handle index out of range exception - Throw out the request
        if method is None or webserver is None or port is -1:
            open('bad_requests.txt', 'wb').write(request)
            return

        if method == 'CONNECT':
            print 'Not handling HTTPS yet...'
            return
            '''
            connect_req = 'HTTP/1.0 200 Connection established\r\n\r\n'
            connect_req += 'Proxy-agent: ProxyServer/1.0\r\n'
            print connect_req
            conn.send(connect_req)
            thread = threading.Thread(target=HTTPSProxyThread, args=(conn, serverSocket))
            thread.start()
            '''

        #Handle requests to blocked sites
        is_blacklisted = BlackList(webserver)
        if is_blacklisted:
            print 'Tried to access banned: ' + webserver
            return

        print 'Request = ' + method + ' ' + webserver + ':' + str(port) + ' START'
        cached_data = IsCached(request)

        if cached_data:
            conn.send(cached_data)
            print 'Request = ' + method + ' ' + webserver + ':' + str(port) + ' FINISH'
        else:
            serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            serverSocket.settimeout(1)
            serverSocket.connect((webserver, port))
            serverSocket.send(request)

            # Generate a file name to put the cached request response into
            cache = hashlib.md5(request)
            filename = cache.hexdigest() + ".txt"

            while 1:
                # serverSocket set to non-blocking and will timeout after 2s
                data = serverSocket.recv(MAX_BUFFER)
                conn.send(data)
                open(filename, 'a+').write(data)

    except socket.timeout:
        print 'Request = ' + method + ' ' + webserver + ':' + str(port) + ' FINISH'

    except socket.error, (message):
        print message

    except KeyboardInterrupt:
        print 'User turned off proxy .. Shutting down ..'
        if conn is not None:
            conn.close()
        if serverSocket is not None:
            serverSocket.close()
        sys.exit(1)

    except OSError:
        print os.getcwd()

    finally:
        exc_type, exc_obj, tb = sys.exc_info()

        if tb is not None:
            lineno = tb.tb_lineno
            if lineno != 83:
                print 'Error on Line:' + str(lineno)

        if conn is not None:
            conn.close()
        if serverSocket is not None:
            serverSocket.close()
#******************End of ProxyThread*********************
'''
def HTTPSProxyThread(conn, serverSocket):
    while 1:
        request = conn.recv(MAX_BUFFER)
        method, webserver, port = ParseReq(request)
        if method is None or webserver is None or port is -1:
            return
        serverSocket.connect((webserver, port))
        serverSocket.send(request)

        while 1:
            data = serverSocket.recv(MAX_BUFFER)

        # while there is data to receive from server
            if len(data) > 0:
                conn.send(data)

            else:
                break
#******************End of HTTPSProxyThread*********************
'''
def ParseReq(request):
    try:
        first_line = request.split('\n')[0]
        method = first_line.split(' ')[0]
        url = first_line.split(' ')[1]
        http_pos = url.find('://')
        if http_pos == -1:
            temp = url
        else:
            temp = url[(http_pos + 3):]

        port_pos = temp.find(':')

        webserver_pos = temp.find('/')
        if webserver_pos == -1:
            webserver_pos = len(temp)
        webserver = ''
        port = -1

        if port_pos == -1 or webserver_pos < port_pos:
            port = 80
            webserver = temp[:webserver_pos]

        else:
            port = int((temp[(port_pos + 1):])[:webserver_pos - port_pos -1])
            webserver = temp[:port_pos]

        return method, webserver, port

    except IndexError:
        print 'out of index error'
        return None, None, -1

    except KeyboardInterrupt:
        print 'User turned off proxy (From ParseReq).. Shutting down ..'
        sys.exit(1)
#******************End of ParseReq()*********************

def IsCached(req):
    try:
        #os.chdir('/home/jack/Documents/Networks/Project 2/src/cache')
        cache = hashlib.md5(req)
        filename = cache.hexdigest() + ".txt"

        if os.path.exists(filename):
            print "Cache hit"
            data_list = open(filename, 'r').read()
            #data_str = ''.join(data_list)
            #os.chdir('/home/jack/Documents/Networks/Project 2/src')
            return data_list

        else:
            print "Cache miss"
            #os.chdir('/home/jack/Documents/Networks/Project 2/src')
            return

    except OSError:
        print os.getcwd()

    except KeyboardInterrupt:
        print 'User turned off proxy (From IsCached).. Shutting down ..'
        sys.exit(1)

#******************End of IsCached()*********************

def BlackList(webserver):
    blacklist_file = open('blacklist.txt', 'r')
    for line in blacklist_file:
        if webserver in line:
            return True
    blacklist_file.close()
    return False
#******************End of Blacklist()*********************

if __name__ == '__main__':
    main()
