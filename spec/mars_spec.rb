# frozen_string_literal: true

RSpec.describe Mars do
  it "has a version number" do
    expect(Mars::VERSION).not_to be_nil
  end
end
