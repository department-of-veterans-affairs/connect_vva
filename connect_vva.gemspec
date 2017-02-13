Gem::Specification.new do |gem|
  gem.name          = "connect_vva"
  gem.version       = "0.1"
  gem.summary       = "Thin wrapper on top of savon to talk with Virtual VA"
  gem.description   = "Thin wrapper on top of savon to talk with Virtual VA"

  gem.authors       = "Anya Roltsch"
  gem.email         = "Anna.Roltsch@va.gov"
  gem.homepage      = ""

  gem.add_runtime_dependency "savon", '~> 2.11', '>= 2.11.0'

  gem.files         = Dir["lib/**/*.rb"]
  gem.require_paths = ["lib"]
end
