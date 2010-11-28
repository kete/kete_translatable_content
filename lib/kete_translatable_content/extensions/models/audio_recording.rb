# extensions to the kete audio recording model

# instantiate the model in Kete before reopening it below
AudioRecording

require File.join(File.dirname(__FILE__), '../tagging_overrides')
require File.join(File.dirname(__FILE__), '../oai_dc_helpers_overrides')

class AudioRecording
  include TaggingOverrides
  include OaiDcHelpersOverrides
end
