# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Exit
        include Base

        def to_mermaid
          "exit((#{name}))"
        end
      end
    end
  end
end
