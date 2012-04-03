require 'spec_helper'

class TestStateAttrsParser < PasParsec::Parser::PasParser
  STATE_A = 1
  STATE_B = 2
  STATE_C = 3
  add_state_attr :example_state
end

describe TestStateAttrsParser do
  
  subject { described_class.new("aaa bbb ccc") }
  
  example "substitution" do
    subject.send :example_state=, TestStateAttrsParser::STATE_A
    subject.send(:example_state).should == TestStateAttrsParser::STATE_A
    subject.try do
      self.example_state = TestStateAttrsParser::STATE_B
      self.example_state.should == TestStateAttrsParser::STATE_B
      try do
        self.example_state = TestStateAttrsParser::STATE_C
        self.example_state.should == TestStateAttrsParser::STATE_C
        string("c").call # This should throw PARSING_FAIL
      end.call
      self.example_state.should == TestStateAttrsParser::STATE_B
      string("b").call # This should throw PARSING_FAIL
    end.call
    subject.send(:example_state).should == TestStateAttrsParser::STATE_A
    subject.send(:input).should == "aaa bbb ccc"
  end

  example "destructive changing" do
    subject.send :example_state=, [1]
    subject.send(:example_state).should == [1]
    subject.try do
      self.example_state << 2
      self.example_state.should == [1, 2]
      try do
        self.example_state << 3
        self.example_state.should == [1, 2, 3]
        string("c").call # This should throw PARSING_FAIL
      end.call
      self.example_state.should == [1, 2]
      string("b").call # This should throw PARSING_FAIL
    end.call
    subject.send(:example_state).should == [1]
    subject.send(:input).should == "aaa bbb ccc"
  end
end