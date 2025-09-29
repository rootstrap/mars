# frozen_string_literal: true

RSpec.describe Mars::Runnable do
  describe "#run" do
    context "when called directly on the base class" do
      let(:runnable) { described_class.new }

      it "raises NotImplementedError" do
        expect { runnable.run("any input") }.to raise_error(NotImplementedError)
      end
    end

    context "when implemented in a subclass" do
      let(:test_runnable_class) do
        Class.new(Mars::Runnable) do
          def run(input)
            "processed: #{input}"
          end
        end
      end

      let(:runnable) { test_runnable_class.new }

      it "can be successfully overridden" do
        result = runnable.run("test input")
        expect(result).to eq("processed: test input")
      end
    end

    context "when subclass doesn't override run method" do
      let(:incomplete_runnable_class) do
        Class.new(Mars::Runnable) do
          # Intentionally not overriding run method
        end
      end

      let(:runnable) { incomplete_runnable_class.new }

      it "still raises NotImplementedError" do
        expect { runnable.run("input") }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "inheritance" do
    it "can be inherited" do
      subclass = Class.new(described_class)
      expect(subclass.ancestors).to include(described_class)
    end
  end
end
