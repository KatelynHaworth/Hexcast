module Hexcast
    module Driver
        def self.load_driver(view, connection)
            if !File.file?(File.join(File.dirname(__FILE__), "drivers", "#{view}.rb"))
                connection.error("Could not load the '#{view}' driver. Please make sure it is installed and try again")
            else
                puts "handle called for #{view}, attempting to load: " + File.join(File.dirname(__FILE__), "drivers", "#{view}.rb")
                first_load = require(File.join(File.dirname(__FILE__), "drivers", "#{view}.rb"))
                
                puts "first load? #{first_load}"
                
                if !class_exists?(view)
                    connection.error("A file exists for '#{view}' driver but no class, please check your installed drivers")
                else
                    driver_class = const_get(view)
                    driver = driver_class.new(connection)
                    driver.verify_dependencies if first_load
                    driver
                end
            end
        end
        
        def self.class_exists?(class_name)
            ObjectSpace.each_object(Class) {|c| return true if c.to_s == class_name }
            false
        end
        
        class Base
            def new(connection)
                raise ClientError, "#{self.class}#new must be implemented"
            end
            
            def handle(controller, arguments)
                raise ClientError, "#{self.class}#handle must be implemented"
            end
        end
    end
end
