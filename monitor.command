#!/bin/sh
#  monitor.command
#  RouterMonitor
#
#  Created by Julian Lima on 21/8/16.
#  Copyright © 2016 Julian Lima. All rights reserved.

for ip in 192.168.0.{1..250};do
 ping -c1 -W0 $ip
done