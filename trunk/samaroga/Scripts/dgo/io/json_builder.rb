# = Simple JSON builder
#
# Ruby オブジェクトを JSON 文字列に変換するクラスです。 *ruby_obj* を
# 以下のようにして変換できます。
#
#   json_str = JsonBuilder.new.build(ruby_obj)
#
# *ruby_obj* は以下の条件を満たさねばなりません。
#
# - to_s メソッドをサポートしているか、もしくは配列・ハッシュ・ nil のいずれかでなければなりません。
# - ハッシュの全てのキーは to_s メソッドをサポートしていなければなりません。
# - 配列・ハッシュのすべての値は上記の条件を満たしていなければなりません。
#
# もし *ruby_obj* が配列・ハッシュのいずれでもない場合、 1 要素の配列に変換されます。
module DGO
  module IO
    class JsonBuilder

      #:stopdoc:
      Name               = 'JsonBuilder'
      ERR_NestIsTooDeep  = "[#{Name}] Array / Hash nested too deep."
      ERR_NaN            = "[#{Name}] NaN and Infinite are not permitted in JSON."
      #:startdoc:

      # JsonBuilder のインスタンスを新規作成します。 *options* には以下の値を指定できます。
      # [:max_nest]
      #     もし配列・ハッシュのネストがこの値を超えた場合、例外が発生します。
      #     デフォルトは 64 です。
      # [:nan]
      #     すべての NaN はこの値で置き換えられます。もし nil もしくは false であれば
      #     代わりに例外が発生します。デフォルトは nil です。
      def initialize(options = {})
        @default_max_nest = options.has_key?(:max_nest) ? options[:max_nest] : 64
        @default_nan      = options.has_key?(:nan)      ? options[:nan]      : nil
      end

      # *obj* を JSON 形式の文字列に変換します。
      # [obj]
      #     Ruby オブジェクトです。前述の条件を満たしていなければなりません。
      # [options]
      #     new と同じです。
      def build(obj, options = {})
        @max_nest = options.has_key?(:max_nest) ? options[:max_nest] : @default_max_nest
        @nan      = options.has_key?(:nan)      ? options[:nan]      : @default_nan
        case obj
        when Array then build_array(obj, 0)
        when Hash  then build_object(obj, 0)
        else            build_array([obj], 0)
        end
      end

      private #---------------------------------------------------------

      def escape(str)
        str.gsub(/[^\x20-\x21\x23-\x5b\x5d-\xff]/n) do |chr|
          if chr[0] != 0 && (index = "\"\\/\b\f\n\r\t".index(chr[0]))
            "\\" + '"\\/bfnrt'[index, 1]
          else
            sprintf("\\u%04x", chr[0])
          end
        end
      end

      def build_value(obj, level)
        case obj
        when Integer, TrueClass, FalseClass then obj.to_s
        when Float    then raise ERR_NaN unless obj.finite? || (obj = @nan) ; obj.to_s
        when NilClass then 'null'
        when Array    then build_array(obj, level + 1)
        when Hash     then build_object(obj, level + 1)
        else          "\"#{escape(obj.to_s)}\""
        end
      end

      def build_array(obj, level)
        raise ERR_NestIsTooDeep if level >= @max_nest
        '[' + obj.map { |item| build_value(item, level) }.join(',') + ']'
      end

      def build_object(obj, level)
        raise ERR_NestIsTooDeep if level >= @max_nest
        '{' + obj.map do |item|
          "#{build_value(item[0].to_s,level)}:#{build_value(item[1],level)}"
        end.join(',') + '}'
      end

    end
  end
end