#!/usr/bin/env ruby

require 'socket'
require 'time'

PATH = 'stuff/'
# ruby magic to make \n into \r\n
$/ = "\r\n"

class WebServer

	#initialize gets called at WebServer.new
	# @variable allows the thread to share data
	def initialize(client)

		#client connection and request(request)
		@client = client
	end

	def serve()
		loop do
			#will read entire request
			request = @client.gets("\r\n\r\n")
			#assumes size of resource is 0 until told otherwise
			@size = 0

			file_contents = platter(request)
			@client.puts("HTTP/1.1 200 OK")
			@client.puts("Last-Modified: #{Time.new.httpdate}")
			@client.puts("Server: HAL the Confused Spaceship")
			@client.puts("Content-Type: #{get_content_type(@req[1]) unless @req[1] == '/'}")
			@client.puts("Content-Length: #{file_contents.length}")
			@client.puts("")
			@client.print(file_contents)
			#I don't need to close it because I support persistent connections

			#create log string
			lfile = "#{@client.peeraddr[3]} [#{Time.new.httpdate}] \"#{@req.join(" ")}\" 200 #{file_contents.size}"
	    	#log the request
	    	log_file(lfile)
	    	#persistent connection
	    	break if request.include?("Connection: close")
	    end
	    #close the client. That's important.
	    @client.close 
	#rescue is one of the ways that Ruby handles exceptions
	rescue => e
		if e.message == "404" # if it's a 404 error
			#create log string
			lfile = "#{@client.peeraddr[3]} [#{Time.new.httpdate}] \"#{@req.join(" ")}\" 404 0"
	    	#log the request
	    	log_file(lfile)
	    elsif e.message == "400" # if it's a 400 error
	    	
	    else
	    	#something else went wrong
			p e
			puts e.backtrace
	    end
		@client.close
	end

	def platter(request)
		file_contents = ""
		#split the first line string into substrings
		@req = request.each_line.first.split(' ')
		#if there's not three arguments
		if @req.count != 3
			#if the request wasn't formatted correctly, raise exception 400
			raise "400"
		#if it starts with 'GET'
		elsif @req[0] == 'GET' && @req[2] == "HTTP/1.1"
			# if it's a simple GET request [client typed "GET HTTP/1.1"]
			if @req[1] == '/'
			# if it's a GET request with a web address [client typed "GET something HTTP/1.1"]
			elsif @req[2] == "HTTP/1.1"
				begin
					file_contents = File.open(PATH + @req[1]) do |stream| 
						#make sure the stream is binary
						stream.set_encoding('ASCII-8BIT')
						#the nice thing about ruby is that you know exactly what the next line does
						stream.read
					end
				rescue
					#if the resource is not found, throw an exception 404
					raise "404"
				end
			end #end if http/1.1
		else
			#otherwise it's not a valid request
			raise "400"
		end  #end if get
		file_contents
	end #end get_status

	def get_content_type(file)
		ext = File.extname(file)
		if ext == ".txt" || ext == ".rtf" || ext == ".doc"
			type = "text/plain" 
		elsif ext == ".gif"
			type = "image/gif" 
		elsif ext == ".jpg" || ext == ".jpeg"
			type = "image/jpeg" 
		elsif ext == ".png"
			type = "image/png" 
		elsif ext == ".HTML"
			type = "text/html" 
		else
			type = "unknown"
		end
	end
end

#logger
def log_file(entry)
	#prints out the log entry, then puts it into the log unless file can't be found
	puts entry
	$log.puts entry unless $log == nil
end

#File.open either opens a file or creates one if it doesn't already exist
#the second parameter, a, means that it allows read/write access. The first parameter
#is the file name, and could be /home/HAL/quoththewebserv/404.txt (but isn't)
$log = File.open(('logfile'), "a")

#start up a server
server = TCPServer.new 2880 

#run loop that listens for client requests
loop do
 	#service client on a new thread
 	Thread.start(server.accept) do |client|
 		begin 
    		WebServer.new(client).serve()
    	#this is here for error checking, please pay it no mind
   		rescue => e
   			#no really... pe sucks
    		p e
    		puts e.backtrace
    	end
    end
end

#don't leave the log file open!
$log.close
