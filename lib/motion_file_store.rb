unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

LOG_IN_MOTION_FILENAME ||= 'logger.txt'
LOG_IN_MOTION_LEVEL ||= 2

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'motion_file_store/*.rb')).each do |file|
    app.files.unshift(file)
  end
end
