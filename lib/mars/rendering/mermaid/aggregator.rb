# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Aggregator
        include Base

        # TODO
        def to_mermaid
          raise NotImplementedError
        end

        def can_end_workflow?
          true
        end
      end
    end
  end
end
