require 'securerandom'

require 'benchmark/ips'

Benchmark.ips do |x|
  x.config(iterations: 3, time: 5, warmup: 2)

  x.report("short string creations") { 'short one' }
  x.report("long string creations") do
    'abcdefghijklmnopqrstuvwxyz123456789)*&^%$#@!QWERTYUIOPLKJHGFDSAZXCVBNM,.\';][=-'
  end
  x.report("2^8 pack Unicode string creations") do
    (0..2**8).to_a.pack('U*')
  end

  x.report("Math.log")  { |i| Math.log i }
  x.report("Math.sqrt") { |i| Math.sqrt i }

  x.report("directory listings")  { Dir.new('/var/log/') }
  x.report("File.write short") { File.write('/tmp/ruby-benchmark-time', 'Hello World!') }
  x.report("File.read short") { File.read('/tmp/ruby-benchmark-time') }
  x.report("File.write 2**16 chars") do
    string = (0..2**16).to_a.pack('U*')
    File.write('/tmp/ruby-benchmark-time', string)
  end
  x.report("File.read 2**16 chars") do
    File.read('/tmp/ruby-benchmark-time')
  end

  x.report("Random.rand")     { Random.rand }
  x.report("Random.srand")    { Random.srand }
  [128, 512, 2048].each do |size|
    x.report("Random.urandom #{size}") { Random.urandom size }
    x.report("Random.urandom #{size} sort") { Random.urandom(size).split('').sort }
  end

  [512, 2048, 4096].each do |size|
    x.report("SecureRandom.base64 #{size}") { SecureRandom.base64(size) }
    x.report("SecureRandom.hex #{size}")  { SecureRandom.hex(size) }
    x.report("SecureRandom.random bytes #{size}") { SecureRandom.random_bytes(size) }
  end

  x.report("SecureRandom.uuid") { SecureRandom.uuid }

  charlist = (('a'..'z').to_a + ('A'..'Z').to_a + (1..9).to_a)

  x.report("SecureRandom.base64 1 bsearch in #{charlist.length}") do
    char = SecureRandom.base64(1)
    charlist.bsearch { |e| e == char }
  end

  x.report("SecureRandom.base64 1 find_index in #{charlist.length}") do
    charlist.find_index SecureRandom.base64(1)
  end
end
