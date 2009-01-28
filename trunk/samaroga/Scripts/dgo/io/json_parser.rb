# = Simple JSON parser & builder
#
# Author::  Chihiro Ito
# License:: Public domain (unlike other files)
# Support:: http://groups.google.com/group/webos-goodies/
# Version:: 1.05
#
# シンプルな JSON 処理クラスです。 JsonParser は JSON 文字列を
# 通常の配列・ハッシュに変換し、 JsonBuilder はその逆を行います。
# これらのクラスは JSON 標準への準拠と信頼性・安定性を意図して
# 制作されています。とくに JsonParser クラスには UTF-8 の正当性
# 検査機能があり、一部のセキュリティー攻撃を防ぐことができます。

require 'strscan'


# = Simple JSON parser
#
# このクラスは JSON 文字列を配列やハッシュに変換します。
# *json_str* が JSON 形式の文字列であれば、以下のようにして
# 変換できます。
#
#   ruby_obj = JsonParser.new.parse(json_str)
#
# デフォルトでは、 *json_str* が不正な UTF-8 シーケンスを含んでいると
# 例外が発生します。この挙動は任意のユニコード文字で置き換えるように
# 変更することも可能です。詳細は以下を参照してください。
module DGO
  module IO
    class JsonParser

      #:stopdoc:
      Debug              = false
      Name               = 'JsonParser'
      ERR_IllegalSyntax  = "[#{Name}] Syntax error"
      ERR_IllegalUnicode = "[#{Name}] Illegal unicode sequence"

      StringRegex = /\s*"((?:\\.|[^"\\])*)"/n
      ValueRegex  = /\s*(?:
    		(true)|(false)|(null)|            # 1:true, 2:false, 3:null
    		(?:\"((?:\\.|[^\"\\])*)\")|       # 4:String
    		([-+]?\d+\.\d+(?:[eE][-+]?\d+)?)| # 5:Float
    		([-+]?\d+)|                       # 6:Integer
    		(\{)|(\[))/xn                     # 7:Hash, 8:Array
      #:startdoc:

      # JsonParser のインスタンスを新規作成します。 *options* には以下の値を指定できます。
      # [:validation]
      #     false にすると、 UTF-8 検証機能が無効になります。デフォルトは true です。
      # [:surrogate]
      #     false にすると、サロゲートペアのサポートが無効になります。デフォルトは true です。
      # [:malformed_chr]
      #     JSON 文字列に含まれる不正なシーケンスはこの値で置き換えられます。
      #     nil を設定すると、置き換える代わりに例外を投げます。
      #     デフォルトは nil です。
      def initialize(options = {})
        @default_validation    = options.has_key?(:validation)    ? options[:validation]    : true
        @default_surrogate     = options.has_key?(:surrogate)     ? options[:surrogate]     : true
        @default_malformed_chr = options.has_key?(:malformed_chr) ? options[:malformed_chr] : nil
      end

      # *str* を配列・ハッシュに変換します。
      # [str]
      #     JSON 形式の文字列です。 UTF-8 エンコーディングでなければなりません。
      # [options]
      #     new と同じです。
      def parse(str, options = {})
        @enable_validation = options.has_key?(:validation)    ? options[:validation]    : @default_validation
        @enable_surrogate  = options.has_key?(:surrogate)     ? options[:surrogate]     : @default_surrogate
        @malformed_chr     = options.has_key?(:malformed_chr) ? options[:malformed_chr] : @default_malformed_chr
        @malformed_chr = @malformed_chr[0] if String === @malformed_chr
        @scanner = StringScanner.new(str)
        obj = case get_symbol[0]
              when ?{ then parse_hash
              when ?[ then parse_array
              else         raise err_msg(ERR_IllegalSyntax)
              end
        @scanner = nil
        obj
      end

      private #---------------------------------------------------------

      def validate_string(str, malformed_chr = nil)
        code  = 0
        rest  = 0
        range = nil
        ucs   = []
        str.each_byte do |c|
          if rest <= 0
            case c
            when 0x01..0x7f then rest = 0 ; ucs << c
            when 0xc0..0xdf then rest = 1 ; code = c & 0x1f ; range = 0x00080..0x0007ff
            when 0xe0..0xef then rest = 2 ; code = c & 0x0f ; range = 0x00800..0x00ffff
            when 0xf0..0xf7 then rest = 3 ; code = c & 0x07 ; range = 0x10000..0x10ffff
            else                 ucs << handle_malformed_chr(malformed_chr)
            end
          elsif (0x80..0xbf) === c
            code = (code << 6) | (c & 0x3f)
            if (rest -= 1) <= 0
              if !(range === code) || (0xd800..0xdfff) === code
                code = handle_malformed_chr(malformed_chr)
              end
              ucs << code
            end
          else
            ucs << handle_malformed_chr(malformed_chr)
            rest = 0
          end
        end
        ucs << handle_malformed_chr(malformed_chr) if rest > 0
        ucs.pack('U*')
      end

      def handle_malformed_chr(chr)
        raise err_msg(ERR_IllegalUnicode) unless chr
        chr
      end

      def err_msg(err)
        err + (Debug ? " #{@scanner.string[[0, @scanner.pos - 8].max,16].inspect}" : "")
      end

      def unescape_string(str)
        str = str.gsub(/\\(["\\\/bfnrt])/n) do
          $1.tr('"\\/bfnrt', "\"\\/\b\f\n\r\t")
        end.gsub(/(\\u[0-9a-fA-F]{4})+/n) do |matched|
          seq = matched.scan(/\\u([0-9a-fA-F]{4})/n).flatten.map { |c| c.hex }
          if @enable_surrogate
            seq.each_index do |index|
              if seq[index] && (0xd800..0xdbff) === seq[index]
                n = index + 1
                raise err_msg(ERR_IllegalUnicode) unless seq[n] && 0xdc00..0xdfff === seq[n]
                seq[index] = 0x10000 + ((seq[index] & 0x03ff) << 10) + (seq[n] & 0x03ff)
                seq[n] = nil
              end
            end.compact!
          end
          seq.pack('U*')
        end
        str = validate_string(str, @malformed_chr) if @enable_validation
        str
      end

      def get_symbol
        raise err_msg(ERR_IllegalSyntax) unless @scanner.scan(/\s*(.)/n)
        @scanner[1]
      end

      def peek_symbol
        @scanner.match?(/\s*(.)/n) ? @scanner[1] : nil
      end

      def parse_string
        raise err_msg(ERR_IllegalSyntax) unless @scanner.scan(StringRegex)
        unescape_string(@scanner[1])
      end

      def parse_value
        raise err_msg(ERR_IllegalSyntax) unless @scanner.scan(ValueRegex)
        case
        when @scanner[1] then true
        when @scanner[2] then false
        when @scanner[3] then nil
        when @scanner[4] then unescape_string(@scanner[4])
        when @scanner[5] then @scanner[5].to_f
        when @scanner[6] then @scanner[6].to_i
        when @scanner[7] then parse_hash
        when @scanner[8] then parse_array
        else                  raise err_msg(ERR_IllegalSyntax)
        end
      end

      def parse_hash
        obj = {}
        if peek_symbol[0] == ?} then get_symbol ; return obj ; end
        while true
          index = parse_string
          raise err_msg(ERR_IllegalSyntax) unless get_symbol[0] == ?:
          value = parse_value
          obj[index] = value
          case get_symbol[0]
          when ?} then return obj
          when ?, then next
          else         raise err_msg(ERR_IllegalSyntax)
          end
        end
      end

      def parse_array
        obj = []
        if peek_symbol[0] == ?] then get_symbol ; return obj ; end
        while true
          obj << parse_value
          case get_symbol[0]
          when ?] then return obj
          when ?, then next
          else         raise err_msg(ERR_IllegalSyntax)
          end
        end
      end

    end
  end
end
