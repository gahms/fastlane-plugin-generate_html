# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/generate_html/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-generate_html'
  spec.version       = Fastlane::GenerateHtml::VERSION
  spec.author        = %q{Nicolai Henriksen}
  spec.email         = %q{nih@miracle.dk}

  spec.summary       = %q{Generate HTML files for easy install of ipa or apk on a phone}
  spec.homepage      = "https://github.com/gahms/fastlane-plugin-generate_html"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency 'apktools', '~> 0.7'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 2.39.2'
end
