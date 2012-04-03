require 'stringio'
require 'pasparsec/parser'

class PasParsec::Parser::PasParser < PasParsec::Parser::Base
  
  def initialize input=nil, &parser
    if input.respond_to? :to_str
      self.input = input
    end
    @parser = parser
  end
  
  def parse *args
    try { instance_exec *args, &@parser }
  end
end