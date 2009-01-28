class Calc
	class Operator
		def initialize( priority, proc )
			@priority = priority
			@proc = proc
		end
		attr_reader :priority, :proc
	end
	
	class TokenType
		def initialize( regex )
			@regex = regex
			@prev_white_list = []
		end
		
		attr_reader :regex
		attr_accessor :prev_white_list
	end
	
	class Token
		def initialize( type, val = nil )
			@type = type
			@val = val
		end
		attr_reader :type, :val
	end
	
	class Error < StandardError ; end
	
	BINARY_OPERATORS = {
    '==' => Operator.new( 4, proc{|a,b| a==b } ),
		'**' => Operator.new( 4, proc{|a,b| a**b } ),
    '&&' => Operator.new( 2, proc{|a,b| a>0&&b>0 ? 1 : 0 } ),
    '||' => Operator.new( 2, proc{|a,b| a>0||b>0 ? 1 : 0 } ),
		'*' => Operator.new( 2, proc{|a,b| a*b } ),
		'/' => Operator.new( 2, proc{|a,b| a/b } ),
		'%' => Operator.new( 2, proc{|a,b| a%b } ),
		'+' => Operator.new( 1, proc{|a,b| a+b } ),
		'-' => Operator.new( 1, proc{|a,b| a-b } ),
	}
	
	UNARY_OPERATORS = {
		'+' => Operator.new( 5, proc{|a| +a } ),
		'-' => Operator.new( 3, proc{|a| -a } ),
	}
	
	TOKEN_TYPES = [
		TOKEN_TYPE_SPACE = TokenType.new( /\s+/ ),
		TOKEN_TYPE_BINARY_OPERATOR = TokenType.new( Regexp.new( 
			BINARY_OPERATORS.keys.sort_by{|v| -v.size }.map{|v| Regexp.escape(v) }.join( '|' ) ) ),
		TOKEN_TYPE_UNARY_OPERATOR = TokenType.new( Regexp.new( 
			UNARY_OPERATORS.keys.sort_by{|v| -v.size }.map{|v| Regexp.escape(v) }.join( '|' ) ) ),
		TOKEN_TYPE_NUM = TokenType.new( /-?[0-9]+(?:\.[0-9]+)?/ ),
		TOKEN_TYPE_LEFT_BRACKETS = TokenType.new( /\(/ ),
		TOKEN_TYPE_RIGHT_BRACKETS = TokenType.new( /\)/ ),
	]

	[TOKEN_TYPE_NUM, TOKEN_TYPE_UNARY_OPERATOR, TOKEN_TYPE_LEFT_BRACKETS].each do |i|
		i.prev_white_list = 
			[nil, TOKEN_TYPE_LEFT_BRACKETS, TOKEN_TYPE_BINARY_OPERATOR, TOKEN_TYPE_UNARY_OPERATOR]
	end
	
	[TOKEN_TYPE_BINARY_OPERATOR, TOKEN_TYPE_RIGHT_BRACKETS].each do |i|
		i.prev_white_list = 
			[TOKEN_TYPE_NUM, TOKEN_TYPE_RIGHT_BRACKETS]
	end

	def calculate( expr )
		lex( expr )
		return calculate_rpn( ToRpnConverter.new.convert( @tokens ) )
	end
	
	def self.calculate( expr )
		return self.new.calculate( expr )
	end
	
	private
	def lex( expr )
		@tokens = []
		i = 0
		prev_type = nil
		while expr[i]
			find = nil
			TOKEN_TYPES.each do |token_type|
				find = ( /\A#{token_type.regex}/ =~ expr[i..-1] )
				unless token_type == TOKEN_TYPE_SPACE
					find = nil if find && !token_type.prev_white_list.include?( prev_type )
				end
				if find
					case token_type
					when TOKEN_TYPE_BINARY_OPERATOR, TOKEN_TYPE_UNARY_OPERATOR
						@tokens << Token.new( token_type, $& )
					when TOKEN_TYPE_NUM
						@tokens << Token.new( token_type, $&.to_f )
					when TOKEN_TYPE_LEFT_BRACKETS, TOKEN_TYPE_RIGHT_BRACKETS
						@tokens << Token.new( token_type )
					end
					i += find + $&.size
					prev_type = token_type unless token_type == TOKEN_TYPE_SPACE
					break
				end
			end
			raise Error, '構文エラーです' unless find
		end
	end
	
	# 逆ポーランド記法（Reversed Polish Notation）への変換器
	class ToRpnConverter
		def convert( tokens )
			@tokens = tokens
			@rpn_tokens = []
			@rpn_tokens_ptr = 0
			@prev_type = nil
			@rs_stack = []
			@brackets_level = 0
			
			@tokens.each_with_index do |@token,@tokens_i|
				case @token.type
				when TOKEN_TYPE_NUM
					insert_rpn_tokens
					@rpn_tokens_ptr += 1
					if [TOKEN_TYPE_BINARY_OPERATOR, TOKEN_TYPE_UNARY_OPERATOR].include?( @prev_type )
						# 右オペランドの場合
						rop_exit
					end
				when TOKEN_TYPE_BINARY_OPERATOR, TOKEN_TYPE_UNARY_OPERATOR
					insert_rpn_tokens
					@rs_stack.push( @brackets_level )
				when TOKEN_TYPE_LEFT_BRACKETS
					@brackets_level += 1
				when TOKEN_TYPE_RIGHT_BRACKETS
					raise Error, '不正な閉じカッコです' unless @brackets_level > 0
					@brackets_level -= 1
					rop_exit
				else
					raise Error, '不明なトークンです'
				end
				@prev_type = @token.type
				#debug_print
			end
			raise Error, '式が途中で終了しています' unless @rpn_tokens.size == @rpn_tokens_ptr
			raise Error, 'カッコが閉じられていません' unless @brackets_level == 0
			
			return @rpn_tokens
		end
		
		private
		def insert_rpn_tokens
			@rpn_tokens.insert( @rpn_tokens_ptr, @token )
		end
		
		def debug_print
			@rpn_tokens.each_with_index do |t,i|
				print ' ' if i != 0
				print '| ' if i == @rpn_tokens_ptr
				print t.val
				if t.type == TOKEN_TYPE_UNARY_OPERATOR
					print '@'
				end
			end
			print ' |' if @rpn_tokens.size == @rpn_tokens_ptr
			print "\n"
		end
		
		# 右オペランド（Right OPerand）の終了を確認し、処理する
		def rop_exit
			while rop_end?
				@rs_stack.pop
				@rpn_tokens_ptr += 1
			end
		end
		
		# 右オペランドは終了している？
		def rop_end?
			return false unless @rs_stack.last == @brackets_level
			next_token = @tokens[@tokens_i+1]
			token = @rpn_tokens[@rpn_tokens_ptr]
			return true unless next_token && token
			return true unless [next_token, token].all? {|v| 
				[TOKEN_TYPE_BINARY_OPERATOR, TOKEN_TYPE_UNARY_OPERATOR].include?( v.type ) }
			# next_token の priority の方が高ければ false
			return proc{|v| v[0] <= v[1] }.call( [next_token, token].map{|v| 
				( ( v.type == TOKEN_TYPE_BINARY_OPERATOR ) ?
					BINARY_OPERATORS : UNARY_OPERATORS )[v.val].priority } )
		end
	end
	
	def calculate_rpn( rpn_tokens )
		stack = []
		rpn_tokens.each do |token|
			case token.type
			when TOKEN_TYPE_NUM
				stack.push token.val
			when TOKEN_TYPE_BINARY_OPERATOR
				raise Error, 'オペランドが足りません' unless stack.size >= 2
				b = stack.pop
				a = stack.pop
				raise Error, '不明な演算子です' unless BINARY_OPERATORS.key?( token.val )
				stack.push BINARY_OPERATORS[token.val].proc.call( a, b )
			when TOKEN_TYPE_UNARY_OPERATOR
				raise Error, 'オペランドが足りません' unless stack.size >= 1
				a = stack.pop
				raise Error, '不明な演算子です' unless UNARY_OPERATORS.key?( token.val )
				stack.push UNARY_OPERATORS[token.val].proc.call( a )
			else 
				raise Error, '不明なトークンです'
			end
		end

		raise Error, 'オペランドが足りないか、余っています' unless stack.size == 1
		return stack[0]
	end
end


class String
  def int?
    return self == self.to_i.to_s
  end
end

v = [1, 4, 0, 4, 55]
s = [0, 0, 0]

def get_value(v, val)
  return val.to_i if val.int?
  idx = 0

  st = 0
  en = 0
  if val[idx, 1] == "$"
    idx += 1
    if val[idx, 1] == 'v'
      idx += 1
      st = idx
      count = 0
      while true
        raise('no ] found') unless val[idx, 1]
        count += 1 if val[idx, 1] == '['
        if val[idx, 1] == ']'
          count -= 1
          if count == 0
            en = idx
            return v[get_value(v, val [(st+1)..(en-1)])]
          end
        end
        idx += 1
      end
    end
  end
  raise('incorrect')
end
"$v[$v[$v[0]]] + $v[$v[0]]"
p get_value(v, "$v[$v[$v[0]]]")

#puts Calc.calculate('1&&1')
