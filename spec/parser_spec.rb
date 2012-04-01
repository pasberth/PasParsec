require 'spec_helper'

describe PasParsec::Parser::PasParser do
  subject { described_class.new("aaa bbb ccc") }
  
  describe "block as a combinator" do
    
    example do
      subject.many do
        result = many1(one_of("abc")).call
        many(" ").call
        result.join
      end.call.should == %w[aaa bbb ccc]
      subject.send(:input).read == ""
    end
  end
  
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
  
  describe "#any_char" do
    
    example do
      subject.any_char.call.should == "a"
      subject.send(:input).read == "aa bbb ccc"
    end
  end
  
  describe "#one_of" do
    
    example do
      subject.one_of("abc").call.should == "a"
      subject.send(:input).read == "aa bbb ccc"
    end
    
    example do
      subject.many(subject.one_of("abc")).call.should == %w[a a a]
      subject.send(:input).read == " bbb ccc"
    end
    
    example do
      subject.many(
        subject.one_of([
          subject.many1(subject.one_of("abc")),
          subject.many1(" ")
        ])
      ).call.should == [%w[a a a], [" "], %w[b b b], [" "], %w[c c c]]
    end
  end

  describe "#none_of" do
    
    example do
      subject.none_of(" bc").call.should == "a"
      subject.send(:input).read == "aa bbb ccc"
    end
    
    example do
      subject.many(subject.none_of(" bc")).call.should == %w[a a a]
      subject.send(:input).read == " bbb ccc"
    end
    
    example do
      subject.many(
        subject.one_of([
          subject.many1(subject.none_of(" c")),
          subject.many1(" ")
        ])
      ).call.should == [%w[a a a], [" "], %w[b b b], [" "]]
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
      subject.try { many("b").call }.call.should == []
      subject.send(:input).read == "aaa bbb ccc"
    end

    example do
      subject.try { many1("b").call }.call.should == nil
      subject.send(:input).read == "aaa bbb ccc"
    end
  end
end