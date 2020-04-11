#!/usr/bin/env bash

sudo pkill dd

sudo cgdelete -g cpu:A
sudo cgdelete -g cpu:B

sudo cgcreate -g cpu:A
sudo cgcreate -g cpu:B

sudo cgset -r cpu.shares=1536 A
sudo cgset -r cpu.shares=512 B

sudo cgget -r cpu.shares A
sudo cgget -r cpu.shares B

sudo cgexec -g cpu:A dd if=/dev/zero of=/dev/null &
sudo cgexec -g cpu:A dd if=/dev/zero of=/dev/null &
sudo cgexec -g cpu:A dd if=/dev/zero of=/dev/null &
sudo cgexec -g cpu:A dd if=/dev/zero of=/dev/null &

sudo cgexec -g cpu:B dd if=/dev/zero of=/dev/null &
sudo cgexec -g cpu:B dd if=/dev/zero of=/dev/null &
sudo cgexec -g cpu:B dd if=/dev/zero of=/dev/null &
sudo cgexec -g cpu:B dd if=/dev/zero of=/dev/null &
