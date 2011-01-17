# for ITEM_CLASSES
# when new version is created to just add tags
# we want to update the version attribute of translations
# that matched previous version
# to new version number
module TaggingControllerOverrides
  unless included_modules.include? TaggingControllerOverrides
    # method that add-ons can define to do something after tags added
    def after_tags_added(options)
      logger.debug("what are after_tags added options: " + options.inspect)
      # get translations matching starting version
      translations = @item.class::Translation.all(@item.class.as_foreign_key_sym => @item.id,
                                                  :version => options[:starting_version].to_s)

      translations.each do |t|
        t.version = options[:ending_version].to_s
        t.save!
      end
    end
  end
end
