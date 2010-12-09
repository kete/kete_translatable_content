ApplicationHelper.module_eval do
  def display_label_for(field_or_choice)
    field_or_choice.label_translation_for(I18n.locale) || field_or_choice.label
  end

  def extras_after_title_headline
    version = (current_translatable_record.respond_to?(:version) && current_translatable_record.version)
    html = ''
    html += '<div style="display:inline; padding-top: 10px; margin-bottom: -7px;" id="translations">' + I18n.t('translations.available_in')
    html += '<ul class="horizontal-list">'
    
    available_locale_links = raw_available_in_locales_links(current_translatable_record, :params => {:version => version })
    available_locales = available_locale_links.collect { |link| link[:locale].to_s }

    available_locale_links.each_with_index do |link, i|
      html += "<li#{' class="first"' if i == 0 }>"
      html += link[:link]

      if current_translatable_record.translation_for(link[:locale]) &&
          current_translatable_record.version.to_i != current_translatable_record.translation_for(link[:locale]).version.to_i
        html += '<sup class="badge">' + I18n.t('translations.old') + '</sup>'
        # drop locale from available_locales, so we get the translate link
        available_locales.delete(link[:locale].to_s)
      end

      html += '</li>'
    end
    if current_translatable_record.original_locale != I18n.locale && !available_locales.include?(I18n.locale.to_s)
      html += '<li id="translate">' + translate_link(current_translatable_record,
                                                     :lightbox => true, 
                                                     :params => {:version => version}) + '</li>'
    end
    html += '</ul>
            </div>'
    html
  end
end
