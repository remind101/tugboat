Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__))
Mongoid.logger = Shipr.logger
Mongoid.raise_not_found_error = false
