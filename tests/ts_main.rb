$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require "test/unit"
require "testrunner/data/tc_unit_test"

class TsMain 
  
  def self.suite
    suite = Test::Unit::TestSuite.new
    suite << TcUnitTest::TcUnitTest.suite
    return suite
  end
end
