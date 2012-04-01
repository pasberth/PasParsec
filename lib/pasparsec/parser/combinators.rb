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
end