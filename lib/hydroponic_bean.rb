require 'beaneater'

require 'hydroponic_bean/version'
require 'hydroponic_bean/data'
require 'hydroponic_bean/connection'
require 'hydroponic_bean/test_helper'

module HydroponicBean
  def establish_connection
    # Keep all variables initialized as if normal connection
    @address = address.first if address.is_a?(Array)
    match = address.split(':')
    @host, @port = match[0], Integer(match[1] || DEFAULT_PORT)

    @connection = Connection.new
  end
end

class Beaneater
  def self.hydroponic!
    Beaneater::Connection.class_eval do
      prepend HydroponicBean
    end
  end
end
