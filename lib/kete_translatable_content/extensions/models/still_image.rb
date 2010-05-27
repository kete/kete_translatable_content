# extensions to the kete still image model

# require the model in Kete before reopening it below
StillImage

require File.join(File.dirname(__FILE__), '../tagging_overides')

class StillImage
  include TaggingOverides
end
