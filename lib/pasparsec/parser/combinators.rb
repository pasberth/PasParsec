require 'give4each'

require 'pasparsec/parser'

module PasParsec::Parser
  
  class CombinatorBase < Base
    def convert_args *args
      args.map &:build_pasparser!.in(owner)
    end
  end
  
  class Try < CombinatorBase

    def parse a
      try_parsing { return a.call } or ( refresh_states; nil )
    end
  end

  Base.add_parser :try, Try
  
  class Many < CombinatorBase
    def parse a
      [].tap do |collection|
        while e = try(a).call
          collection << e
        end
      end
    end
  end
  
  Base.add_parser :many, Many
  
  class Many1 < CombinatorBase
    def parse a
      collection = many(a).call
      collection.empty? ?
          parsing_fail : collection
    end
  end

  Base.add_parser :many1, Many1

  class Between < CombinatorBase
    def parse open, close, body
      open.call
      ret = body.call
      close.call
      ret
    end
  end

  Base.add_parser :between, Between
  
  class EnumParserBase < Base
    def convert_args enum
      enum = case enum
            when String then enum.enum_for(:each_char)
            when Enumerable then enum
            else
              enum.respond_to?(:each) ?
                  enum.to_enum : raise(TypeError, "Can't convert #{enum.class} into Enumerable")
            end
      [enum]
    end
  end

  class OneOf < EnumParserBase

    def parse enum
      enum.map(&:build_pasparser!.in(owner)).until { |comb| try(comb).call }
    end
  end

  Base.add_parser :one_of, OneOf
end