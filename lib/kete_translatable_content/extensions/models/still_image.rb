# extensions to the kete still image model

# require the model in Kete before reopening it below
StillImage

require File.join(File.dirname(__FILE__), '../tagging_overrides')
require File.join(File.dirname(__FILE__), '../oai_dc_helpers_overrides')

class StillImage
  include TaggingOverrides
  include OaiDcHelpersOverrides
end
