module Cline
  class ScheduledJob
    INTERVAL = 60

    def initialize(trigger, &block)
      @trigger = trigger
      @job     = block
    end

    def run
      loop do
        invoke_if_needed

        sleep INTERVAL
      end
    end

    private

    def invoke_if_needed
      Thread.fork { Command.new.instance_eval(&@job) } if @trigger.()
    rescue Exception => e
      Cline.logger.error [e.class, e.message].join(' ')
    end
  end
end
