
class FileUtil
	
	def FileUtil.writeFile(filePath, html)
		file = File.new(filePath, "w")
		if file
			file.syswrite(html)
			file.close
		else
		   raise "unable to write: " + filePath
		end
	end

	def FileUtil.openBrowser(path)
		realpath = Pathname.new(path).realpath
		done = false
		if FileUtil.isWindows() then 
			done = system("rundll32 url.dll,FileProtocolHandler \"#{realpath}\"")	
		elsif FileUtil.isLinux() then
			browsers = Array[
				"gnome-open", "kfmclient" , "exo-open", "htmlview",                 # dektop browsers
				"firefox", "seamonkey", "opera", "mozilla", "netscape", "galeon"    # system browsers
			]
			browsers.each do |browser|
				if system("#{browser} #{realpath}") then
					done = true
					break
				end
			end		
		else
			raise "unsupported platform: #{RUBY_PLATFORM}"
		end	
		if !done then
			raise "unable to open browser: #{path}"
		end
  end
  
  def FileUtil.isWindows()
  	return RUBY_PLATFORM.downcase.include?("mswin") || RUBY_PLATFORM.downcase.include?("mingw")
  end
  
  def FileUtil.isLinux()
  	return RUBY_PLATFORM.downcase.include?("linux")
  end

end
