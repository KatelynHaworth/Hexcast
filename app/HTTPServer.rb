require 'socket'
require 'colorize'
require 'json'

module Hexcast
    class HTTPServer
        def initialize(host, port)
            @server = TCPServer.new(host, port)
            @connectionThreads = []
            puts "----* Server in now bound on #{host}:#{port}".green
        end
        
        def run()
            puts '----> The server is now online and ready!'.yellow
            
            loop do
                socket = @server.accept
                request = socket.gets.gsub("\r\n",'')
                
                httpMethod, reqURI = request.split(' ')
             
                puts "----> Client connected from [#{socket.peeraddr[3]}] and requested [#{reqURI}] with method [#{httpMethod}]".blue
                
                connectionHandler = Hexcast::HTTPConnection.new(socket, httpMethod, reqURI)
                @connectionThreads << Thread.new {connectionHandler.run()}
            end
        end
    end
end