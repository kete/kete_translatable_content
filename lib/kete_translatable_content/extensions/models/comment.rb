# extensions to the kete comment model

# require the model in Kete before reopening it below
Comment

require File.join(File.dirname(__FILE__), '../tagging_overrides')

class Comment
  include TaggingOverrides
end
