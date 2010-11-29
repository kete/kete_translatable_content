# extensions to the kete web link model

# require the model in Kete before reopening it below
WebLink

require File.join(File.dirname(__FILE__), '../tagging_overrides')
require File.join(File.dirname(__FILE__), '../oai_dc_helpers_overrides')

class WebLink
  include TaggingOverrides
  include OaiDcHelpersOverrides
end
