require 'pasparsec/parser'

module PasParsec::Parser
  
  class Try < Base
    def parse a
      try_parsing { return a.call } or ( @input.seek(@pos); nil )
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
      collection = [].tap do |collection|
        while e = try(a).call
          collection << e
        end
      end

      collection.empty? ?
          parsing_fail : collection
    end
  end

  Base.add_parser :many1, Many1

  class Between < Base
    def parse open, close, body
      open.call
      ret = body.call
      close.call
      ret
    end
  end

  Base.add_parser :between, Between
end