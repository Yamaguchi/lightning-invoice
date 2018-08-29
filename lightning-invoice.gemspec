# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lightning/invoice/version"

Gem::Specification.new do |spec|
  spec.name          = "lightning-invoice"
  spec.version       = Lightning::Invoice::VERSION
  spec.authors       = ["Hajime Yamaguchi"]
  spec.email         = ["gen.yamaguchi0@gmail.com"]

  spec.summary       = 'Ruby implementation of the Lightning Network Invoice Protocol (BOLT #11).'
  spec.description   = 'Ruby implementation of the Lightning Network Invoice Protocol (BOLT #11).'
  spec.homepage      = 'https://github.com/Yamaguchi/lightning-invoice'
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency 'bech32'
  spec.add_runtime_dependency 'bitcoinrb'
end
