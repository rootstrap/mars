# frozen_string_literal: true

RSpec.describe MARS::Gate do
  let(:context) { MARS::Context.new(input: "hello") }

  let(:fallback_step) do
    Class.new(MARS::Step) do
      def run(input, ctx: {})
        MARS::Result.new(value: "fallback: #{input.value}")
      end
    end.new
  end

  let(:error_step) do
    Class.new(MARS::Step) do
      def run(input, ctx: {})
        MARS::Result.new(value: "error: #{input.value}")
      end
    end.new
  end

  describe "#run" do
    context "with constructor-based configuration" do
      it "passes through when check returns falsy" do
        gate = described_class.new(
          "PassGate",
          check: ->(_input, _ctx) {},
          branches: { fail: fallback_step }
        )

        expect(gate.run(MARS::Result.new(value: "hello"), ctx: context)).to eq(MARS::Result.new(value: "hello"))
      end

      it "returns branch result when check returns a key" do
        gate = described_class.new(
          "FailGate",
          check: ->(_input, _ctx) { :fail },
          branches: { fail: fallback_step }
        )

        expect(gate.run(MARS::Result.new(value: "hello"), ctx: context)).to eq(MARS::Result.new(value: "fallback: hello", stopped: true))
      end

      it "raises when check returns an unregistered key" do
        gate = described_class.new(
          "BadGate",
          check: ->(_input, _ctx) { :unknown },
          branches: { fail: fallback_step }
        )

        expect { gate.run(MARS::Result.new(value: "hello"), ctx: context) }.to raise_error(ArgumentError, /No branch registered for :unknown/)
      end

      it "selects among multiple branches" do
        gate = described_class.new(
          "MultiFallback",
          check: ->(input, _ctx) { input.value[:error_type] },
          branches: { timeout: fallback_step, auth: error_step }
        )

        input = MARS::Result.new(value: { error_type: :auth })
        expect(gate.run(input, ctx: context)).to eq(MARS::Result.new(value: "error: #{input.value}", stopped: true))
      end
    end

    context "with class-level DSL" do
      let(:fallback_cls) do
        Class.new(MARS::Step) do
          def run(input, ctx: {})
            MARS::Result.new(value: "handled: #{input.value}")
          end
        end
      end

      it "uses check and fallback DSL" do
        cls = fallback_cls
        gate_class = Class.new(described_class) do
          check { |input, _ctx| :invalid if input.value.length > 5 }
          branch :invalid, cls
        end

        gate = gate_class.new("DSLGate")
        expect(gate.run(MARS::Result.new(value: "hi"), ctx: context)).to eq(MARS::Result.new(value: "hi"))
        expect(gate.run(MARS::Result.new(value: "longstring"), ctx: context)).to eq(MARS::Result.new(value: "handled: longstring", stopped: true))
      end
    end
  end

  describe "inside a workflow" do
    it "stops the current happy path after executing the selected branch" do
      branch = Class.new(MARS::Step) do
        def run(input, ctx: {})
          MARS::Result.new(value: "branched:#{input.value}")
        end
      end.new(name: "branch_step")

      gate = described_class.new(
        "gate",
        check: ->(_input, _ctx) { :branch },
        branches: { branch: branch }
      )

      workflow = MARS::Workflows::Sequential.new(
        "gate_workflow",
        steps: [
          gate,
          Class.new(MARS::Step) do
            def run(input, ctx: {})
              MARS::Result.new(value: "after:#{input.value}")
            end
          end.new(name: "after_step")
        ]
      )

      result = workflow.run("hello")
      expect(result).to be_stopped
      expect(result.value).to eq("branched:hello")
      expect(result.outputs[:gate]).to eq(MARS::Result.new(value: "branched:hello", stopped: true))
      expect(result[:after_step]).to be_nil
    end
  end
end
