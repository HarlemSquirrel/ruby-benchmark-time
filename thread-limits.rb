require 'net/http'

##
# Try out limiting concurrent threads to see what the execution time, CPU usage, and
# memory usage is like.
#
# /usr/bin/time ruby thread-limits.rb 4

CONCURRENT_THREAD_LIMIT = ARGV[0].to_i
TOTAL_THREAD_COUNT = 256
@threads = []

def print_threads_status(current = nil)
  msg = Time.now.strftime('%H:%M:%S - ')

  @threads.each_with_index do |t, i|
    # A status of false indicates successfuly thread completion
    # https://ruby-doc.org/core-2.6.5/Thread.html#method-i-status
    status = (t.status || 'done')
    msg << "#{i}: #{status}#{i == current ? '*' : ' '} ".ljust(10)
  end

  puts msg
end

##
# Return true if fewer threads are running than the configured limit
def ready_for_more_threads?
  @threads.count(&:alive?) < CONCURRENT_THREAD_LIMIT
end

puts "\nRunning #{TOTAL_THREAD_COUNT} threads with a " \
     "concurrency limit of #{CONCURRENT_THREAD_LIMIT}\n\n"

TOTAL_THREAD_COUNT.times do |i|
  # Wait until there are fewer running threads then our limit
  until ready_for_more_threads?
    sleep 0.001
  end

  @threads << Thread.new do
    # print_threads_status(i)
    # Do some varied work that uses some memory and takes a some time
    # size = 2**rand(16..24)
    # puts "#{Time.now.strftime('%H:%M:%S - ')} - Starting thread with size: #{size}"
    # Random.urandom(2**rand(16..24)).bytes.sort
    Net::HTTP.get(URI('https://ruby-doc.org/core-2.7.1/Thread.html')).split(/.#{rand(16)}/)
    print '.'
  end
end

# Make sure all threads have completed by joining them to the main thread.
@threads.each(&:join)

puts "\nThreads are all joined now."

# print_threads_status

puts "\nDone!"
