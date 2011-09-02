version = File.read(File.expand_path("../VERSION", __FILE__)).strip

Gem::Specification.new do |s|

  s.platform = Gem::Platform::RUBY
  s.name = 'datyl'
  s.version = version
  s.summary = 'A toolkit of support libraries for DAITSS.'
  s.description = 'A toolkit of support libraries for DAITSS, including configuration, streams processing, logging, tries, etc.'

  s.required_ruby_version = '>= 1.8.7'

  s.authors = [ 'Randy Fischer', 'Manny Rodriguez' ]
  s.email   = [ 'rf@ufl.edu', 'avatar38@ufl.edu' ]

  s.homepage = 'http://fda.fcla.edu/'

  s.files = Dir['CHANGELOG', 'README', 'lib/**/*']

  s.require_path = 'lib'
end
