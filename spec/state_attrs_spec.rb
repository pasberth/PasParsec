require 'spec_helper'

class TestStateAttrsParser < PasParsec::Parser::PasParser
  STATE_A = 1
  STATE_B = 2
  STATE_C = 3
  add_state_attr :example_state
end

describe TestStateAttrsParser do
  
  subject { described_class.new("aaa bbb ccc") }
  
  example do
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
    subject.send(:input).read.should == "aaa bbb ccc"
  end
end