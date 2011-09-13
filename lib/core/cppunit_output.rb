# creates output for gcov-data

require "html/workspace_html"
require "xml/workspace_xml"

class CppUnitOutput

	def initialize(workspaceFolder, outputFolder, logger)
		@workspaceFolder = workspaceFolder		   # workspace-folder path
		@outputFolder = outputFolder			       # output-folder path
    @logger = logger 
	end
	
	def createOutput(cppunitRunner)
		@logger.emph "output"
		outputFile = nil
		
		if !$AppOptions[:xml] then
			createXmlOutput(cppunitRunner, @outputFolder)
			outputFile = createHtmlOutput(cppunitRunner, @outputFolder)
		else
			outputFile = createXmlOutput(cppunitRunner, ".")
		end
		
		if outputFile != nil && $AppOptions[:browser] then
			@logger.info "open browser"
			begin 
				FileUtil.openBrowser(outputFile)
      rescue => error
        @logger.dump error
      end
		end
	end
	
	def createHtmlOutput(cppunitRunner, outputFolder)
		htmlOutput = WorkspaceHtml.new(@workspaceFolder, outputFolder)
		htmlOutput.createHtmlOutput(cppunitRunner)
		@logger.info "html-output: "+htmlOutput.outputFile
		return htmlOutput.outputFile
	end
	
  def createXmlOutput(cppunitRunner, outputFolder)
    begin
      require "feedback"
    rescue error
      @logger.warn e.message
      return nil
    end
    
    xmlOutput = WorkspaceXml.new(@workspaceFolder, outputFolder)
    xmlOutput.createXmlOutput(cppunitRunner)
    @logger.info "xml-output: "+xmlOutput.outputFile
    return xmlOutput.outputFile
  end

end