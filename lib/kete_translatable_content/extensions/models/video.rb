# extensions to the kete video model

# require the model in Kete before reopening it below
Video

require File.join(File.dirname(__FILE__), '../tagging_overrides')

class Video
  include TaggingOverrides
end
