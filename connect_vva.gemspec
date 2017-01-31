Gem::Specification.new do |gem|
  gem.name          = "connect_vva"
  gem.version       = "0.1"
  gem.summary       = "Thin wrapper on top of savon to talk with Virtual VA"
  gem.description   = "Thin wrapper on top of savon to talk with Virtual VA"

  gem.authors       = "Anya Roltsch"
  gem.email         = "Anna.Roltsch@va.gov"
  gem.homepage      = ""

  gem.add_runtime_dependency "nokogiri"
  gem.add_runtime_dependency "savon"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rubocop"

  gem.files         = Dir["lib/**/*.rb"]
  gem.require_paths = ["lib"]
end
