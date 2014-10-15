require 'colorize'
load 'HTTPServer.rb'
load 'HTTPConnection.rb'
load 'version.rb'

module Hexcast
    puts "----> Starting Hexcast API server v#{VERSION}".green
    puts "----* Server is going to be on #{ENV['IP']}:#{ENV['PORT']}".green
   
    ## maybe   
    #puts "----* Loading server drivers form #{File.dirname(__FILE__) + "/drivers/"}".green
    #Dir[File.dirname(__FILE__) + "/drivers/*.rb"].each {|file| require file }
    
    server = Hexcast::HTTPServer.new(ENV['IP'], ENV['PORT'])
    server.run()
end