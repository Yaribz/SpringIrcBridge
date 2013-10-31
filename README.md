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

Usage
-----
Configure your IRC client as follows:
* server: irc.springrts.com (or the address if your own bridge)
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