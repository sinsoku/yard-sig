# frozen_string_literal: true

module YardSig
  class Sig
    TAG_ORDER = %w[param yieldparam yieldreturn return].freeze

    # @!sig (String source, ?Array[Array[String]] parameters, ?String namespace) -> self
    def initialize(source, parameters = [], namespace = "")
      @source = source
      @parameters = parameters
      @namespace = namespace
    end

    # @!sig () -> Array[YARD::Tags::Tag]
    def to_tags
      tags = rbs_type_to_tags(rbs_method_type.type)
      tags += rbs_type_to_tags(rbs_method_type.block.type, within_block: true) if rbs_method_type.block

      tags.compact.sort_by { |tag| TAG_ORDER.index(tag.tag_name) }
    end

    private

    def rbs_method_type
      @rbs_method_type ||= RBS::Parser.parse_method_type(@source)
    end

    def rbs_type_to_tags(rbs_type, within_block: false) # rubocop:disable Metrics/AbcSize
      positionals = rbs_type.required_positionals + rbs_type.optional_positionals

      tags = positionals.map.with_index do |param, i|
        build_param_tag(param, :positionals, pos: i, within_block: within_block)
      end

      tags += rbs_type.required_keywords.map { |name, type| build_param_tag_for_keyword(name, type) }
      tags += rbs_type.optional_keywords.map { |name, type| build_param_tag_for_keyword(name, type) }

      tags << build_param_tag(rbs_type.rest_positionals, :rest, within_block: within_block)
      tags << build_param_tag(rbs_type.rest_keywords, :keyrest, within_block: within_block)
      tags << build_return_tag(rbs_type.return_type, within_block: within_block)

      tags.compact
    end

    def build_param_tag(type, kind, pos: nil, within_block: false) # rubocop:disable Metrics/MethodLength
      return unless type

      yard_types = to_yard_type(type.type)
      return unless yard_types

      tag_name = within_block ? :yieldparam : :param
      name = type.name ? type.name.to_s : find_name_from_yard(kind, pos)

      if kind == :rest
        yard_types = "Array<#{yard_types.join(", ")}>"
      elsif kind == :keyrest
        yard_types = "Hash{Symbol => #{yard_types.join(", ")}}"
      end

      YARD::Tags::Tag.new(tag_name, "", yard_types, name)
    end

    def build_param_tag_for_keyword(name, type)
      yard_types = to_yard_type(type.type)
      return unless yard_types

      YARD::Tags::Tag.new(:param, "", yard_types, name.to_s)
    end

    def build_return_tag(type, within_block: false)
      return unless type

      yard_types = to_yard_type(type)
      return unless yard_types

      tag_name = within_block ? :yieldreturn : :return
      YARD::Tags::Tag.new(tag_name, "", yard_types)
    end

    def to_yard_type(type) # rubocop:disable Metrics
      case type
      when RBS::Types::Bases::Void, RBS::Types::Bases::Any, RBS::Types::Bases::Bottom
        nil
      when RBS::Types::Bases::Top
        ["Object"]
      when RBS::Types::Union
        type.types.map { |t| to_yard_type(t) }
      when RBS::Types::Tuple
        args = type.types.map { |t| to_yard_type(t) }.join(", ")
        ["Array[#{args}]"]
      when RBS::Types::Bases::Bool
        ["Boolean"]
      when RBS::Types::Bases::Instance
        [@namespace.to_s]
      when RBS::Types::Optional
        [to_yard_type(type.type).join(", ").to_s, "nil"]
      when RBS::Types::ClassInstance
        args = type.args.map { |t| to_yard_type(t) }
        if args.empty?
          [type.to_s]
        elsif type.name.name == :Hash
          key = args[0].join(", ")
          value = args[1].join(", ")
          ["#{type.name}{#{key} => #{value}}"]
        else
          ["#{type.name}<#{args.join(", ")}>"]
        end
      else
        [type.to_s]
      end
    end

    def find_name_from_yard(kind, pos) # rubocop:disable Metrics
      @param_names ||= {}.tap do |h|
        names = @parameters.map(&:first)

        h[:rest] = names.find { |s| s.start_with?(/\*\w/) }&.then { |name| name.delete_prefix("*") }
        h[:keyrest] = names.find { |s| s.start_with?(/\*\*\w/) }&.then { |name| name.delete_prefix("**") }
        h[:block] = names.find { |s| s.start_with?("&") }&.then { |name| name.delete_prefix("&") }
        h[:keywords] = names.select { |s| s.end_with?(":") }.map { |name| name.delete_suffix(":") }
        h[:positionals] = names.grep(/\w/)
      end
      kind == :positionals ? @param_names.dig(kind, pos) : @param_names[kind]
    end
  end
end
