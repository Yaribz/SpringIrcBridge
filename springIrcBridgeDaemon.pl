#!/usr/bin/perl -w
#
# SpringRTS IRC bridge daemon. This daemon ensures a process is listening on TCP
# port 6667, and (re)starts the IRC bridge server if needed.
#
# If a file named "stop" is found in current working directory, the daemon exits
# (this does not stop the IRC bridge server if it is running).
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

while(! -f 'stop') {
  my $isListening=`netstat -ltn | grep 6667 | wc -l`;
  $isListening=0 unless(defined $isListening);
  $isListening=$1 if($isListening =~ /(\d+)/);
  system("./springIrcBridgeServer.pl &") if($isListening == 0);
  sleep(60);
}

unlink('stop');
