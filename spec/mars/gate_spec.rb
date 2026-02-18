# frozen_string_literal: true

RSpec.describe Mars::Gate do
  describe "#run" do
    let(:gate) { described_class.new("TestGate", condition: condition, branches: branches) }

    context "with simple boolean condition" do
      let(:condition) { ->(input) { input > 5 } }
      let(:false_branch) { instance_spy(Mars::Runnable) }
      let(:branches) { { false => false_branch } }

      it "returns the input when no branch matches" do
        result = gate.run(10)
        expect(result).to eq(10)
      end

      it "returns the false branch when condition is false" do
        result = gate.run(3)

        expect(result).to eq(false_branch)
      end

      it "does not run the false branch when condition is false" do
        gate.run(3)

        expect(false_branch).not_to have_received(:run)
      end
    end

    context "with string-based condition" do
      let(:condition) { ->(input) { input.length > 5 ? "long" : "short" } }
      let(:long_branch) { instance_spy(Mars::Runnable) }
      let(:short_branch) { instance_spy(Mars::Runnable) }
      let(:branches) { { "long" => long_branch, "short" => short_branch } }

      it "routes to long branch for long strings" do
        result = gate.run("longstring")

        expect(result).to eq(long_branch)
      end

      it "routes to short branch for short strings" do
        result = gate.run("hi")

        expect(result).to eq(short_branch)
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
        result = gate.run(5)

        expect(result).to eq(low_branch)
      end

      it "routes to medium branch" do
        result = gate.run(25)

        expect(result).to eq(medium_branch)
      end

      it "routes to high branch" do
        result = gate.run(100)

        expect(result).to eq(high_branch)
      end
    end
  end
end
