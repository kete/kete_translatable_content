# extensions to the kete video model

require File.join(File.dirname(__FILE__), '../tagging_overides')

class Video
  include TaggingOverides
end
