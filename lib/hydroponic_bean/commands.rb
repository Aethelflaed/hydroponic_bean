require 'hydroponic_bean/commands/producer'
require 'hydroponic_bean/commands/worker'
require 'hydroponic_bean/commands/tube'
require 'hydroponic_bean/commands/other'

module HydroponicBean
  module Commands
    include HydroponicBean::Commands::Producer
    include HydroponicBean::Commands::Worker
    include HydroponicBean::Commands::Tube
    include HydroponicBean::Commands::Other

    # Find a job by id and yield it
    #
    # Outputs Protocol::NOT_FOUND if the block returns false
    # or the job is not found
    def for_job(id)
      job = HydroponicBean.find_job(id)
      if !job || !yield(job)
        output(Protocol::NOT_FOUND)
        return false
      end
    end
  end
end
