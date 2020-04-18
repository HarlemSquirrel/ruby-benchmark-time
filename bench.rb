#!/usr/bin/env ruby

require 'benchmark'
require 'securerandom'

n = 1_000_000

puts "\n++ Loops"

Benchmark.bmbm do |x|
  x.report('for:')   { for i in 1..n; a = "1"; end }
  x.report('times:') { n.times do   ; a = "1"; end }
  x.report('upto:')  { 1.upto(n) do ; a = "1"; end }
end

puts "\n++ String creation"

Benchmark.bmbm do |x|
  x.report('short') { n.times { 'short one' } }
  x.report('long') do
    n.times { 'abcdefghijklmnopqrstuvwxyz123456789)*&^%$#@!QWERTYUIOPLKJHGFDSAZXCVBNM,.\';][=-' }
  end
end

puts "\n++ Math"

Benchmark.bmbm do |x|
  x.report('log')  { n.times { |i| Math.log i } }
  x.report('sqrt') { n.times { |i| Math.sqrt i } }
end
 
puts "\n++ Filesystem"

Benchmark.bmbm do |x|
  x.report('list files') { n.times { Dir.new('/var/log/') } }
end

puts "\n++ Random"

Benchmark.bmbm do |x|
  x.report('rand')     { n.times { Random.rand } }
  x.report('srand')    { n.times { Random.srand } }
  x.report('bytes 32') { n.times { Random.bytes 32 } }
end

puts "\n++ SecureRandom"

Benchmark.bmbm do |x|
  x.report('hex 16')  { n.times { SecureRandom.hex(16) } }
  x.report('hex 128') { n.times { SecureRandom.hex(128) } }

  x.report('random bytes 64')  { n.times { SecureRandom.random_bytes(64) } }
  x.report('random bytes 256') { n.times { SecureRandom.random_bytes(256) } }

  x.report('uuid') { n.times { SecureRandom.uuid } }
end

puts "\n++ SecureRandom and sorting"

Benchmark.bmbm do |x|
  x.report('base64 128 sort') { n.times { SecureRandom.base64(128).split('').sort } }
  x.report('base64 256 sort') { n.times { SecureRandom.base64(256).split('').sort } }
end

puts "\n++ SecureRandom and searching"

Benchmark.bmbm do |x|
  x.report('base64 1 bsearch') do
    n.times do
      char = SecureRandom.base64(1)
      (('a'..'z').to_a + ('A'..'Z').to_a + (1..9).to_a).bsearch { |e| e == char }
    end
  end
  x.report('base64 1 find_index') do
    n.times do
      (('a'..'z').to_a + ('A'..'Z').to_a + (1..9).to_a).find_index SecureRandom.base64(1)
    end
  end
end
