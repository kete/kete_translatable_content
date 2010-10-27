TranslationsHelper.module_eval do
  def modify_translation_value(value, original_object)
    if original_object.class == ConfigurableSetting
      YAML.load(value)
    else
      value
    end
  end

  def localized_label_for(attribute_key)
    if @original.extended_content_values.keys.include?(attribute_key.to_s)
      return @original.send(attribute_key)
    else
      t(@translatable_class.name.tableize + '.' + 'form' + '.' + attribute_key.to_s)
    end
  end
end
