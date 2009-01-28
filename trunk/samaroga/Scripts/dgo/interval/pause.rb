module DGO
  module Interval
    class Pause

      attr_reader :depth, :duration

      def initialize(&func)
        @func = func
        @depth = 1
        @duration = 0
      end

      def call(node)
        return true if @func.nil?
        return @func.call
      end

    end
  end
end
