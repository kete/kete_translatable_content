# we only override specific extended field uses for translation
# rather than overriding find
ExtendedFieldsHelper.module_eval do
  def extended_field_example(extended_field)
    translated_example = extended_field.example_translation_for(I18n.locale) || extended_field.example
    h(translated_example)
  end
end
