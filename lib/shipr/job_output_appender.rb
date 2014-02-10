module Shipr
  class JobOutputAppender
    attr_reader :job, :output

    def initialize(job, output)
      @job = job
      @output = output
    end

    def self.append(*args)
      new(*args).append
    end

    def append
      job.output += output
      job.save!
      trigger
    end

  private

    def trigger
      Shipr.push(job.channel, 'output', id: job.id, output: output)
    end

  end
end
