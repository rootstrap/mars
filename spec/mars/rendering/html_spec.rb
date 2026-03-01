# frozen_string_literal: true

require "tmpdir"

RSpec.describe MARS::Rendering::Html do
  let(:step_class) do
    Class.new(MARS::Runnable) do
      def run(input)
        input
      end
    end
  end

  let(:workflow) do
    step_a = step_class.new(name: "step_a")
    step_b = step_class.new(name: "step_b")
    MARS::Workflows::Sequential.new("TestPipeline", steps: [step_a, step_b])
  end

  describe "#render" do
    it "returns a self-contained HTML string" do
      html = described_class.new(workflow).render

      expect(html).to include("<!DOCTYPE html>")
      expect(html).to include("beautiful-mermaid")
      expect(html).to include("renderMermaidSVG")
      expect(html).to include("TestPipeline")
      expect(html).to include("flowchart LR")
    end

    it "accepts a custom direction" do
      html = described_class.new(workflow).render(direction: "TD")

      expect(html).to include("flowchart TD")
    end

    it "accepts a custom title" do
      html = described_class.new(workflow).render(title: "My Workflow")

      expect(html).to include("<title>My Workflow</title>")
    end

    it "accepts theme options" do
      html = described_class.new(workflow).render(theme: { bg: "#1a1b26", fg: "#a9b1d6" })

      expect(html).to include("bg: '#1a1b26'")
      expect(html).to include("fg: '#a9b1d6'")
    end

    it "escapes HTML in the title" do
      html = described_class.new(workflow).render(title: "<script>alert('xss')</script>")

      expect(html).not_to include("<script>alert")
      expect(html).to include("&lt;script&gt;")
    end
  end

  describe "#write" do
    it "writes the HTML to a file" do
      path = File.join(Dir.tmpdir, "mars_test_#{SecureRandom.hex(4)}.html")

      begin
        described_class.new(workflow).write(path)

        content = File.read(path)
        expect(content).to include("<!DOCTYPE html>")
        expect(content).to include("beautiful-mermaid")
      ensure
        FileUtils.rm_f(path)
      end
    end
  end
end
