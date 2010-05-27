TranslationsHelper.module_eval do
  def modify_translation_value(value, original_object)
    if original_object.class == ConfigurableSetting
      YAML.load(value)
    else
      value
    end
  end
end
