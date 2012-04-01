require 'give4each'

require 'pasparsec/parser'

module PasParsec::Parser
  
  class Try < Base

    def parse a
      try_parsing { return owner.build_pasparser!(a).call } or ( refresh_states; nil )
    end
  end

  Base.add_parser :try, Try
  
  class Many < Base
    def parse a
      [].tap do |collection|
        while e = try(a).call
          collection << e
        end
      end
    end
  end
  
  Base.add_parser :many, Many
  
  class Many1 < Base
    def parse a
      collection = many(a).call
      collection.empty? ?
          parsing_fail : collection
    end
  end

  Base.add_parser :many1, Many1

  class Between < Base
    def parse open, close, body
      open, close, body = [open, close, body].map &:build_pasparser!.in(owner)
      open.call
      ret = body.call
      close.call
      ret
    end
  end

  Base.add_parser :between, Between

  class OneOf < Base

    def parse enum
      enum = case enum
            when String then enum.enum_for(:each_char)
            when Enumerable then enum
            else
              enum.respond_to?(:each) ?
                  enum.to_enum : raise(TypeError, "Can't convert #{enum.class} into Enumerable")
            end
      enum.map(&:build_pasparser!.in(owner)).until { |comb| try(comb).call }
    end

    Base.add_parser :one_of, OneOf
  end
end