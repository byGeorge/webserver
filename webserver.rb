#!/usr/bin/env ruby

require 'socket'
require 'resolv'
require 'uri'
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
			@client.puts("Server: HAL the Confused Space-ship")
			@client.puts("Content-Type: CONTENT TYPE GOES HERE")
			@client.puts("Content-Length: #{file_contents.length}")
			@client.puts("")
			@client.print(file_contents)
			#I don't need to close it because I support persistent connections
			lfile = "#{@client.peeraddr[3]} [#{Time.new.httpdate}] \"#{request.to_s.strip!}\" 200 #{file_contents.size}"
	    	#log the request
	    	log_file(lfile)
	    	#persistent connection

	    	break if request.include?("Connection: close")
	    end
	    #close the client. That's important.
	    @client.close 

	rescue => e
		p e
		puts e.backtrace
		#if e.message == "404" do stuff
		@client.close
	end

	def platter(request)
		file_contents = "oops"
		#split the first line string into substrings
		@req = request.each_line.first.split(' ')
		#if there's not three arguments
		if @req.count != 3
			raise "400"
		#if it starts with 'GET'
		elsif @req[0] == 'GET' && @req[2] == "HTTP/1.1"
			# if it's a simple GET request [client typed "GET HTTP/1.1"]
			if @req[1] == '/'
			# if it's a GET request with a web address [client typed "GET something HTTP/1.1"]
			elsif @req[2] == "HTTP/1.1"
				begin
					file_contents = File.open(PATH + @req[1]) do |stream| 
						stream.set_encoding('ASCII-8BIT')
						stream.read
					end
				rescue
					raise "404"
				end
			end #end if http/1.1
		else
			#otherwise it's not a valid request
			raise "400"
		end  #end if get
		file_contents
	end #end get_status
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
	#try to accept client
 	#client = server.accept 

 	#get the client request
 	#request = (client.gets) 
 	#addr = client.peeraddr[2]	

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

 	#and close connection
end

#don't leave the log file open!
$log.close
