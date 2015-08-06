lib = File.expand_path("../lib/", __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'Olib'
  s.version       = '0.0.6'
  s.date          = '2014-09-12'
  s.summary       = "Useful Lich extensions for Gemstone IV"
  s.description   = "Useful Lich extensions for Gemstone IV including hostile creature management, group management, syntactically pleasing movement, locker management, etc"
  s.authors       = ["Ondreian Shamsiel"]
  s.email         = 'ondreian.shamsiel@gmail.com'
  s.homepage      = 'https://github.com/ondreian/Olib'
  s.files         = %w[Olib.gemspec] + Dir['*.md', 'lib/**/*.rb']
  #s.require_paths = %w[lib]
  # s.add_runtime_dependency 'shoes'
  s.license     = 'MIT'
end