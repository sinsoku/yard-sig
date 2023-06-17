# frozen_string_literal: true

RSpec.describe YardSig::Sig do
  describe "#to_tags" do
    it "returns a param tag" do
      sig = described_class.new("(Integer a) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Integer"], "a")
      ])
    end

    it "returns a param tag for optional" do
      sig = described_class.new("(?Integer a) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Integer"], "a")
      ])
    end

    it "returns a return tag" do
      sig = described_class.new("() -> Integer")
      expect(sig.to_tags).to eq_tags([
        tag(:return, "", ["Integer"])
      ])
    end

    it "returns param tags and a return tag" do
      sig = described_class.new("(Symbol a, String b) -> Integer")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Symbol"], "a"),
        tag(:param, "", ["String"], "b"),
        tag(:return, "", ["Integer"])
      ])
    end

    it "returns a param tag for the rest parameter" do
      sig = described_class.new("(*Integer args) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Array<Integer>"], "args")
      ])
    end

    it "returns a param tag for the keyrest parameter" do
      sig = described_class.new("(**Integer opts) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Hash<Symbol, Integer>"], "opts")
      ])
    end

    it "returns a param tag for the block parameter" do
      sig = described_class.new("() { (Integer a) -> String } -> Integer")
      expect(sig.to_tags).to eq_tags([
        tag(:yieldparam, "", ["Integer"], "a"),
        tag(:yieldreturn, "", ["String"]),
        tag(:return, "", ["Integer"])
      ])
    end

    it "returns a param tag for the block parameter with rest and keyrest" do
      sig = described_class.new("() { (Integer a, *Integer b, **Integer c) -> String } -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:yieldparam, "", ["Integer"], "a"),
        tag(:yieldparam, "", ["Array<Integer>"], "b"),
        tag(:yieldparam, "", ["Hash<Symbol, Integer>"], "c"),
        tag(:yieldreturn, "", ["String"])
      ])
    end

    it "returns a param tag with multiple types" do
      sig = described_class.new("(Integer | String a) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Integer, String"], "a")
      ])
    end

    it "returns a param tag with generics" do
      sig = described_class.new("(Array[Integer] a) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Array<Integer>"], "a")
      ])
    end

    it "returns a param tag with self" do
      sig = described_class.new("(self a) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["self"], "a")
      ])
    end

    it "returns a param tag with instance" do
      sig = described_class.new("(instance a) -> void", [], "Foo")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Foo"], "a")
      ])
    end

    it "returns a param tag with Boolean(instead of bool)" do
      sig = described_class.new("(bool a) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Boolean"], "a")
      ])
    end

    it "does not return tags for the `untyped`" do
      sig = described_class.new("(untyped a) -> untyped")
      expect(sig.to_tags).to be_empty
    end

    it "returns a param tag with `nil`" do
      sig = described_class.new("(nil a) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["nil"], "a")
      ])
    end

    it "returns a param tag with Object(instead of top)" do
      sig = described_class.new("(top a) -> void")
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Object"], "a")
      ])
    end

    it "does not return tags for the `bot`" do
      sig = described_class.new("() -> bot")
      expect(sig.to_tags).to be_empty
    end

    it "completes arg names from YARD parameters" do
      parameters = [["a", nil], ["*b", nil], ["**c", nil]]
      sig = described_class.new("(Integer, *Symbol, **String) -> void", parameters)
      expect(sig.to_tags).to eq_tags([
        tag(:param, "", ["Integer"], "a"),
        tag(:param, "", ["Array<Symbol>"], "b"),
        tag(:param, "", ["Hash<Symbol, String>"], "c")
      ])
    end
  end
end
