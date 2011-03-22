# generates xml output for test-results of an workspace

require "core/cppunit_runner"
require "util/xml_util"
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
      testResult.resolution = getResolution(unitTest.status).to_s
      feedback.results << testResult
    end
    feedback.serialize(outputFile)
    
	end
  
  def getResolution(status)

    case status
      when 2 # SUCCEED
        return Feedback::Result.RESOLUTION[2] # SUCCEED
      when 3 # ERROR
      when 4 # FAILURE
        return Feedback::Result.RESOLUTION[3] # ERROR
      else
        return Feedback::Result.RESOLUTION[0] # UNDEFINED
    end
  end
  
end