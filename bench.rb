#!/usr/bin/env ruby

require 'benchmark'
require 'securerandom'

n = 10_000

Benchmark.bmbm do |x|
  x.report("#{n} for loops")   { for i in 1..n; a = "1"; end }
  x.report("#{n} times loops") { n.times { a = "1" } }
  x.report("#{n} upto loops")  { 1.upto(n) {  a = "1" } }

  x.report("#{n} short string creations") { n.times { 'short one' } }
  x.report("#{n} long string creations") do
    n.times { 'abcdefghijklmnopqrstuvwxyz123456789)*&^%$#@!QWERTYUIOPLKJHGFDSAZXCVBNM,.\';][=-' }
  end
  x.report("#{n} 2^8 pack Unicode string creations") do
    n.times { (0..2**8).to_a.pack('U*') }
  end

  x.report("#{n} Math.log")  { n.times { |i| Math.log i } }
  x.report("#{n} Math.sqrt") { n.times { |i| Math.sqrt i } }

  x.report("#{n} directory listings")  { n.times { Dir.new('/var/log/') } }
  x.report("#{n} File.write short") { n.times { |i| File.write('/tmp/ruby-benchmark-time', i) } }
  x.report("#{n} File.read short") { n.times { |i| File.read('/tmp/ruby-benchmark-time', i) } }
  x.report("#{n} File.write 2**16 chars") do
    string = (0..2**16).to_a.pack('U*')
    n.times { |i| File.write('/tmp/ruby-benchmark-time', string) }
  end
  x.report("#{n} File.read 2**16 chars") do
    n.times { |i| File.read('/tmp/ruby-benchmark-time') }
  end

  x.report("#{n} Random.rand")     { n.times { Random.rand } }
  x.report("#{n} Random.srand")    { n.times { Random.srand } }
  [32, 64, 128, 256, 512].each do |size|
    x.report("#{n} Random.urandom #{size}") { n.times { Random.urandom size } }
    x.report("#{n} Random.urandom #{size} sort") { n.times { Random.urandom(size).split('').sort } }
  end

  [32, 64, 128, 256, 512].each do |size|
    x.report("#{n} SecureRandom.base64 #{size}") { n.times { SecureRandom.base64(size) } }
    x.report("#{n} SecureRandom.base64 #{size} sort") { n.times { SecureRandom.base64(size).split('').sort } }
    x.report("#{n} SecureRandom.hex #{size}")  { n.times { SecureRandom.hex(size) } }
    x.report("#{n} SecureRandom.hex #{size} sort")  { n.times { SecureRandom.hex(size).split('').sort } }
    x.report("#{n} SecureRandom.random bytes #{size}") { n.times { SecureRandom.random_bytes(size) } }
    x.report("#{n} SecureRandom.random bytes #{size} sort") { n.times { SecureRandom.random_bytes(size).split('').sort } }
  end

  x.report("#{n} SecureRandom.uuid") { n.times { SecureRandom.uuid } }

  x.report("#{n} SecureRandom.base64 1 bsearch") do
    n.times do
      char = SecureRandom.base64(1)
      (('a'..'z').to_a + ('A'..'Z').to_a + (1..9).to_a).bsearch { |e| e == char }
    end
  end

  x.report("#{n} SecureRandom.base64 1 find_index") do
    n.times do
      (('a'..'z').to_a + ('A'..'Z').to_a + (1..9).to_a).find_index SecureRandom.base64(1)
    end
  end
end
