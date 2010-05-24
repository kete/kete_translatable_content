ApplicationHelper.module_eval do
  def display_label_for(field_or_choice)
    translated_label = field_or_choice.label_translation_for(I18n.locale) || field_or_choice.label
  end
end
