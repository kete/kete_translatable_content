# extensions to the kete video model

# require the model in Kete before reopening it below
Video

require File.join(File.dirname(__FILE__), '../tagging_overrides')
require File.join(File.dirname(__FILE__), '../oai_dc_helpers_overrides')

class Video
  include TaggingOverrides
  include OaiDcHelpersOverrides
end
