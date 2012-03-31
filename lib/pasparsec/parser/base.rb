require 'give4each'

require 'pasparsec/parser'

class PasParsec::Parser::Base

  include ::PasParsec::Parser  
  include ::PasParsec::ParserHelper

  def self.to_pasparser
    new
  end
  
  def self.add_parser method, klass
    define_method method do |*args, &block|
      build_pasparser!(klass).curry!(*args, &block)
    end
  end

  attr_accessor :pos, :input, :owner
  protected :pos, :pos=, :input, :input=, :owner, :owner=

  def call
    try_parsing { return parse *(@curried_args ||= []) } or ( refresh_states; throw PARSING_FAIL )
  end
  
  def curry *combinators, &proc_as_combinator
    close.curry! *combinators, &proc_as_combinator
  end
  
  def curry! *args, &proc_as_combinator
    @curried_args ||= []
    args.each &:push.to(@curried_args)
    proc_as_combinator and @curried_args << owner.build_pasparser!(proc_as_combinator)
    self
  end
  
  private

    def parse *combinators
      parsing_fail
    end
  
    def try_parsing &block
      catch PARSING_FAIL, &block
    end
  
    def parsing_fail
      throw PARSING_FAIL
    end
  
    def refresh_states
      @input.seek(@pos)
    end


  protected

    def bind owner
      clone.tap do |bound|
        bound.pos = owner.input.pos
        bound.input = owner.input
        bound.owner = owner
      end
    end
  
    def build_pasparser! combinator
      try_convert_into_pasparser!(combinator).bind(self)
    end


  public

    def to_proc
      proc { |*a, &b| curry(*a, &b).call }
    end
  
    def to_pasparser
      self
    end
end