Gem::Specification.new do |s|
  s.name        = 'faktura'
  s.version     = '0.1.7'
  s.date        = '2019-01-10'
  s.summary     = "Fakturator is a command line tool to help with gathering invoices"
  s.description = "This tool shows invocies issuers, and summarizes which invoices are downloaded"
  s.authors     = ["Marcin Koziej"]
  s.email       = 'marcin@akcjademokracja.pl'
  s.files       = Dir['./lib/**/*.rb'] + Dir['./lib/**/*.yml']
  s.homepage    = 'http://rubygems.org/gems/faktura'
  s.license     = '0BSD'
  s.bindir      = "bin"
  s.executables = ['faktura']
  s.add_runtime_dependency 'clamp', '~> 1.3', '>= 1.3.0'
  s.add_runtime_dependency 'colorize', '~> 0.8.0'
  s.add_runtime_dependency 'hexapdf', '~> 0.9.0'
end
