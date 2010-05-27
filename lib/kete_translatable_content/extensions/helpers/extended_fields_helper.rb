# we only override specific extended field uses for translation
# rather than overriding find
ExtendedFieldsHelper.module_eval do
  def label_show_column(extended_field)
    translated_label = extended_field.label_translation_for(I18n.locale) || extended_field.label
    h(translated_label)
  end

  def example_show_column(extended_field)
    translated_example = extended_field.example_translation_for(I18n.locale) || extended_field.example
    h(translated_example)
  end

  def extended_field_example(extended_field)
    example_show_column(extended_field)
  end
end
