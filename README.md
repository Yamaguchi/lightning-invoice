# Lightning::Invoice

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/lightning/invoice`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lightning-invoice'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lightning-invoice

## Usage

Running console

```
$ ./bin/console
```

Encode Payment

```
irb(main):001:0> message = Lightning::Invoice::Message.new
=> #<Lightning::Invoice::Message:0x007fd1ec1df1f8 @amount=-1, @timestamp=0, @expiry=3600, @min_final_cltv_expiry=9, @routing_info=[]>
irb(main):002:0> message.prefix = "lnbc"
=> "lnbc"
irb(main):003:0> message.amount = 2500
=> 2500
irb(main):004:0> message.multiplier = "u"
=> "u"
irb(main):005:0> message.timestamp = Time.now.to_i
=> 1535552315
irb(main):006:0> message.payment_hash = "0001020304050607080900010203040506070809000102030405060708090102".htb
=> "\x00\x01\x02\x03\x04\x05\x06\a\b\t\x00\x01\x02\x03\x04\x05\x06\a\b\t\x00\x01\x02\x03\x04\x05\x06\a\b\t\x01\x02"
irb(main):007:0> message.description = "Please consider supporting this project"
=> "Please consider supporting this project"
irb(main):008:0> message.expiry = 60
=> 60
irb(main):009:0> message.signature = "38ec6891345e204145be8a3a99de38e98a39d6a569434e1845c8af7205afcfcc7f425fcd1463e93c32881ead0d6e356d467ec8c02553f9aab15e5738b11f127f00".htb
=> "8\xECh\x914^ AE\xBE\x8A:\x99\xDE8\xE9\x8A9\xD6\xA5iCN\x18E\xC8\xAFr\x05\xAF\xCF\xCC\x7FB_\xCD\x14c\xE9<2\x88\x1E\xAD\rn5mF~\xC8\xC0%S\xF9\xAA\xB1^W8\xB1\x1F\x12\x7F\x00"
irb(main):010:0> message.fallback_address = "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4"
=> "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4"
irb(main):011:0> message.to_bech32
=> "lnbc2500u1pdcd2empp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqdpl2pkx2ctnv5sxxmmwwd5kgetjypeh2ursdae8g6twvus8g6rfwvs8qun0dfjkxaqxqzpufppqw508d6qejxtdg4y5r3zarvary0c5xw7k8rkx3yf5tcsyz3d73gafnh3cax9rn449d9p5uxz9ezhhypd0elx87sjle52x86fux2ypatgddc6k63n7erqz25le42c4u4ecky03ylcqgtxcst"

```

Decode Payment

```

irb(main):012:0> Lightning::Invoice.parse("lnbc2500u1pdcd2empp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqdpl2pkx2ctnv5sxxmmwwd5kgetjypeh2ursdae8g6twvus8g6rfwvs8qun0dfjkxaqxqzpufppqw508d6qejxtdg4y5r3zarvary0c5xw7k8rkx3yf5tcsyz3d73gafnh3cax9rn449d9p5uxz9ezhhypd0elx87sjle52x86fux2ypatgddc6k63n7erqz25le42c4u4ecky03ylcqgtxcst")
=> #<Lightning::Invoice::Message:0x007fd1eb2dc390 @amount=2500, @timestamp=1535552315, @expiry=60, @min_final_cltv_expiry=9, @routing_info=[], @prefix="lnbc", @multiplier="u", @payment_hash="\x00\x01\x02\x03\x04\x05\x06\a\b\t\x00\x01\x02\x03\x04\x05\x06\a\b\t\x00\x01\x02\x03\x04\x05\x06\a\b\t\x01\x02", @description="Please consider supporting this project", @signature="8\xECh\x914^ AE\xBE\x8A:\x99\xDE8\xE9\x8A9\xD6\xA5iCN\x18E\xC8\xAFr\x05\xAF\xCF\xCC\x7FB_\xCD\x14c\xE9<2\x88\x1E\xAD\rn5mF~\xC8\xC0%S\xF9\xAA\xB1^W8\xB1\x1F\x12\x7F\x00", @fallback_address="bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4">

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Yamaguchi/lightning-invoice. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Lightning::Invoice project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Yamaguchi/lightning-invoice/blob/master/CODE_OF_CONDUCT.md).
