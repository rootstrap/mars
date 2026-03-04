# frozen_string_literal: true

RSpec.describe MARS::Gate do
  describe "#run" do
    context "with constructor-based configuration" do
      let(:short_step) do
        Class.new(MARS::Runnable) do
          def run(input)
            "short: #{input}"
          end
        end.new
      end

      let(:long_step) do
        Class.new(MARS::Runnable) do
          def run(input)
            "long: #{input}"
          end
        end.new
      end

      let(:gate) do
        described_class.new(
          "LengthGate",
          condition: ->(input) { input.length > 5 ? :long : :short },
          branches: { short: short_step, long: long_step }
        )
      end

      it "returns a Halt wrapping the branch result" do
        result = gate.run("hi")
        expect(result).to be_a(MARS::Halt)
        expect(result.result).to eq("short: hi")
      end

      it "executes the other branch for different input" do
        result = gate.run("longstring")
        expect(result).to be_a(MARS::Halt)
        expect(result.result).to eq("long: longstring")
      end

      it "returns input when no branch matches" do
        gate = described_class.new(
          "NoMatch",
          condition: ->(_input) { :unknown },
          branches: { short: short_step }
        )

        expect(gate.run("hello")).to eq("hello")
      end
    end

    context "with class-level DSL" do
      let(:short_step_class) do
        Class.new(MARS::Runnable) do
          def run(input)
            "quick: #{input}"
          end
        end
      end

      let(:long_step_class) do
        Class.new(MARS::Runnable) do
          def run(input)
            "deep: #{input}"
          end
        end
      end

      it "uses condition and branch DSL" do
        short_cls = short_step_class
        long_cls = long_step_class

        gate_class = Class.new(described_class) do
          condition { |input| input.length < 5 ? :short : :long }
          branch :short, short_cls
          branch :long, long_cls
        end

        gate = gate_class.new("DSLGate")
        expect(gate.run("hi").result).to eq("quick: hi")
        expect(gate.run("longstring").result).to eq("deep: longstring")
      end
    end

    context "with complex condition logic" do
      let(:low_step) do
        Class.new(MARS::Runnable) { def run(input) = "low:#{input}" }.new
      end

      let(:medium_step) do
        Class.new(MARS::Runnable) { def run(input) = "med:#{input}" }.new
      end

      let(:high_step) do
        Class.new(MARS::Runnable) { def run(input) = "high:#{input}" }.new
      end

      let(:gate) do
        described_class.new(
          "SeverityGate",
          condition: lambda { |input|
            case input
            when 0..10 then :low
            when 11..50 then :medium
            else :high
            end
          },
          branches: { low: low_step, medium: medium_step, high: high_step }
        )
      end

      it "routes to low branch" do
        expect(gate.run(5).result).to eq("low:5")
      end

      it "routes to medium branch" do
        expect(gate.run(25).result).to eq("med:25")
      end

      it "routes to high branch" do
        expect(gate.run(100).result).to eq("high:100")
      end
    end
  end
end
