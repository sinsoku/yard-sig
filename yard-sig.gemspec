# frozen_string_literal: true

require_relative "lib/yard-sig/version"

Gem::Specification.new do |spec|
  spec.name = "yard-sig"
  spec.version = YardSig::VERSION
  spec.authors = ["Takumi Shotoku"]
  spec.email = ["sinsoku.listy@gmail.com"]

  spec.summary = "A YARD plugin for writing documentations with RBS syntax"
  spec.description = "It provides a way to define types with `@!sig` directive instead of other tags."
  spec.homepage = "https://github.com/sinsoku/yard-sig"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/tree/v#{spec.version}"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rbs", ">= 3.0"
  spec.add_dependency "yard", ">= 0.9"
end
