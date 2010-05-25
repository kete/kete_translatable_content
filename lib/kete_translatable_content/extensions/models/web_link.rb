# extensions to the kete web link model

require File.join(File.dirname(__FILE__), '../tagging_overides')

class WebLink
  include TaggingOverides
end
