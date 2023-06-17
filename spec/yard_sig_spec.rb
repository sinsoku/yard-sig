# frozen_string_literal: true

RSpec.describe YardSig do
  before { YARD::Registry.clear }

  it "adds param tags and a return tag" do
    YARD.parse_string(<<~RUBY)
      class A
        # @!sig (Integer, Integer) -> String
        def m(a, b)
          "\#{a} + \#{b}"
        end
      end
    RUBY
    obj = YARD::Registry.at("A#m")

    expect(obj.tags).to eq_tags([
      tag(:param, "", ["Integer"], "a"),
      tag(:param, "", ["Integer"], "b"),
      tag(:return, "", ["String"])
    ])
  end

  it "outputs warn with arguments forwarding" do
    allow(log).to receive(:warn)

    YARD.parse_string(<<~RUBY)
      # @!sig () -> void
      def m(...); end
    RUBY

    expect(log).to have_received(:warn).with("arguments forwarding is not supported.")
  end
end
