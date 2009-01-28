module DGO
  module Interval
    class Func

      attr_reader :duration

      def initialize(&func)
        @func = func
        @duration = 0
      end

      def call(node)
        @func.call unless @func.nil?
        return false
      end

    end
  end
end
