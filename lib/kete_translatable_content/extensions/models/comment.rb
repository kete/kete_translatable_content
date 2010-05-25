# extensions to the kete comment model

require File.join(File.dirname(__FILE__), '../tagging_overides')

class Comment
  include TaggingOverides
end
