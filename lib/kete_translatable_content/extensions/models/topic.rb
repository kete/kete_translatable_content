# extensions to the kete topic model

# require the model in Kete before reopening it below
Topic

require File.join(File.dirname(__FILE__), '../tagging_overrides')
require File.join(File.dirname(__FILE__), '../oai_dc_helpers_overrides')

class Topic
  include TaggingOverrides
  include OaiDcHelpersOverrides
end
