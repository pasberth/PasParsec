require 'give4each'

require 'pasparsec/parser'

class PasParsec::Parser::Base

  include ::PasParsec::Parser  
  include ::PasParsec::ParserHelper

  def self.to_pasparser
    new
  end
  
  def self.add_parser method, pasparser
    define_method method do |*args, &block|
      build_pasparser!(pasparser).curry(*args, &block)
    end
  end
  
  def self.add_state_attr attr, options={}
    attr = attr.to_sym
    state_attrs << attr
    varname = :"@#{attr}"
    getter = :"#{attr}"
    setter = :"#{attr}="
    
    case options[:getter]
    when String
      class_eval(<<-DEFINE)
        def #{getter}
          #{options[:getter]}
        end
      DEFINE
    when Proc
      define_method getter do |val|
        instance_exec val, &options[:getter]
      end
    else
      class_eval(<<-DEFINE)
        def #{getter}
          #{varname}
        end
      DEFINE
    end

    case options[:setter]
    when String
      class_eval(<<-DEFINE)
        def #{setter} val
          #{options[:setter]}
        end
      DEFINE
    when Proc
      define_method setter do |val|
        instance_exec val, &options[:setter]
      end
    else
      class_eval(<<-DEFINE)
        def #{setter} val
          #{varname} = val
        end
      DEFINE
    end
    
    class_eval(<<-ORIGINAL)
      def original_#{getter}
        @_original_#{attr}
      end

      def original_#{setter} val
        @_original_#{attr} = val
      end
    ORIGINAL
    
    protected getter, setter
    private :"original_#{getter}", :"original_#{setter}"
    true
  end
  
  def self.state_attrs
    @state_attrs ||= []
    if self != ::PasParsec::Parser::Base
      @state_attrs = superclass.state_attrs | @state_attrs
    else
      @state_attrs
    end
  end
  
  def state_attrs
    if owner
      self.class.state_attrs | self.owner.state_attrs
    else
      self.class.state_attrs
    end
  end

  add_state_attr :pos,
                 :getter => "input.pos",
                 :setter => "input.seek val"

  attr_accessor :input, :owner
  protected :input, :input=, :owner, :owner=

  def call
    try_parsing { return parse *(@curried_args ||= []) } or ( refresh_states; throw PARSING_FAIL )
  end
  
  def curry *args, &proc_as_combinator
    clone.curry! *args, &proc_as_combinator
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
      state_attrs.each { |attr| send(:"#{attr}=", send(:"original_#{attr}")) }
      true
    end

  protected

    def bind owner
      clone.tap do |bound|
        bound.input = owner.input
        bound.owner = owner
        owner.state_attrs.each do |a|
          val = owner.send(a) and val = val.clone rescue val

          if self.class.state_attrs.include? a
            bound.send(:"original_#{a}=", val)
          else
            bound.instance_eval(<<-DEFINE)
              def #{a}= val
                owner.send :'#{a}=', val
              end

              def #{a}
                owner.send :'#{a}'
              end

              def original_#{a}= val
                @_original_#{a} = val
              end

              def original_#{a}
                @_original_#{a}
              end
            DEFINE
            bound.send(:"original_#{a}=", val)
          end
        end
        bound.send :refresh_states
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