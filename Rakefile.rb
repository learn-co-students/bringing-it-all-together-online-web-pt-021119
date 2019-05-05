require_relative 'config/environment.rb'

require 'pry'
require 'rake'

def reload!
	load 'lib/dog.rb'
end

task :console do
	Pry.start
end
