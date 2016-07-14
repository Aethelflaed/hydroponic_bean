# HydroponicBean

This gem aims to provide a mock for the [beaneater](https://github.com/beanstalkd/beaneater) connection,
used to access a [beanstalkd](https://github.com/kr/beanstalkd)
instance, either directly or through [backburner](https://github.com/nesquena/backburner).

At the moment, the focus is made only on the producer commands, although it should be
easy enough (though maybe not as useful) to mock worker commands to, followings the
[protocol documentation](https://github.com/kr/beanstalkd/blob/master/doc/protocol.txt)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hydroponic_bean', group: :test
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hydroponic_bean

## Usage

Simply call `Beaneater.hydroponic!` to make it use this mocked collection.

You can include `HydroponicBean::TestHelper` which provides `assert_job_put(count = 1) do ... end` for you tests.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hydroponic_bean. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

