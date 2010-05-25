# extensions to the kete video model

require 'kete_translatable_content/extensions/tagging_overides'

class Video
  include TaggingOverides
end
