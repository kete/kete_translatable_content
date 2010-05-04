require 'mongo_translatable'

TRANSLATABLES = YAML.load(IO.read(File.join(File.dirname(__FILE__), '../config/translatables.yml')))

