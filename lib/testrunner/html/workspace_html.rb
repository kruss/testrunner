# generates html output for test-results of an workspace

require "testrunner/core/cppunit_runner"
require "testrunner/util/html_util"
require "testrunner/util/file_util"

class WorkspaceHtml

	def initialize(workspaceFolder, outputFolder)
		@workspaceFolder = workspaceFolder		# workspace-folder path
		@outputFolder = outputFolder			    # output-folder path
	end
	
	def outputFile
		return @outputFolder+"/index.htm"
	end
	
	def createHtmlOutput(cppunitRunner)
		
    unitTests = cppunitRunner.unitTests
    
		# header
		html = HtmlUtil.getHeader($AppName)
		html << "<h1>"+$AppNameUI+" [ "+@workspaceFolder+" ] - "+Status::getHtml(cppunitRunner.status)+"</h1> \n"
    html << "<hr> \n"

    # tested projects
    html << "<h2>Unit Tests</h2> \n"
    unitTests = unitTests.sort_by{|item| item.projectName}
    if unitTests.size() > 0 then
      html << "<table cellspacing=0 cellpadding=5 border=1> \n"
      html << "<tr>"
      html << " <td width=150><b>Project</b></td>"
      html << " <td width=100><b>Results</b></td>"
      html << " <td width=75><b>Status</b></td>"
      html << "</tr> \n"
      idx = 0
      unitTests.each do |unitTest|
        idx = idx + 1
        
        projectName = unitTest.projectName
        testStatus = unitTest.status
        
        html << "<tr>"
        html << "<td>"+idx.to_s+".) <b>"
        if File.exist?(@outputFolder+"/"+projectName+"/test.log") then
          html << "<a href='"+projectName+"/test.log'>"+projectName+"</a>"
        else
          html << projectName
        end
        html << "</b></td>"
        if unitTest.testTotal >= 0 && unitTest.testFailed >= 0 then
          html << "<td>total: "+unitTest.testTotal.to_s+" / failed: "+unitTest.testFailed.to_s+"</td>"
        else
          html << "<td><i>&lt;unknown&gt;</i></td>"
        end
        html << "<td>"+Status::getHtml(testStatus)+"</td>"
        html << "<tr> \n"
      end
      html << "</table> \n"
    else
      html << "<ul><i>empty</i></ul> \n"
    end
    
    # logfile
    if FileTest.file?("#{$AppOptions[:output]}/#{$AppName}.log") then
       html << "<p> \n"
       html << "<a href='"+$AppName+".log'>Logfile</a> \n"
       html << "</p> \n"
    end
		
		# footer
		html << HtmlUtil.getFooter
		
		# output
		FileUtil.writeFile(outputFile, html)
	end
end