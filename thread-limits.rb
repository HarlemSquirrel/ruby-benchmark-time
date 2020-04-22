require 'net/http'

##
# Try out limiting concurrent threads to see what the execution time, CPU usage, and
# memory usage is like.
#
# Ex.
# /usr/bin/time ruby thread-limits.rb 4
#
# Or do some comparisons with different limits.
# declare -a limits=(4 8 16 32 64 128 256); for n in "${limits[@]}"; do
#   /usr/bin/time ruby thread-limits.rb $n;
# done

##
# A job with some work that will take a bit of time.
#
class CoolJob
  attr_reader :split_size, :url

  def initialize(split_size:, url:)
    @split_size = split_size
    @url = url
  end

  def do
    Net::HTTP.get(URI(url)).split(/.#{split_size}/)
  end
end

##
# Create a list of data for jobs that need to be done.
# https://ruby-doc.org/core/Queue.html
#
class CoolQueue
  RUBY_CLASS_NAMES = %w[Array Integer MatchData Object Queue  String Thread].freeze

  attr_reader :queue

  ##
  # Create a new queue with some work to be done.
  # Use a new thread so we can move on to starting some workers.
  # For now, there's no limit to the size of the queue since it's only holding the data needed
  # to perform each job.
  #
  def initialize(queue_length)
    @queue = Queue.new

    Thread.new do
      queue_length.times do |i|
        # Add a new set of data for the queue
        queue << { url: "https://ruby-doc.org/core-2.7.1/#{RUBY_CLASS_NAMES.sample}.html",
                        split_size: rand(16) }
      end

      puts "Added #{queue.length} items to the queue."
    end
  end
end

##
# Create a new queue and process them in concurrent job threads with a configured concurrency limit.
#
class JobManager
  TOTAL_THREAD_COUNT = 256

  attr_reader :concurrency_limit, :job_threads

  def initialize(concurrency_limit)
    @concurrency_limit = concurrency_limit
  end

  def run
    @job_threads = []

    puts "\nRunning #{TOTAL_THREAD_COUNT} threads with a " \
    "concurrency limit of #{concurrency_limit}\n\n"

    # This will hold data for each job that needs to be done.
    # https://ruby-doc.org/core/Queue.html
    @job_queue = CoolQueue.new(TOTAL_THREAD_COUNT).queue

    TOTAL_THREAD_COUNT.times do |i|
      # Wait until there are fewer running threads then our limit
      until ready_for_more_threads?
        sleep 0.001
      end

      @job_threads << Thread.new do
        # Create and start a new job in a new thread that processes the next data in the queue.
        CoolJob.new(**@job_queue.pop).do
        # Print a dot to show that the job has completed and we're at the end of this thread.
        print '.'
      end
    end

    # Make sure all threads have completed by joining them to the main thread.
    @job_threads.each(&:join)

    puts "\nThreads are all joined now."

    # print_threads_status

    puts "\nDone!"
  end

  private

  def print_threads_status(current = nil)
    msg = Time.now.strftime('%H:%M:%S - ')

    @job_threads.each_with_index do |t, i|
      # A status of false indicates successfuly thread completion
      # https://ruby-doc.org/core-2.6.5/Thread.html#method-i-status
      status = (t.status || 'done')
      msg << "Queue size: #{@job_queue.length}  " \
             "#{i}: #{status}#{i == current ? '*' : ' '} ".ljust(10)
    end

    puts msg
  end

  ##
  # Return true if fewer threads are running than the configured limit
  #
  def ready_for_more_threads?
    @job_threads.count(&:alive?) < concurrency_limit
  end
end


runner = JobManager.new ARGV[0].to_i
runner.run
