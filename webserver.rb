#!/usr/bin/env ruby

require 'socket'
require 'resolv'
require 'uri'

class WebServer

	#initialize gets called at WebServer.new
	# @variable allows the thread to share data
	def initialize(request, client)

		#client connection and request(request)
		@client = client
		@request = request
		#assumes size of resource is 0 until told otherwise
		@size = 0
	end

	def serve()
		
		lfile = client.peeraddr[2] + " " + "[" + Time.now.to_s + "]" + " \"" + request.to_s.strip! + "\" "
    	lfle += @status + " " + @size
		Webserver.get_status
		puts @status
    	#log the request
    	log_file(lfile)
	end

	def get_status
		#split the string into substrings
		@req = @request.split(' ')
		#if it starts with 'GET'
		if @req[0] == 'GET'
			#just a get statement? invalid request [client typed "GET" and nothing else]
			if @req[1].nil?
				@status = "400"
			# if it's a simple GET request [client typed "GET HTTP/1.1"]
			elsif @req[1] == "HTTP/1.1"
				@status = "200"
			# another way to get an invalid request [Client typed "GET something "]
			elsif @req[2].nil?
				@status = "400"
			# if it's a GET request with a web address [client typed "GET something HTTP/1.1"]
			elsif @req[2] == "HTTP/1.1"
				#check to make sure it's a real web address, and we are assuming it's an ipv4
				#new IP address (don't throw exception). check if nil return 404 : otherwise 200
				req[1] =~ Resolv::IPv4::Regex ? @status = "404" : @status = "200"
			end #end if http/1.1
		else
			#otherwise it's not a valid request
			@status = "400"
		end  #end if get
	end
end

#logger
def log_file(entry)
	#prints out the log entry, then puts it into the log unless file can't be found
	puts entry
	$log.puts entry unless $log == nil
end

#File.open either opens a file or creates one if it doesn't already exist
#the second parameter, w+, means that it allows read/write access. The first parameter
#is the file name, and could be /home/HAL/quoththewebserv/404.txt (but isn't)
$log = File.open(('logfile'), "w+")

#start up a server
server = TCPServer.new 2880 

#run loop that listens for client requests
loop do
	#try to accept client
 	client = server.accept 

 	#get the client request
 	request = (client.gets) 	

 	#service client on a new thread
 	Thread.start(client, request) do |client, request|

    	WebServer.new(client, request).serve()
    end

 	#and close connection
  	client.close
end

#don't leave the log file open!
$log.close
