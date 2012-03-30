require 'spec_helper'

describe PasParsec::Parser::PasParser do
  subject { described_class.new("aaa bbb ccc") }
  
  describe "#string" do
    
    example do
      subject.string("aaa").call.should == "aaa"
      subject.send(:input).read == " bbb ccc"
    end
    
    example do
      expect { subject.string("bbb").call }.should throw_symbol ::PasParsec::Parser::PARSING_FAIL
      subject.send(:input).read == "aaa bbb ccc"
    end
  end
  
  describe "#many" do
  
    example do
      subject.many("a").call.should == %w[a a a]
      subject.send(:input).read == " bbb ccc"
    end

    example do
      subject.many("b").call.should == []
      subject.send(:input).read == "aaa bbb ccc"
    end
  end
  
  describe "#many1" do
    example do
      subject.many1("a").call.should == %w[a a a]
      subject.send(:input).read == " bbb ccc"
    end

    example do
      expect { subject.many1("b").call }.should throw_symbol ::PasParsec::Parser::PARSING_FAIL
      subject.send(:input).read == "aaa bbb ccc"
    end
  end
  
  describe "#between" do
    
    subject { described_class.new('"aaa" "bbb" "ccc"') }
    
    example do
      subject.between('"', '"', subject.many("a")).call.should == %w[a a a]
      subject.send(:input).read == ' "bbb" "ccc"'
    end
  end
  
  describe "#try" do
  
    example do
      subject.try { many("b").call }.should == []
      subject.send(:input).read == "aaa bbb ccc"
    end

    example do
      subject.try { many1("b").call }.should == nil
      subject.send(:input).read == "aaa bbb ccc"
    end
  end
end
