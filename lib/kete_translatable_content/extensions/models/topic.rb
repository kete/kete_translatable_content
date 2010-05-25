# extensions to the kete topic model

require File.join(File.dirname(__FILE__), '../tagging_overides')

class Topic
  include TaggingOverides
end
