require 'pasparsec/parser'

module PasParsec::Parser
  
  class ::Proc

    def to_pasparser
      ::PasParsec::Parser::ProcParser.new.curry!(self)
    end
  end
  
  class ProcParser < Base

    def parse proc, *args
      instance_exec *args, &proc
    end
  end

  class ::Regexp
  
    def to_pasparser
      ::PasParsec::Parser::RegexpParser.new.curry!(self)
    end
  end
  
  class RegexpParser < Base

    # def parse # Unimplementation
  end

  Base.add_parser :regexp, RegexpParser

  class ::String
  
    def to_pasparser
      ::PasParsec::Parser::StringParser.new.curry!(self)
    end
  end

  class StringParser < Base

    def parse str
      input.read(str.bytes.count).tap do |got|
        parsing_fail if str != got
      end
    end
  end

  Base.add_parser :string, StringParser

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