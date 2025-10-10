# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Exit
        include Base

        def to_mermaid(from = 'In(("In")) -->', to = 'Out(("Out"))')
          ["#{from} exit((#{name}))"]
        end
      end
    end
  end
end
