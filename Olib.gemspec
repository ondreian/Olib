Gem::Specification.new do |s|
  s.name        = 'Olib'
  s.version     = '0.0.4'
  s.date        = '2014-09-12'
  s.summary     = "Useful Lich extensions for Gemstone IV"
  s.description = "Useful Lich extensions for Gemstone IV including hostile creature management, group management, syntactically pleasing movement, locker management, etc"
  s.authors     = ["Ondreian Shamsiel"]
  s.email       = 'ondreian.shamsiel@gmail.com'
  s.homepage    = 'https://github.com/ondreian/Olib'
  s.files       = [
    "lib/Olib.rb",
    "lib/Olib/group.rb",
    "lib/Olib/creature.rb",
    "lib/Olib/creatures.rb",
    "lib/Olib/errors.rb",
    "lib/Olib/utils.rb",
    "lib/Olib/extender.rb",
    "lib/Olib/container.rb",
    "lib/Olib/dictionary.rb",
    "lib/Olib/item.rb",
    "lib/Olib/shops.rb",
    "lib/Olib/transport.rb",
    "lib/Olib/inventory.rb",
    "lib/Olib/help_menu.rb"
  ]
  # s.add_runtime_dependency 'shoes'
  s.license     = 'MIT'
end