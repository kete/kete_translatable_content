# extensions to the kete document model

require File.join(File.dirname(__FILE__), '../tagging_overides')

class Document
  include TaggingOverides
end
