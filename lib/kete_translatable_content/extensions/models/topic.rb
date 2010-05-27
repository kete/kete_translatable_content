# extensions to the kete topic model

# require the model in Kete before reopening it below
Topic

require File.join(File.dirname(__FILE__), '../tagging_overides')

class Topic
  include TaggingOverides
end
