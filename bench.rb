#!/usr/bin/env ruby

require 'benchmark'
require 'securerandom'

n = 5_000_000

puts "\nSet variable in loop"

Benchmark.bmbm do |x|
  x.report("for:")   { for i in 1..n; a = "1"; end }
  x.report("times:") { n.times do   ; a = "1"; end }
  x.report("upto:")  { 1.upto(n) do ; a = "1"; end }
end

puts "\nString creation"

Benchmark.bmbm do |x|
  x.report('short') { n.times { 'short one' } }
  x.report('long')  { n.times { 'abcdefghijklmnopqrstuvwxyz123456789)*&^%$#@!QWERTYUIOPLKJHGFDSAZXCVBNM,.\';][=-' } }
end


puts "\nFilesystem"

Benchmark.bmbm do |x|
  x.report('list files') { n.times { Dir.new('/var/log/') } }
end


puts "\nSecureRandom"

Benchmark.bmbm do |x|
  x.report('hex 16')  { n.times { SecureRandom.hex(16) } }
  x.report('hex 128') { n.times { SecureRandom.hex(128) } }

  x.report('random bytes 64')  { n.times { SecureRandom.random_bytes(64) } }
  x.report('random bytes 256') { n.times { SecureRandom.random_bytes(256) } }

  x.report('uuid') { n.times { SecureRandom.uuid } }
end
