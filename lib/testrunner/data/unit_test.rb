# a unit-test project with gcov instrumented object-files

require "testrunner/util/command"
require "testrunner/util/status"
require "fileutils"

class UnitTest

  TEST_TYPE_UNKNOWN     = "UNKNOWN"
  TEST_TYPE_CPPUNIT     = "CPPUNIT"
  TEST_TYPE_GOOGLE      = "GTEST"
  
	def initialize(projectName, projectFolder, outputFolder, testExecutable, logger)
		@projectName = projectName			      # name of project
		@projectFolder = projectFolder		    # project-folder path
		@outputFolder = outputFolder		      # project output-folder path
    @testExecutable = testExecutable      # test executable file path
    @logger = logger
    
    @testType = TEST_TYPE_UNKNOWN
    @testTotal = -1
    @testFailed = -1
    @status = Status::UNDEFINED
	end
	
	attr_accessor :projectName
	attr_accessor :projectFolder
	attr_accessor :outputFolder
  attr_accessor :testExecutable
  attr_accessor :testType
  attr_accessor :testTotal
  attr_accessor :testFailed
  attr_accessor :status
  
  def testOk
    if @testTotal >= 0 && @testFailed >=0 then
      return @testTotal - @testFailed
    else
      return -1
    end
  end
  
  def analyseTest
    @logger.debug "analyse test: #{@testExecutable}"
    file = File.new(@testExecutable, "r")
    begin
      while (line = file.gets)
        if line.include?("CppUnit") then
          @testType = TEST_TYPE_CPPUNIT
          break
        elsif line.include?("gtest") then
          @testType = TEST_TYPE_GOOGLE
          break
        end
      end
    ensure
      file.close
    end
    @logger.debug "=> type: #{@testType}"
  end
  
	def runTest
    @logger.info "run test: #{@testExecutable}"
    command = "#{File.basename(@testExecutable)}"
    if @testType.eql?(TEST_TYPE_CPPUNIT) then
      command = "#{command} -xml=test.xml"
    elsif @testType.eql?(TEST_TYPE_GOOGLE) then
      command = "#{command} --gtest_output=\"xml:test.xml\""
    end
		FileUtils.cd(getTestFolder()) do
      begin  
			  Command.call("#{command} > test.log", @logger)
      rescue => error
        @logger.warn error.message
        @status = Status::ERROR
      end
	  end
	end
 
  def moveTestOutput()
    moveFile("#{getTestFolder()}/test.log", @outputFolder)
    moveFile("#{getTestFolder()}/test.xml", @outputFolder)
  end
	
  def evaluateTestOutput()
    evaluated = false
    failed = false
    
    xmlfile = @outputFolder+"/test.xml"
    logfile = @outputFolder+"/test.log"     
    if !@testType.eql?(TEST_TYPE_UNKNOWN) && FileTest.file?(xmlfile) then
      @logger.info "=> evaluating: #{xmlfile}"
      if @testType.eql?(TEST_TYPE_CPPUNIT) then
        parseCppUnitXml(xmlfile)
        evaluated = true
      elsif @testType.eql?(TEST_TYPE_GOOGLE) then
        parseGoogleXml(xmlfile)
        evaluated = true
      end
      if @testTotal > 0 && @testFailed > 0 then
        failed = true
      end    
    elsif FileTest.file?(logfile) then
      @logger.info "=> evaluating: #{logfile}" 
      failed = parseLogfile(logfile, [ 
        "!!!FAILURES!!!",   # CppUnit
        "[  FAILED  ]"      # GTest
      ])
      evaluated = true
    end
    
    if evaluated then
      if failed then
        @logger.info "=> Test FAILED"
        @status = Status::ERROR
      elsif @status == Status::UNDEFINED then
        @logger.info "=> Test OK"
        @status = Status::SUCCEED
      end
    else
      @logger.warn "Could not evaluate test"
      @status = Status::UNDEFINED
    end
  end

  def createOutputFolder
    if !FileTest.directory?(@outputFolder) then 
      FileUtils.mkdir_p(@outputFolder) 
    end
  end
  
private

  def getTestFolder()
    return File.dirname(@testExecutable)
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
  
  def parseCppUnitXml(path)
    file = File.new(path, "r")
    begin
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
    ensure
      file.close
    end
  end
  
  def parseGoogleXml(path)
    file = File.new(path, "r")
    begin
      while (line = file.gets)
        if line =~ /^\s*<testsuites.*tests="(\d+)".*failures="(\d+)".*>$/ && $~[1] != nil && $~[2] != nil then
          @testTotal = $~[1].to_i
          @testFailed = $~[2].to_i
          break
        end
      end
    ensure
      file.close
    end
  end
  
  def parseLogfile(path, tokens)
    found = false
    file = File.new(path, "r")
    begin
      while (line = file.gets) && !found
          tokens.each do |token|  
            if line.include?(token) then
              found = true
              break
            end
          end
      end
    ensure
      file.close
    end
    return found
  end

end