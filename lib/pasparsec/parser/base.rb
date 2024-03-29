require 'give4each'

require 'pasparsec/parser'

class PasParsec::Parser::Base

  include ::PasParsec::Parser  
  include ::PasParsec::ParserHelper

  def self.to_pasparser
    new
  end
  
  def self.add_parser method, pasparser
    method = method.to_sym
    pasparsers << method
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
  
  def self.pasparsers
    @pasparsers ||= []
    if self != ::PasParsec::Parser::Base
      @pasparsers = superclass.pasparsers | @pasparsers
    else
      @pasparsers
    end
  end
  
  def self.state_attrs
    @state_attrs ||= []
    if self != ::PasParsec::Parser::Base
      @state_attrs = superclass.state_attrs | @state_attrs
    else
      @state_attrs
    end
  end
  
  def pasparsers
    if owner
      self.class.pasparsers | self.owner.pasparsers
    else
      self.class.pasparsers
    end
  end
  
  def state_attrs
    if owner
      self.class.state_attrs | self.owner.state_attrs
    else
      self.class.state_attrs
    end
  end

  add_state_attr :input
  attr_accessor :owner
  protected :owner, :owner=

  def call
    owner.pasparsers.each do |a|
      unless self.class.pasparsers.include? a
        instance_eval(<<-DEFINE)
          def #{a}
            owner.#{a}.bind(self)
          end
        DEFINE
      end
    end

    owner.state_attrs.each do |a|
      val = owner.send(a) and val = val.clone rescue val

      if self.class.state_attrs.include? a
        send(:"original_#{a}=", val)
      else
        instance_eval(<<-DEFINE)
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
        send(:"original_#{a}=", val)
      end
    end

    refresh_states

    try_parsing do
     result = parse(*convert_args(*(@curried_args ||= [])))
     commit_states
     return result
   end or ( refresh_states; throw PARSING_FAIL )
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
  
    def convert_args *args
      args
    end

    def parse *args
      parsing_fail
    end
  
    def try_parsing &block
      catch PARSING_FAIL, &block
    end
  
    def parsing_fail
      throw PARSING_FAIL
    end
    
    def commit_states
      state_attrs.each { |attr| owner.send(:"#{attr}=", send(:"#{attr}")) }
      true
    end
  
    def refresh_states
      state_attrs.each { |attr| send(:"#{attr}=", send(:"original_#{attr}")) }
      true
    end

  protected

    def bind owner
      clone.tap do |bound|
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