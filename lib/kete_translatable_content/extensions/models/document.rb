# extensions to the kete document model

# require the model in Kete before reopening it below
Document

require File.join(File.dirname(__FILE__), '../tagging_overrides')
require File.join(File.dirname(__FILE__), '../oai_dc_helpers_overrides')

class Document
  include TaggingOverrides
  include OaiDcHelpersOverrides
end
