# frozen_string_literal: true

require "rbs"
require "yard"

require_relative "yard-sig/version"
require_relative "yard-sig/sig"

module YardSig
  class Error < StandardError; end

  class SigDirective < ::YARD::Tags::Directive
    # @!sig () -> void
    def call
      validate_arguments_forwarding!

      sig = Sig.new(tag.text, object.parameters, object.namespace.path)
      parser.tags += sig.to_tags
    rescue Error => e
      log.warn(e.message)
    end

    private

    def validate_arguments_forwarding!
      return unless object.signature.include?("(...)")

      raise Error, "arguments forwarding is not supported."
    end
  end
end

YARD::Tags::Library.define_directive :sig, YardSig::SigDirective
