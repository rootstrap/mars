# frozen_string_literal: true

RSpec.describe Mars::Gate do
  describe "#run" do
    context "with simple boolean condition" do
      let(:condition) { ->(input) { input > 5 } }
      let(:true_branch) { instance_spy(Mars::Runnable) }
      let(:false_branch) { instance_spy(Mars::Runnable) }
      let(:branches) { { true => true_branch, false => false_branch } }
      let(:gate) { described_class.new(name: "TestGate", condition: condition, branches: branches) }

      it "executes true branch when condition is true" do
        allow(true_branch).to receive(:run).with(10).and_return("true result")

        result = gate.run(10)

        expect(result).to eq("true result")
        expect(true_branch).to have_received(:run).with(10)
      end

      it "executes false branch when condition is false" do
        allow(false_branch).to receive(:run).with(3).and_return("false result")

        result = gate.run(3)

        expect(result).to eq("false result")
        expect(false_branch).to have_received(:run).with(3)
      end
    end

    context "with string-based condition" do
      let(:condition) { ->(input) { input.length > 5 ? "long" : "short" } }
      let(:long_branch) { instance_spy(Mars::Runnable) }
      let(:short_branch) { instance_spy(Mars::Runnable) }
      let(:branches) { { "long" => long_branch, "short" => short_branch } }
      let(:gate) { described_class.new(name: "LengthGate", condition: condition, branches: branches) }

      it "routes to correct branch based on string result" do
        allow(long_branch).to receive(:run).with("longstring").and_return("long result")

        result = gate.run("longstring")

        expect(result).to eq("long result")
        expect(long_branch).to have_received(:run).with("longstring")
      end

      it "routes to short branch for short strings" do
        allow(short_branch).to receive(:run).with("hi").and_return("short result")

        result = gate.run("hi")

        expect(result).to eq("short result")
        expect(short_branch).to have_received(:run).with("hi")
      end
    end

    context "with missing branch" do
      let(:condition) { ->(input) { input > 5 ? "high" : "low" } }
      let(:high_branch) { instance_spy(Mars::Runnable) }
      let(:branches) { { "high" => high_branch } }
      let(:gate) { described_class.new(name: "TestGate", condition: condition, branches: branches) }

      it "executes defined branch when condition matches" do
        allow(high_branch).to receive(:run).with(10).and_return("high result")

        result = gate.run(10)

        expect(result).to eq("high result")
        expect(high_branch).to have_received(:run).with(10)
      end

      it "raises an error when branch is not defined" do
        # For input 3, condition returns "low" which is not in branches
        expect { gate.run(3) }.to raise_error(NoMethodError)
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

      let(:low_branch) { instance_spy(Mars::Runnable) }
      let(:medium_branch) { instance_spy(Mars::Runnable) }
      let(:high_branch) { instance_spy(Mars::Runnable) }
      let(:branches) { { "low" => low_branch, "medium" => medium_branch, "high" => high_branch } }

      it "routes to low branch" do
        gate = described_class.new(name: "RangeGate", condition: condition, branches: branches)
        allow(low_branch).to receive(:run).with(5).and_return("low result")

        result = gate.run(5)

        expect(result).to eq("low result")
        expect(low_branch).to have_received(:run).with(5)
      end

      it "routes to medium branch" do
        gate = described_class.new(name: "RangeGate", condition: condition, branches: branches)
        allow(medium_branch).to receive(:run).with(25).and_return("medium result")

        result = gate.run(25)

        expect(result).to eq("medium result")
        expect(medium_branch).to have_received(:run).with(25)
      end

      it "routes to high branch" do
        gate = described_class.new(name: "RangeGate", condition: condition, branches: branches)
        allow(high_branch).to receive(:run).with(100).and_return("high result")

        result = gate.run(100)

        expect(result).to eq("high result")
        expect(high_branch).to have_received(:run).with(100)
      end
    end
  end
end
