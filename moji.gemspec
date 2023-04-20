$:.push File.expand_path('lib', __dir__)
require 'moji/version'

Gem::Specification.new do |s|
  s.name        = 'moji'
  s.version     = Moji::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Hiroshi Ichikawa']
  s.email       = ['gimite+moji@gmail.com']
  s.homepage    = 'https://github.com/gimite/moji'
  s.summary     = %q{Character type classification and conversion for Japanese language}
  s.description = %q{Character type classification and conversion for Japanese language}
  s.license     = 'MIT'

  s.files         = Dir['lib/**/*'] + %w[README.md LICENSE]
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.6'
end
