# extensions to the kete video model

# require the model in Kete before reopening it below
Video

require File.join(File.dirname(__FILE__), '../tagging_overides')

class Video
  include TaggingOverides
end
