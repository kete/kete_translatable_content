# extensions to the kete tag model
class Tag
  # redefine so if no tag is found initially, we look for translations too
  def self.find_or_create_with_like_by_name(name)
    # first, see if any tags exist with this name
    existing_tag = first(:conditions => ["name LIKE ?", name])

    # if no tag exists, look through tag translations for the current locale
    if !existing_tag && existing_tag = Tag::Translation.first(:name => name, :locale => I18n.locale)
      # if a translation is found, return the original Tag object, but with the values of the locale
      existing_tag = Tag.swap_in_translation_for_single(existing_tag.translatable)
    end

    existing_tag || create(:name => name, :locale => I18n.locale)
  end
end
