module Fabrication
  module Schematic
    class Runner
      attr_accessor :klass

      def initialize(klass)
        self.klass = klass
      end

      def sequence(name = Fabrication::Sequencer::DEFAULT, start = nil, &)
        name = "#{klass.to_s.downcase.gsub('::', '_')}_#{name}"
        Fabrication::Sequencer.sequence(name, start, &)
      end
    end
  end
end
