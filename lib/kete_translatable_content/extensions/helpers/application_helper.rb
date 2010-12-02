ApplicationHelper.module_eval do
  def display_label_for(field_or_choice)
    field_or_choice.label_translation_for(I18n.locale) || field_or_choice.label
  end

  def extras_after_title_headline
    version = (current_translatable_record.respond_to?(:version) && current_translatable_record.version)
    html = ''
    html += '<div style="display:inline; padding-top: 10px; margin-bottom: -7px;" id="translations">' + I18n.t('translations.available_in')
    html += '<ul class="horizontal-list">'
    
    raw_locale_links(:params => {:version => version }).each_with_index do |link, i|
      html += "<li#{' class="first"' if i == 0 }>"
      html += link[:link]

      if current_translatable_record.translation_for(link[:locale]) &&
          current_translatable_record.version.to_i != current_translatable_record.translation_for(link[:locale]).version.to_i
        html += '<span class="old">' + I18n.t('translations.old') + '</span>'
      end

      html += '</li>'
    end
    html += '<li id="translate">' + translate_link(current_translatable_record,
                                                   :lightbox => true, 
                                                   :params => {:version => version}) + '</li>'
    html += '</ul>
            </div>'
    html
  end
end
