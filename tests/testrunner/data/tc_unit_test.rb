require "test/unit"
require "logger"
require "testrunner/data/unit_test"
require "rake"

module TcUnitTest
  
class TcUnitTest < Test::Unit::TestCase
  
  def setup  
    @binaryFolder = "#{Dir.getwd}/tests/binary"
    @outputFolder = "#{Dir.getwd}/tests/temp"
    @logger = Logger.new(NIL)
  end 
    
  def teardown
    if FileTest.directory?(@outputFolder) then 
      FileUtils.rm_rf(@outputFolder)
    end
  end

  def test_CppUnitTest
    @logger.info("=== CppUnitTest ===")
    test = UnitTest.new("dummy", @binaryFolder, @outputFolder, "#{@binaryFolder}/CppUnitTest.exe", @logger)
    test.analyseTest()
    test.runTest()
    test.moveTestOutput()
    test.evaluateTestOutput()

    assert_equal(UnitTest::TEST_TYPE_CPPUNIT, test.testType)
    assert_equal(2, test.testTotal)
    assert_equal(1, test.testFailed)
    assert_equal(Status::ERROR, test.status)
  end
  
  def test_CppUnitTest_UnknownType
    @logger.info("=== CppUnitTest (unknown-type) ===")
    test = UnitTest.new("dummy", @binaryFolder, @outputFolder, "#{@binaryFolder}/CppUnitTest.exe", @logger)
    test.runTest()
    test.moveTestOutput()
    test.evaluateTestOutput()

    assert_equal(UnitTest::TEST_TYPE_UNKNOWN, test.testType)
    assert_equal(-1, test.testTotal)
    assert_equal(-1, test.testFailed)
    assert_equal(Status::ERROR, test.status)
  end
  
  def test_GoogleTest
    @logger.info("=== GoogleTest ===")
    test = UnitTest.new("dummy", @binaryFolder, @outputFolder, "#{@binaryFolder}/GoogleTest.exe", @logger)
    test.analyseTest()
    test.runTest()
    test.moveTestOutput()
    test.evaluateTestOutput()
    
    assert_equal(UnitTest::TEST_TYPE_GOOGLE, test.testType)
    assert_equal(2, test.testTotal)
    assert_equal(1, test.testFailed)
    assert_equal(Status::ERROR, test.status)
  end
  
  def test_GoogleTest_UnknownType
    @logger.info("=== GoogleTest (unknown-type) ===")
    test = UnitTest.new("dummy", @binaryFolder, @outputFolder, "#{@binaryFolder}/GoogleTest.exe", @logger)
    test.runTest()
    test.moveTestOutput()
    test.evaluateTestOutput()
    
    assert_equal(UnitTest::TEST_TYPE_UNKNOWN, test.testType)
    assert_equal(-1, test.testTotal)
    assert_equal(-1, test.testFailed)
    assert_equal(Status::ERROR, test.status)
  end
      
end

end # module