require "spec_helper"

RSpec.describe Lightning::Invoice do
  it "has a version number" do
    expect(Lightning::Invoice::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
