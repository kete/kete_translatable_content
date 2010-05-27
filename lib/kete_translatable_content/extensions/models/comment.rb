# extensions to the kete comment model

# require the model in Kete before reopening it below
Comment

require File.join(File.dirname(__FILE__), '../tagging_overides')

class Comment
  include TaggingOverides
end
