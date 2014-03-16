$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
require 'bubble-wrap'

$:.unshift("./lib/")
require './lib/motion_file_store'

Motion::Project::App.setup do |app|
  app.name = 'MotionFileStore'
end

task :spec do
  App.config.spec_mode = true
  spec_files = App.config.spec_files
  App.config.instance_variable_set("@spec_files", spec_files)
  Rake::Task["simulator"].invoke
end
