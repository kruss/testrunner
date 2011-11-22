# generates xml output for test-results of an workspace

require "testrunner/core/cppunit_runner"

class WorkspaceXml

	def initialize(workspaceFolder, outputFolder)
		@workspaceFolder = workspaceFolder		# workspace-folder path
		@outputFolder = outputFolder			    # output-folder path
	end
	
	def outputFile
		return @outputFolder+"/"+Feedback.OUTPUT_FILE
	end
	
	def createXmlOutput(cppunitRunner)
    
    feedback = Feedback.new()
    unitTests = cppunitRunner.unitTests
    unitTests = unitTests.sort_by{|item| item.projectName}
    unitTests.each do |unitTest|
      testResult = Result.new(unitTest.projectName)
      if unitTest.status == Status::FAILURE then
        testResult.status = Result.STATUS_ERROR
        testResult.values << "Could not execute unit-test"
      elsif unitTest.status == Status::ERROR then
        testResult.status = Result.STATUS_ERROR
        if unitTest.testTotal >= 0 && unitTest.testFailed >= 0 then
          testResult.values << unitTest.testFailed.to_s+" / "+unitTest.testTotal.to_s+" test failed"
        else
          testResult.values << "test failed"
        end
      elsif unitTest.status == Status::SUCCEED then
        testResult.status = Result.STATUS_SUCCEED
        if unitTest.testTotal >= 0 then
          testResult.values << unitTest.testTotal.to_s+" test ok"
        else
          testResult.values << "test ok"
        end
      else
        testResult.status = Result.STATUS_UNDEFINED
        testResult.values << "No data available"
      end
      feedback.results << testResult
    end
    feedback.serialize(outputFile)
    
	end
  
end