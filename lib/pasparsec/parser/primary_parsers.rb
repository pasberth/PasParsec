require 'pasparsec/parser'

module PasParsec::Parser
  
  class Base
    def regexp re
      re.to_pasparser.bind(self)
    end
  end

  class ::Regexp
  
    def to_pasparser *args, &block
      ::PasParsec::Parser::RegexpParser.new(self)
    end
  end
  
  class RegexpParser < Base

    def initialize regexp
      @regexp = regexp
    end

    def parse
    end
  end

  class Base
    def string str
      str.to_pasparser.bind(self)
    end
  end

  class ::String
  
    def to_pasparser
      ::PasParsec::Parser::StringParser.new(self)
    end
  end

  class StringParser < Base
    def initialize string
      @string = string
    end

    def parse
      input.read(@string.bytes.count).tap do |got|
        parsing_fail if @string != got
      end
    end
  end
end
