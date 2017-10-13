$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest'

class TestCase < Minitest::Test
  def after_teardown
    HydroponicBean.clear
  end
end

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'timecop'

require 'hydroponic_bean'

require 'minitest/autorun'
