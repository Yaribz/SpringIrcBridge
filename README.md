SpringIrcBridge
===============
Multithreaded TCP bridge server which translates IRC commands into
[SpringRTS](http://springrts.com/) lobby commands. It acts like a proxy for
lobby connections, making it possible to use a standard IRC client to connect
to the lobby server.

Components
----------
* [SpringIrcBridge.pm](SpringIrcBridge.pm): Perl module implementing the
  protocol translation between an IRC client and the SpringRTS lobby server.
* [springIrcBridgeDaemon.pl](springIrcBridgeDaemon.pl): SpringRTS IRC bridge
  daemon. This daemon ensures a process is listening on TCP port 6667, and
  (re)starts the IRC bridge server if needed.
* [springIrcBridgeServer.pl](springIrcBridgeServer.pl): SpringRTS IRC bridge
  server. This server listens to IRC connections on ports 6667 and 16667, and
  spawns IRC bridge threads on new connections.

Dependencies
------------
The SpringIrcBridge application depends on following projects:
* [SimpleLog](https://github.com/Yaribz/SimpleLog)
* [SpringLobbyInterface](https://github.com/Yaribz/SpringLobbyInterface)

Installation
------------
* Copy the dependencies listed above (SimpleLog.pm and SpringLobbyInterface.pm)
  into same location as SpringIrcBridge files
* Run "springIrcBridgeServer.pl", it will listen to IRC connections on ports
  6667 and 16667

Administration
--------------
The springIrcBridgeServer process handles following POSIX signals:
* SIGTERM: closes server socket, wait for clients to disconnect and then exit
* SIGUSR1: closes server socket, start a new bridge server process and wait
  for clients connected to current process to disconnect before exiting

The SIGUSR1 signal can be used to reload code without impacting connected
users.

Logs are available in the "log" subdirectory (created automatically if needed)

Usage
-----
Configure your IRC client as follows:
* server: irc.springrts.com (or the address of your own bridge)
* port: 6667 (or 16667)
* nickname: login of a valid Spring lobby account (not connected to Spring
  lobby server currently)
* password: password of the Spring lobby account 

Then you can use the bridge like any other IRC server (list channels, join
channels, send private messages...).

See the [SpringIrcBridge wiki](http://springrts.com/wiki/IrcBridge) for more
information.

Licensing
---------
Please see the file called [LICENSE](LICENSE).

Author
------
Yann Riou <yaribzh@gmail.com>