require 'net/http'

##
# Try out limiting concurrent threads to see what the execution time, CPU usage, and
# memory usage is like.
#
# /usr/bin/time ruby thread-limits.rb 4

CONCURRENT_THREAD_LIMIT = ARGV[0].to_i
TOTAL_THREAD_COUNT = 256
@job_threads = []

def print_threads_status(current = nil)
  msg = Time.now.strftime('%H:%M:%S - ')

  @job_threads.each_with_index do |t, i|
    # A status of false indicates successfuly thread completion
    # https://ruby-doc.org/core-2.6.5/Thread.html#method-i-status
    status = (t.status || 'done')
    msg << "Queue size: #{@job_queue.length}  #{i}: #{status}#{i == current ? '*' : ' '} ".ljust(10)
  end

  puts msg
end

##
# A job with some work that will take a bit of time and be run asynchronously.
#
def job(split_size)
  # print_threads_status(i)
  # Do some varied work that uses some memory and takes a some time
  # size = 2**rand(16..24)
  # puts "#{Time.now.strftime('%H:%M:%S - ')} - Starting thread with size: #{size}"
  # Random.urandom(2**rand(16..24)).bytes.sort
  Net::HTTP.get(URI('https://ruby-doc.org/core-2.7.1/Thread.html')).split(/.#{split_size}/)
  print '.'
end

##
# Return true if fewer threads are running than the configured limit
#
def ready_for_more_threads?
  @job_threads.count(&:alive?) < CONCURRENT_THREAD_LIMIT
end

puts "\nRunning #{TOTAL_THREAD_COUNT} threads with a " \
     "concurrency limit of #{CONCURRENT_THREAD_LIMIT}\n\n"

# This will hold data for each job that needs to be done.
@job_queue = Queue.new

# Queue some work to be done but use a new thread so we can move on to starting some workers.
# For now, there's no limit to the size of the queue since it's only holding the data needed
# to perform each job.
enqueuer = Thread.new do
  TOTAL_THREAD_COUNT.times do |i|
    # Add a new set of data for the queue
    @job_queue << rand(16)
  end

  puts "Added #{@job_queue.length} items to the queue."
end


TOTAL_THREAD_COUNT.times do |i|
  # Wait until there are fewer running threads then our limit
  until ready_for_more_threads?
    sleep 0.001
  end

  @job_threads << Thread.new do
    # Start a new job in a new thread that processes the next data in the queue.
    job(@job_queue.pop)
  end
end

# Make sure all threads have completed by joining them to the main thread.
@job_threads.each(&:join)

puts "\nThreads are all joined now."

# print_threads_status

puts "\nDone!"
