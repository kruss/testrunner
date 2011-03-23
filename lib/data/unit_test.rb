# a unit-test project with gcov instrumented object-files

require "util/logger"
require "util/status"

class UnitTest

	def initialize(projectName, projectFolder, outputFolder, testExecutable)
		@projectName = projectName			    # name of project
		@projectFolder = projectFolder		  # project-folder path
		@outputFolder = outputFolder		    # project output-folder path
    @testExecutable = testExecutable    # test executable file path
    
    @status = Status::UNDEFINED
    @testTotal = -1
    @testFailed = -1
	end
	
	attr_accessor :projectName
	attr_accessor :projectFolder
	attr_accessor :outputFolder
  attr_accessor :testExecutable
  attr_accessor :status
  attr_accessor :testTotal
  attr_accessor :testFailed
  
  def testOk
    if @testTotal >= 0 && @testFailed >=0 then
      return @testTotal - @testFailed
    else
      return -1
    end
  end
	
	def runUnitTest

    # execute test
		configName = Pathname.new(@testExecutable).relative_path_from(Pathname.new(@projectFolder)).cleanpath.to_s.split("/")[0]
		configFolder = @projectFolder+"/"+configName	
		command = File.basename(@testExecutable)+" -xml=cppunit.xml > cppunit.log"
		Logger.debug "... calling: "+command
		cd configFolder do
			sh command
	  end
  
    # copy output
    logfilePath = @projectFolder+"/"+configName+"/cppunit.log"
    if FileTest.file?(logfilePath) then
      FileUtils.mv(FileList.new(logfilePath), outputFolder)
    end
    xmlfilePath = @projectFolder+"/"+configName+"/cppunit.xml"
    if FileTest.file?(xmlfilePath) then
      FileUtils.mv(FileList.new(xmlfilePath), outputFolder)
    end
  end
	
  def getTestResults
    
    evaluated = false
    
    # ealute results by xmlfile
    xmlfilePath = outputFolder+"/cppunit.xml"
    if FileTest.file?(xmlfilePath) then
      Logger.log "Evaluating: "+xmlfilePath 
      xmlfile = File.new(xmlfilePath, "r")
      getTestResultsFromXml(xmlfile)
      xmlfile.close
      evaluated = true
    else
      # ealute results by logfile
      logfilePath = outputFolder+"/cppunit.log"
      if FileTest.file?(logfilePath) then
        logfile = File.new(logfilePath, "r")
        Logger.log "Evaluating: "+logfilePath 
        getTestResultsFromLog(logfile)
        logfile.close
        evaluated = true
      end
    end
    
    if ! evaluated then
      Logger.error "Could not evaluate test results"
    end
    
  end
  
  def getTestResultsFromXml(file)
    
    parse = false
    while (line = file.gets)
        if line.include?("<Statistics>") then
          parse = true
          next
        end
        if line.include?("</Statistics>") then
          break
        end
        if parse then
          if line =~ /^\s*<Tests>(\d+)<\/Tests>$/ && $~[1] != nil then
            @testTotal = $~[1].to_i
          end
          if line =~ /^\s*<FailuresTotal>(\d+)<\/FailuresTotal>$/ && $~[1] != nil then
            @testFailed = $~[1].to_i
          end
        end
    end
    if @testTotal > 0 && @testFailed > 0 then
      Logger.log "Test FAILED !"
      @status = Status::ERROR
    else
      Logger.log "Test OK !"
      @status = Status::SUCCEED
    end
  end
  
  def getTestResultsFromLog(file)
    
    fail = false
    while (line = file.gets)
        if line.include?("!!!FAILURES!!!") then
          fail = true
          break
        end
    end
    if fail then
      Logger.log "Test FAILED !"
      @status = Status::ERROR
    else
      Logger.log "Test OK !"
      @status = Status::SUCCEED
    end
    
  end
  
	def createOutputFolder
	
		if !FileTest.directory?(outputFolder) then 
			Dir.mkdir(outputFolder) 
		end
	end
end