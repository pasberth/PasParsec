require 'give4each'

require 'pasparsec/parser'

class PasParsec::Parser::Base

  include ::PasParsec::Parser  
  include ::PasParsec::ParserHelper

  def self.to_pasparser
    new
  end
  
  attr_accessor :pos, :input, :owner
  protected :pos, :pos=, :input, :input=, :owner, :owner=
  
  def input
    if !@input and @owner
      owner.input
    elsif @input
      @input
    end
  end
  
  def call
    parse *(@curried_args ||= [])
  end
  
  def curry *combinators, &proc_as_combinator
    close.curry! *combinators, &proc_as_combinator
  end
  
  def curry! *combinators, &proc_as_combinator
    @curried_args ||= []
    combinators.map(&:build_pasparser!.in(owner)).each(&:push.to(@curried_args))
    proc_as_combinator and @curried_args << build_pasparser!(proc_as_combinator)
    self
  end

  def parse *combinators
    parsing_fail
  end
  
  def try &block
    pos = @input.pos
    try_parsing { instance_exec &block } or ( @input.seek(pos); nil )
  end
  
  def try_parsing &block
    catch PARSING_FAIL, &block
  end
  
  def parsing_fail
    throw PARSING_FAIL
  end

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
    
  def self.add_parser method, klass
    define_method method do |*args, &block|
      klass.new.bind(self).curry!(*args, &block)
    end
  end

  def to_proc
    proc { |*a, &b| call *a, &b }
  end
  
  def to_pasparser
    self
  end
end