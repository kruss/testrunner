# runs gcov on unit-tests within a workspace

require "rake"
require "pathname"
require "data/unit_test"

class CppUnitRunner

	def initialize(workspaceFolder, outputFolder, logger)
		@workspaceFolder = workspaceFolder		      # workspace-folder path
		@outputFolder = outputFolder			          # output-folder path
    @logger = logger
    
		@unitTests = Array.new					            # unit-tests within workspace
	end
	
	attr_accessor :unitTests

  def status
    if @unitTests.size() > 0 then
      @unitTests.each do |unitTest|
        if unitTest.status != Status::SUCCEED then
          return Status::ERROR
        end
      end
      return Status::SUCCEED
    else
      return Status::UNDEFINED
    end
  end

	def fetchUnitTests
		executable_pattern = "#{@workspaceFolder}/*/#{$AppOptions[:config]}/*.#{$AppOptions[:extention]}"
    @logger.info "search test-executables: #{executable_pattern}" 
    testExecutables = FileList.new(executable_pattern)
    @logger.info "=> test-executables: #{testExecutables.size}"
    
    testExecutables.each do |testExecutable|
      testExecutablePath = testExecutable.to_s
      @logger.info "test-executable: #{testExecutablePath}"
      projectName = Pathname.new(testExecutablePath).relative_path_from(Pathname.new(@workspaceFolder)).to_s.split("/")[0]
      projectFolder = @workspaceFolder+"/"+projectName
      
      unitTest = @unitTests.find{ |item| item.projectName.eql?(projectName) }
      if unitTest == nil then
        @logger.debug "=> adding unit-test: #{projectFolder}"
        outputFolder = @outputFolder+"/"+projectName
        unitTest = UnitTest.new(projectName, projectFolder, outputFolder, testExecutable, @logger)
        @unitTests << unitTest
      end
    end
    @logger.info "=> tests: #{@unitTests.size}"
	end
	
	def runUnitTests
		@unitTests.each do |unitTest|
      @logger.emph unitTest.projectName
      begin
  			unitTest.createOutputFolder
        unitTest.analyseTest
  			unitTest.runTest
        unitTest.moveTestOutput
        unitTest.evaluateTestOutput
      rescue => error
        @logger.dump error
        unitTest.status = Status::FAILURE
      end
		end
	end

end