# extensions to the kete topic model

require 'kete_translatable_content/extensions/tagging_overides'

class Topic
  include TaggingOverides
end
