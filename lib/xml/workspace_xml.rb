# generates xml output for test-results of an workspace

require "core/cppunit_runner"
require "util/logger"

class WorkspaceXml

	def initialize(workspaceFolder, outputFolder)
		@workspaceFolder = workspaceFolder		# workspace-folder path
		@outputFolder = outputFolder			# output-folder path
	end
	
	def outputFile
		return @outputFolder+"/"+Feedback::Feedback.OUTPUT_FILE
	end
	
	def createXmlOutput(cppunitRunner)
    
    feedback = Feedback::Feedback.new()
    unitTests = cppunitRunner.unitTests
    unitTests = unitTests.sort_by{|item| item.projectName}
    unitTests.each do |unitTest|
      testResult = Feedback::Result.new(unitTest.projectName)
      if unitTest.status == Status::FAILURE then
        testResult.resolution = Feedback::Result.RESOLUTION[3] # ERROR
        testResult.messages << "Could not execute unit-test"
      elsif unitTest.status == Status::ERROR then
        testResult.resolution = Feedback::Result.RESOLUTION[3] # ERROR
        if unitTest.testTotal >= 0 && unitTest.testFailed >= 0 then
          testResult.messages << unitTest.testFailed.to_s+" / "+unitTest.testTotal.to_s+" test failed"
        else
          testResult.messages << "test failed"
        end
      elsif unitTest.status == Status::SUCCEED then
        testResult.resolution = Feedback::Result.RESOLUTION[2] # SUCCEED
        if unitTest.testTotal >= 0 then
          testResult.messages << unitTest.testTotal.to_s+" test ok"
        else
          testResult.messages << "test ok"
        end
      else
        testResult.resolution = Feedback::Result.RESOLUTION[0] # UNDEFINED
        testResult.messages << "No data available"
      end
      feedback.results << testResult
    end
    feedback.serialize(outputFile)
    
	end
  
end