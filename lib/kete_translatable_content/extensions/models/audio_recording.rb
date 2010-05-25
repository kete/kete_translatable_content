# extensions to the kete audio recording model

require File.join(File.dirname(__FILE__), '../tagging_overides')

class AudioRecording
  include TaggingOverides
end
