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
    extended_values = @original.extended_content_values if @original.respond_to?('extended_content_values')
    if extended_values && extended_values.keys.include?(attribute_key.to_s)
      return display_label_for(ExtendedField.find(:first, :conditions => ["label = ?" ,ExtendedField.params_to_label(attribute_key)]))
    else
      t(@translatable_class.name.tableize + '.' + 'form' + '.' + attribute_key.to_s)
    end
  end

    %w{untranslated translated}.each do |term|
    define_method(term + '_values_with_localized_labels') do
      set_original
      raise "No object supplied to translate." if @original.blank?
      raise "No matching translation available." if term == 'translated' && @translation.blank?

      @original.translatable_attributes.collect do |attribute_key|
        attribute_key = check_for_value_hash(attribute_key)
        value = (term == 'untranslated') ? @original.send(attribute_key) : @translation[attribute_key]
        { :attribute_key => attribute_key,
          :localized_label => localized_label_for(attribute_key),
          :value => modify_translation_value(value, @original) }
      end
    end
  end

  def check_for_value_hash(value)
    if  value.is_a?(Hash) && value.keys.include?('value') && value.keys.include?('label')
      value["label"]
    else
      value
    end
  end

end
