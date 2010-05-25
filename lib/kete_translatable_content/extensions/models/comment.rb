# extensions to the kete comment model

require 'kete_translatable_content/extensions/tagging_overides'

class Comment
  include TaggingOverides
end
