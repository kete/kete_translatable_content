# Keep this file are bare as possible as it is used in migrations and routes
# and does not need to pull in mongo libs or adjust view paths. Such code
# should be done in ../rails/init.rb

TRANSLATABLES = YAML.load(IO.read(File.join(File.dirname(__FILE__), '../config/translatables.yml')))
