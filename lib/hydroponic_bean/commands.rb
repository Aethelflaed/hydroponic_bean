require 'hydroponic_bean/commands/producer'
require 'hydroponic_bean/commands/worker'
require 'hydroponic_bean/commands/other'

module HydroponicBean
  module Commands
    include HydroponicBean::Commands::Producer
    include HydroponicBean::Commands::Worker
    include HydroponicBean::Commands::Other
  end
end
