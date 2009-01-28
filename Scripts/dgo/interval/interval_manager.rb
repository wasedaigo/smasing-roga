require "dgo/interval/interval_runner"
module DGO
  module Interval
    class IntervalManager
      include DGO::Interval
      
      def initialize
        @runners = []
      end
      
      def <<(interval)
        @runners << IntervalRunner.new(interval)
      end
      
      def update
        @runners.each do |runner|
          runner.update unless runner.done?
        end
        @runners = @runners.select{|runner|runner.done?}
      end
    end
  end
end
