require 'socket'
require 'json'

module Hexcast
    class HTTPConnection
        def initialize(socket, method, uri)
            @baseSocket = socket
            @requestMethod = method
            @requestURI = uri
        end
        
        def handleVersionOneApi(view, controller, arguments)
            puts "handle called for #{view}, attempting load"
            first_load = require("hexcast/driver/#{view}")
            
            puts "first load? #{first_load}"
            
            driver_class = const_get(view)
            driver = driver_class.new(self)
            driver.verify_dependencies if first_load
            
            driver.handle(controller, arugments)
        rescue UserError
            raise
        rescue LoadError, NameError
            error("Cloud not load the '#{view}' driver. Please make sure it is installed and try again")
        end
        
        def respond(message)
            response = {:status => "success", :result => message, :timestamp => Time.now.to_i}
            response = response.to_json
            
            @baseSocket.print "HTTP/1.1 200 OK\r\n" +
                       "Content-Type: application/json\r\n" +
                       "Content-Length: #{response.bytesize}\r\n" +
                       "Connection: close\r\n\r\n"
            
            @baseSocket.print response
            @baseSocket.close
        end
        
        def error(message)
            response = {:status => "error", :error => message, :timestamp => Time.now.to_i}
            response = response.to_json
            
            @baseSocket.print "HTTP/1.1 200 OK\r\n" +
                       "Content-Type: application/json\r\n" +
                       "Content-Length: #{response.bytesize}\r\n" +
                       "Connection: close\r\n\r\n"
            
            @baseSocket.print response
            @baseSocket.close
        end
        
        def run()
            if @requestURI[0] == '/'
                @requestURI[0] = ''
            end
    
            model, view, controller, *arguments = @requestURI.split('/')
            
            puts "[#{@baseSocket.peeraddr[3]}] -> #{model} [#{view}] {#{controller}} ##{arguments}#".blue
            
            if model.nil?
                respond("Thanking you for using Hexcast v#{VERSION}, please check the usage documents for more help")
            else
                case model
                    when 'v1.0'
                        handleVersionOneApi(view, controller, arguments)
                    
                    else
                        error("I have no handler for #{model}, please check your documents and hexcast server version")
                end
            end
        end
    end
end