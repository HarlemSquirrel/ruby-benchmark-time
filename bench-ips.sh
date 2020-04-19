#!/bin/sh

printf 'Benchmarking iterations per second'
ruby -v
printf "\n"

JRUBY_OPTS='--dev' /usr/bin/time ruby bench-ips.rb

printf "\ndone!\n"
