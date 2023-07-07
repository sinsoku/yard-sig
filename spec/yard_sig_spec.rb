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

  it "does not cause errors within sord processing" do
    YARD.parse_string(<<~RUBY)
      # @!sig (Integer) -> void
      def m(a); end
    RUBY
    obj = YARD::Registry.at("#m")

    # refs: https://github.com/AaronC81/sord/blob/6.0.0/lib/sord/generator.rb#L174-L177
    parser = YARD::Docstring.parser
    parser.parse(obj.docstring.all)
    docs_array = parser.text.split("\n")

    expect(docs_array).to eq([])
  end
end
