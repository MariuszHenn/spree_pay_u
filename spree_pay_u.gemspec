# coding: utf-8

Gem::Specification.new do |s|
  s.platform              = Gem::Platform::RUBY
  s.name                  = 'spree_pay_u'
  s.version               = '0.1.6'
  s.summary               = 'PayU.pl payment system for Spree'
  s.required_ruby_version = '>= 1.8.7'
  s.author                = 'Mariusz Henn'
  s.email                 = 'mariusz.henn@gmail.com'
  s.files                 = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path          = 'lib'
  s.requirements          << 'none'
  
  s.add_dependency('spree_core', '>= 1.0')
end
