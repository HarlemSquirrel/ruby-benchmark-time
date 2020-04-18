#!/bin/sh

printf 'Benchmarking '
ruby -v

JRUBY_OPTS='--dev' /usr/bin/time -v ruby bench-ips.rb

printf "\ndone!\n"
