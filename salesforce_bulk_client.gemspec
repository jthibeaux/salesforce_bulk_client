# coding: UTF-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salesforce_bulk_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'salesforce_bulk_client'
  spec.version       = SalesforceBulkClient::VERSION
  spec.authors       = ['Jeremy Thibeaux']
  spec.email         = ['jthibeaux@gmail.com']
  spec.summary       = 'Simple client for Salesforce Bulk API usage'
  spec.description   = 'Intended for basic usage of the Salesforce Bulk API'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'xml-simple'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'debugger'
end
