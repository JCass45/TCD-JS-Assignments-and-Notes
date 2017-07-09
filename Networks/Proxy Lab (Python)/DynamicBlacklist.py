import os
import sys

def DynamicBlackList():
    print 'Write command in the format ADD/DELETE [WEBSERVER]'
    print 'WEBSERVER should be in the format www.[site].com'
    os.chdir('/home/jack/Documents/Networks/Project 2/src/cache')
    while 1:
        try:
            command = raw_input('Enter command: ');

            action = command.split(' ')[0]
            webserver = command.split(' ')[1]

            if action == 'ADD':
                open('blacklist.txt', 'a+').write(webserver + '\n')
                print 'Added ' + webserver + ' to Blocked list'

            elif action == 'DELETE':
                blacklist_file = open('blacklist.txt', 'r')
                lines = blacklist_file.readlines()
                blacklist_file.close()
                blacklist_file = open('blacklist.txt', 'w')
                for line in lines:
                    if webserver not in line:
                        blacklist_file.write(line)
                blacklist_file.close()
                print 'Deleted ' + webserver + ' from Blocked list'

            else:
                print 'Not a correct command, try again!'

        except IndexError:
            print 'Not a correct command, try again!'

        except KeyboardInterrupt:
            print 'User turned off proxy (From DynamicBlackList).. Shutting down ..'
            sys.exit(1)

if __name__ == '__main__':
    DynamicBlackList()
