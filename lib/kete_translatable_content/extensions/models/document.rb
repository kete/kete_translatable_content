# extensions to the kete document model

require 'kete_translatable_content/extensions/tagging_overides'

class Document
  include TaggingOverides
end
