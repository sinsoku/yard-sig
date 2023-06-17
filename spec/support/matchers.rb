# frozen_string_literal: true

RSpec::Matchers.define :eq_tags do |expected|
  eq_tag = lambda { |x, y|
    x.tag_name == y.tag_name &&
      x.text == y.text &&
      x.name == y.name &&
      x.types == y.types
  }

  match do |actual|
    actual.size == expected.size &&
      actual.each_with_index.all? { |tag, i| eq_tag.call(tag, expected[i]) }
  end

  failure_message do |actual|
    <<~MSG
      expected:
      #{expected.map(&:inspect).join("\n")}
      actual:
      #{actual.map(&:inspect).join("\n")}
    MSG
  end
end
