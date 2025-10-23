# frozen_string_literal: true

RSpec.describe Mars::Gate do
  describe "#initialize" do
    let(:condition) { ->(input) { input > 5 } }
    let(:branches) { { true => Mars::Exit.new, false => Mars::Exit.new } }

    it "initializes with required parameters" do
      gate = described_class.new(name: "TestGate", condition: condition, branches: branches)
      expect(gate.name).to eq("TestGate")
    end

    it "requires a name parameter" do
      expect {
        described_class.new(condition: condition, branches: branches)
      }.to raise_error(ArgumentError)
    end

    it "requires a condition parameter" do
      expect {
        described_class.new(name: "TestGate", branches: branches)
      }.to raise_error(ArgumentError)
    end

    it "requires a branches parameter" do
      expect {
        described_class.new(name: "TestGate", condition: condition)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#name" do
    let(:condition) { ->(input) { input > 5 } }
    let(:branches) { { true => Mars::Exit.new } }

    it "returns the gate name" do
      gate = described_class.new(name: "MyGate", condition: condition, branches: branches)
      expect(gate.name).to eq("MyGate")
    end
  end

  describe "#run" do
    context "with simple boolean condition" do
      let(:condition) { ->(input) { input > 5 } }
      let(:true_branch) { instance_double(Mars::Runnable) }
      let(:false_branch) { instance_double(Mars::Runnable) }
      let(:branches) { { true => true_branch, false => false_branch } }
      let(:gate) { described_class.new(name: "TestGate", condition: condition, branches: branches) }

      it "executes true branch when condition is true" do
        expect(true_branch).to receive(:run).with(10).and_return("true result")
        result = gate.run(10)
        expect(result).to eq("true result")
      end

      it "executes false branch when condition is false" do
        expect(false_branch).to receive(:run).with(3).and_return("false result")
        result = gate.run(3)
        expect(result).to eq("false result")
      end
    end

    context "with string-based condition" do
      let(:condition) { ->(input) { input.length > 5 ? "long" : "short" } }
      let(:long_branch) { instance_double(Mars::Runnable) }
      let(:short_branch) { instance_double(Mars::Runnable) }
      let(:branches) { { "long" => long_branch, "short" => short_branch } }
      let(:gate) { described_class.new(name: "LengthGate", condition: condition, branches: branches) }

      it "routes to correct branch based on string result" do
        expect(long_branch).to receive(:run).with("longstring").and_return("long result")
        result = gate.run("longstring")
        expect(result).to eq("long result")
      end

      it "routes to short branch for short strings" do
        expect(short_branch).to receive(:run).with("hi").and_return("short result")
        result = gate.run("hi")
        expect(result).to eq("short result")
      end
    end

    context "with default exit behavior" do
      let(:condition) { ->(input) { input > 5 ? "high" : "low" } }
      let(:high_branch) { instance_double(Mars::Runnable) }
      let(:branches) { { "high" => high_branch } }
      let(:gate) { described_class.new(name: "TestGate", condition: condition, branches: branches) }

      it "uses default Exit node for undefined branches" do
        expect(high_branch).to receive(:run).with(10).and_return("high result")
        result = gate.run(10)
        expect(result).to eq("high result")
      end

      it "returns input unchanged when branch is not defined" do
        # For input 3, condition returns "low" which is not in branches
        # Should use default Exit node which returns input unchanged
        result = gate.run(3)
        expect(result).to eq(3)
      end
    end

    context "with complex condition logic" do
      let(:condition) do
        lambda do |input|
          case input
          when 0..10 then "low"
          when 11..50 then "medium"
          else "high"
          end
        end
      end

      let(:low_branch) { instance_double(Mars::Runnable) }
      let(:medium_branch) { instance_double(Mars::Runnable) }
      let(:high_branch) { instance_double(Mars::Runnable) }
      let(:branches) { { "low" => low_branch, "medium" => medium_branch, "high" => high_branch } }
      let(:gate) { described_class.new(name: "RangeGate", condition: condition, branches: branches) }

      it "routes to low branch" do
        expect(low_branch).to receive(:run).with(5).and_return("low result")
        result = gate.run(5)
        expect(result).to eq("low result")
      end

      it "routes to medium branch" do
        expect(medium_branch).to receive(:run).with(25).and_return("medium result")
        result = gate.run(25)
        expect(result).to eq("medium result")
      end

      it "routes to high branch" do
        expect(high_branch).to receive(:run).with(100).and_return("high result")
        result = gate.run(100)
        expect(result).to eq("high result")
      end
    end

    context "with nested runnable execution" do
      let(:condition) { ->(input) { input[:type] } }
      let(:exit_node) { Mars::Exit.new(name: "TestExit") }
      let(:branches) { { "passthrough" => exit_node } }
      let(:gate) { described_class.new(name: "TestGate", condition: condition, branches: branches) }

      it "passes input through Exit node" do
        input = { type: "passthrough", data: "test" }
        result = gate.run(input)
        expect(result).to eq(input)
      end
    end
  end

  describe "inheritance" do
    it "inherits from Mars::Runnable" do
      expect(described_class.ancestors).to include(Mars::Runnable)
    end
  end
end
