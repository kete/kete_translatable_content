TranslationsHelper.module_eval do
  def modify_translation_value(value, original_object)
    if original_object.class == ConfigurableSetting
      YAML.load(value)
    else
      value
    end
  end

  def localized_label_for(attribute_key)
    #Using the content_values because it's the only eash thing that matches the attribute key.
    extended_values = @original.extended_content_values
    if extended_values.keys.include?(attribute_key.to_s)
      return ExtendedField.params_to_label(attribute_key)
    else
      t(@translatable_class.name.tableize + '.' + 'form' + '.' + attribute_key.to_s)
    end
  end
end
