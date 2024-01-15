[![Gem Version](https://badge.fury.io/rb/yard-sig.svg)](https://badge.fury.io/rb/yard-sig)

# yard-sig

A YARD plugin for writing documentations with [RBS syntax](https://github.com/ruby/rbs).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add yard-sig

Then specify it as an argument when running YARD.

    $ bundle exec yard doc --plugin sig

## Usage

This plugin provides a `@!sig` directive to define types as follows.

```ruby
class Foo
  # @!sig (Integer, Integer) -> Integer
  def sum(a, b)
    a + b
  end
end
```

Using this directive will cause it to be replaced internally by `@param` and `@return` tags when YARD runs.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sinsoku/yard-sig. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sinsoku/yard-sig/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Yard::Sig project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sinsoku/yard-sig/blob/main/CODE_OF_CONDUCT.md).
