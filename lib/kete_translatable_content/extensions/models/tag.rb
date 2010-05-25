# extensions to the kete tag model
class Tag
  # When creating a tag, check both the tags model, and tag translations
  # This is done so that for each tag we don't end up with additiona Tag
  # objects, but rather, the original tag object with multiple translations
  #
  # Example Usage:
  #
  # >> I18n.locale = :en
  # >> t = Tag.find_or_create_with_like_by_name('Welcome')
  # => #<Tag id: 1, name: "Welcome", locale: "en", original_locale: "en">
  # >> t.translate(:name => 'Accueil', :locale => :fr)
  # => #<Tag::Translation name: "Accueil", tag_id: 1, _id: ObjectID('4bfb1a87f42ce12372000002'), locale: "fr", translatable_locale: "en">
  #
  # >> I18n.locale = :fr
  # >> Tag.find_or_create_with_like_by_name('Accueil')
  # => #<Tag id: 1, name: "Accueil", locale: "fr", original_locale: "en">

  # redefine so if no tag is found initially, we look for translations too
  # this method is used by acts-as-taggable-on for all creations of tags
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
