TranslationsHelper.module_eval do
  def modify_translation_value(value, original_object)
    if original_object.class == ConfigurableSetting
      YAML.load(value)
    else
      value
    end
  end

  def localized_label_for(attribute_key)
    @localized_labels ||= Hash.new
    return @localized_labels[attribute_key] if @localized_labels[attribute_key].present?

    extended_content_keys = nil
    if @original.respond_to?('extended_content_pairs')
      extended_content_keys = @original.extended_content_pairs.collect { |p| p[0] }
    end

    if extended_content_keys &&
        (extended_content_keys.include?(attribute_key.to_s) ||
         extended_content_keys.include?(attribute_key.to_s + '_multiple'))

      ef = ExtendedField.find(:first,
                              :conditions => ExtendedField.clauses_for_has_label_that_matches(attribute_key))

      @localized_labels[attribute_key] = display_label_for(ef)
    else
      @localized_labels[attribute_key] = t(@translatable_class.name.tableize + '.' + 'form' + '.' + attribute_key.to_s)
    end

    @localized_labels[attribute_key]
  end

    %w{untranslated translated}.each do |term|
    name = term + '_values_with_localized_labels'
    define_method(name) do
      set_original
      raise "No object supplied to translate." if @original.blank?
      raise "No matching translation available." if term == 'translated' && @translation.blank?

      existing_value = instance_variable_get('@' + name)
      return existing_value if existing_value.present?

      new_value = @original.translatable_attributes.collect do |attribute_key|
        logger.debug("inside un/translated for attribute key: " + attribute_key.inspect + " and term is " + term.inspect)
        attribute_key = check_for_value_hash(attribute_key)
        value = (term == 'untranslated') ? @original.send(attribute_key) : @translation[attribute_key]
        { :attribute_key => attribute_key,
          :localized_label => localized_label_for(attribute_key),
          :value => modify_translation_value(value, @original) }
      end

      instance_variable_set('@' + name, new_value)
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
