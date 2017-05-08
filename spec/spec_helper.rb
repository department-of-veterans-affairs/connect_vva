require "vva"
require "savon/mock/spec_helper"

include Savon::SpecHelper

RSpec.configure do |config|
  config.order = "random"

  # set Savon in and out of mock mode
  config.before(:all) { savon.mock!   }
  config.after(:all)  { savon.unmock! }
end