# frozen_string_literal: true

RSpec.describe MARS::Gate do
  let(:fallback_step) do
    Class.new(MARS::Runnable) do
      def run(input)
        "fallback: #{input}"
      end
    end.new
  end

  let(:error_step) do
    Class.new(MARS::Runnable) do
      def run(input)
        "error: #{input}"
      end
    end.new
  end

  describe "#run" do
    context "with constructor-based configuration" do
      it "passes through when check returns falsy" do
        gate = described_class.new(
          "PassGate",
          check: ->(_input) {},
          fallbacks: { fail: fallback_step }
        )

        expect(gate.run("hello")).to eq("hello")
      end

      it "halts with fallback result when check returns a key" do
        gate = described_class.new(
          "FailGate",
          check: ->(_input) { :fail },
          fallbacks: { fail: fallback_step }
        )

        result = gate.run("hello")
        expect(result).to be_a(MARS::Halt)
        expect(result.result).to eq("fallback: hello")
      end

      it "raises when check returns an unregistered key" do
        gate = described_class.new(
          "BadGate",
          check: ->(_input) { :unknown },
          fallbacks: { fail: fallback_step }
        )

        expect { gate.run("hello") }.to raise_error(ArgumentError, /No fallback registered for :unknown/)
      end

      it "selects among multiple fallbacks" do
        gate = described_class.new(
          "MultiFallback",
          check: ->(input) { input[:error_type] },
          fallbacks: { timeout: fallback_step, auth: error_step }
        )

        input = { error_type: :auth }
        result = gate.run(input)
        expect(result).to be_a(MARS::Halt)
        expect(result.result).to eq("error: #{input}")
      end
    end

    context "with class-level DSL" do
      let(:fallback_cls) do
        Class.new(MARS::Runnable) do
          def run(input)
            "handled: #{input}"
          end
        end
      end

      it "uses check and fallback DSL" do
        cls = fallback_cls
        gate_class = Class.new(described_class) do
          check { |input| :invalid if input.length > 5 }
          fallback :invalid, cls
        end

        gate = gate_class.new("DSLGate")
        expect(gate.run("hi")).to eq("hi")
        expect(gate.run("longstring").result).to eq("handled: longstring")
      end

      it "supports halt_scope DSL" do
        cls = fallback_cls
        gate_class = Class.new(described_class) do
          check { |_input| :fail }
          fallback :fail, cls
          halt_scope :global
        end

        result = gate_class.new("GlobalGate").run("test")
        expect(result).to be_a(MARS::Halt)
        expect(result).to be_global
      end
    end

    context "with halt scope" do
      it "defaults to local scope" do
        gate = described_class.new(
          "LocalGate",
          check: ->(_input) { :fail },
          fallbacks: { fail: fallback_step }
        )

        result = gate.run("hello")
        expect(result).to be_local
      end

      it "respects constructor halt_scope" do
        gate = described_class.new(
          "GlobalGate",
          check: ->(_input) { :fail },
          fallbacks: { fail: fallback_step },
          halt_scope: :global
        )

        result = gate.run("hello")
        expect(result).to be_global
      end
    end
  end
end
