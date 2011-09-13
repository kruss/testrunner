# a unit-test project with gcov instrumented object-files

require "util/command"
require "util/status"
require "fileutils"

class UnitTest

	def initialize(projectName, projectFolder, outputFolder, testExecutable, logger)
		@projectName = projectName			      # name of project
		@projectFolder = projectFolder		    # project-folder path
		@outputFolder = outputFolder		      # project output-folder path
    @testExecutable = testExecutable      # test executable file path
    @logger = logger
    
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
    @logger.info "run test: #{@testExecutable}"
		FileUtils.cd(getTestFolder()) do
      begin  
		    command = File.basename(@testExecutable)+" -xml=cppunit.xml > cppunit.log"
			  Command.call(command, @logger)
      rescue => error
        @logger.dump error
        @status = Status::FAILURE
      end
	  end
	end
 
  def moveTestOutput()
    moveFile("#{getTestFolder()}/cppunit.log", @outputFolder)
    moveFile("#{getTestFolder()}/cppunit.xml", @outputFolder)
  end
	
  def evaluateTestOutput()
    evaluated = false
    
    # ealute results by xmlfile
    xmlfilePath = @outputFolder+"/cppunit.xml"
    if FileTest.file?(xmlfilePath) then
      @logger.info "=> evaluating: "+xmlfilePath 
      xmlfile = File.new(xmlfilePath, "r")
      getTestResultsFromXml(xmlfile)
      xmlfile.close
      evaluated = true
    else
      # ealute results by logfile
      logfilePath = @outputFolder+"/cppunit.log"
      if FileTest.file?(logfilePath) then
        @logger.info "=> evaluating: "+logfilePath 
        logfile = File.new(logfilePath, "r")
        getTestResultsFromLog(logfile)
        logfile.close
        evaluated = true
      end
    end
    
    if !evaluated then
      @logger.warn "missing test-results"
    end
  end

  def createOutputFolder
    if !FileTest.directory?(@outputFolder) then 
      FileUtils.mkdir_p(@outputFolder) 
    end
  end
  
private

  def getTestFolder()
    return @projectFolder+"/"+Pathname.new(@testExecutable).relative_path_from(Pathname.new(@projectFolder)).cleanpath.to_s.split("/")[0]
  end
  
  def moveFile(path, destination)
    if FileTest.file?(path) then
      @logger.debug "move file: #{path} -> #{destination}"
      if !FileTest.directory?(destination) then 
        FileUtils.mkdir_p(destination) 
      end
      FileUtils.mv(FileList.new(path), destination)
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
      @logger.info "=> Test FAILED"
      @status = Status::ERROR
    else
      @logger.info "=> Test OK"
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
      @logger.info "=> Test FAILED"
      @status = Status::ERROR
    else
      @logger.info "=> Test OK"
      @status = Status::SUCCEED
    end
  end

end