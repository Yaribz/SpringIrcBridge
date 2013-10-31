#!/usr/bin/perl -w
#
# SpringRTS IRC bridge server. This server listens to IRC connections on ports
# 6667 and 16667, and spawns IRC bridge threads on new connections. It restarts
# every 24 hours in a transparent way for users (connection threads keep running
# in background until the clients disconnect) in order to optimize thread memory
# management. This also makes it possible to update code and restart the bridge
# server without impacting connected users.
#
# The server handles following POSIX signals:
# - SIGTERM: close server socket, wait for clients to disconnect and then exit
# - SIGUSR1: close server socket, start a new bridge server process and wait for
# clients connected to current process to disconnect before exiting
#
# The SIGUSR1 signal can be used to reload code without impacting connected
# users.
#
# Copyright (C) 2013  Yann Riou <yaribzh@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;
use threads;
use threads::shared;

use IO::Select;
use IO::Socket::INET;

use SpringIrcBridge;

$SIG{CHLD}='IGNORE';

mkdir('log') unless(-d 'log');

my $startTime=localtime();
my $startTs=time();
my $running=1;
my $restart=0;
my $nbClient=0;
my @serverSocks;
foreach my $serverPort (6667,16667) {
  my $serverSock=IO::Socket::INET->new(Listen => 5,
                                       LocalPort => $serverPort,
                                       Proto => 'tcp',
                                       ReuseAddr => 1);
  if(! defined $serverSock) {
    print "Unable to open server socket (port $serverPort): $@\n";
    exit 1;
  }
  push(@serverSocks,$serverSock);
}

my $select=IO::Select->new(@serverSocks);

$SIG{TERM} = \&sigTermHandler;
$SIG{USR1} = \&sigUsr1Handler;
sub sigTermHandler {
  $running=0;
  print "Received SIGTERM signal, exiting...\n";
}
sub sigUsr1Handler {
  $running=0;
  $restart=1;
  print "Received SIGUSR1 signal, restarting...\n";
}

sub createNewBridge {
  my ($sock,$localNbClient)=@_;
  undef $select;
  undef @serverSocks;
  my $ip=$sock->peerhost();
  my $bridge=SpringIrcBridge->new($sock,$localNbClient);
  $bridge->run();
}

while($running) {
  my @pendingServerSocks=$select->can_read(1);
  foreach my $pendingServerSock (@pendingServerSocks) {
    my $clientSock=$pendingServerSock->accept();
    if(defined $clientSock) {
      $nbClient++;
      async { undef $pendingServerSock; undef @pendingServerSocks; createNewBridge($clientSock,$nbClient); };
    }else{
      print "Unable to create client socket!\n";
    }
  }

  my @joinableThreads=threads->list(threads::joinable);
  foreach my $joinableThread (@joinableThreads) {
    $nbClient--;
    $joinableThread->join();
  }
  @joinableThreads=();

  if(time() - $startTs > 86400) {
    $running=0;
    $restart=1;
  }
}

print "Closing server socket(s)... (PID: $$, Start time: $startTime)\n";
undef $select;
foreach my $serverSock (@serverSocks) {
  $serverSock->close();
}
undef @serverSocks;

if($restart) {
  print "Restarting a new server process... (PID: $$, Start time: $startTime)\n";
  my $childPid=fork();
  if(! defined $childPid) {
    print "Unable to fork new server process !\n";
  }elsif($childPid == 0) {
    $SIG{CHLD}='';
    exec("./springIrcBridgeServer.pl");
  }else{
    print "New server process forked: PID $childPid (PID: $$, Start time: $startTime)\n";
  }
}

print "Joining bridge threads... (PID: $$, Start time: $startTime)\n";
my @bridgeThreads=threads->list();
foreach my $bridgeThread (@bridgeThreads) {
  $bridgeThread->join();
}

print "All bridge threads joined, exiting... (PID: $$, Start time: $startTime)\n";
