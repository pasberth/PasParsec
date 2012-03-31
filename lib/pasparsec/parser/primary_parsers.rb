require 'pasparsec/parser'

module PasParsec::Parser
  
  class ::Proc

    def to_pasparser
      ::PasParsec::Parser::ProcParser.new(self)
    end
  end
  
  class ProcParser < Base

    def initialize proc
      @proc = proc
    end
    
    def parse *args
      @proc.call *args
    end
  end

  class Base
    def regexp re
      re.to_pasparser.bind(self)
    end
  end

  class ::Regexp
  
    def to_pasparser
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

  class Base

    def one_of enum
      ::PasParsec::Parser::OneOf.new(enum).bind(self)
    end
  end

  class OneOf < Base

    def initialize enum
      @enum = case enum
              when String then enum.enum_for(:each_char)
              when Enumerable then enum
              else enum # raise TypeError, "Can't convert #{enum.class} into Enumerable"
              end
    end

    def parse
      @enum.map(&:build_pasparser!.in(owner)).until { |comb| try { comb.call } }
    end
  end
end
