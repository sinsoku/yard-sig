# frozen_string_literal: true

module TestHelper
  def tag(tag_name, text, types = nil, name = nil)
    YARD::Tags::Tag.new(tag_name, text, types, name)
  end
end

RSpec.configure do |config|
  config.include(TestHelper)
end
