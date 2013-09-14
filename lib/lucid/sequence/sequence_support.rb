require 'lucid/sequence/sequence_group'
require 'lucid/sequence/sequence_errors'

module Sequence
  module SequenceSupport
    
    def add_sequence(phrase, sequence, data)
      SequenceGroup.instance.add_sequence(phrase, sequence, data)
    end
    
    def invoke_sequence(phrase, data = nil)
      group = SequenceGroup.instance()
      generated_steps = group.generate_steps(phrase, data)
    end
    
  end
end