ApplicationHelper.module_eval do
  # lighboxes only used when user is logged in
  def lightbox?
    logged_in?
  end

  def tags_for(item)
    html_string = String.new

    return html_string if item.tags.blank?

    html_string = "<p>#{t('application_helper.tags_for.tags')} "
    item_tags = item.tags

    item_tags.each_with_index do |tag,index|
      html_string += link_to_tagged(tag, item.class.name)

      # since tags-list is cached,
      # we have to assume the user is logged out, use false for lightbox

      # all we need to know is whether this tag is in the I18n.locale
      # if not, provide translate link
      unless tag.locale == I18n.locale
        html_string += '<sup class="badge">' +
          translate_link(tag,
                         :lightbox => false,
                         :action => 'new') +
          '</sup>'
      end

      html_string += ", " unless item_tags.size == (index + 1)
    end
    html_string += "</p>"

    html_string
  end

  def display_label_for(field_or_choice)
    field_or_choice.label_translation_for(I18n.locale) || field_or_choice.label
  end

  def combined_tranlation_links
    version = (current_translatable_record.respond_to?(:version) && current_translatable_record.version)
    html = ''
    html += '<div class="content-wrapper-submenu" id="translations">' + I18n.t('translations.available_in')
    html += '<ul class="horizontal-list">'
    
    available_locale_links = raw_available_in_locales_links(current_translatable_record, :params => {:version => version })

    available_locales = available_locale_links.collect { |link| link[:locale].to_s }

    available_locale_links.each_with_index do |link, i|
      html += "<li#{' class="first"' if i == 0 }>"
      html += link[:link]

      unless link[:locale] == current_translatable_record.original_locale
        record_translation_for_locale = current_translatable_record.translation_for(link[:locale])

        if record_translation_for_locale &&
            current_translatable_record.version.to_i > record_translation_for_locale.version.to_i
          html += '<sup class="badge">' + I18n.t('translations.old') + '</sup>'
          # drop locale from available_locales, so we get the translate link
          available_locales.delete(link[:locale].to_s)
        end
      end

      html += '</li>'
    end

    if current_translatable_record.original_locale != I18n.locale &&
        !available_locales.include?(I18n.locale.to_s)
      html += '<li id="translate">' + translate_link(current_translatable_record,
                                                     :lightbox => lightbox?,
                                                     :action => 'new',
                                                     :params => {:version => version}) + '</li>'
    elsif current_translatable_record.original_locale == I18n.locale && available_locales.size == 1
      other_locales = TranslationsHelper::available_locales.keys - [current_translatable_record.original_locale]

      html += '<li id="translate">' + translate_link(current_translatable_record,
                                                     :lightbox => lightbox?,
                                                     :action => 'new',
                                                     :params => {:version => version,
                                                       :to_locale => other_locales.first}) + '</li>'
    end

    translations_params = Hash.new
    params.each do |k,v|
      translations_params[k] = v unless %w(action controller id).include?(k.to_s)
    end

    manage_links = manage_translations_links_for(current_translatable_record,
                                                 available_locales - [current_translatable_record.original_locale],
                                                 { :params => translations_params })

    html += '<li id="manage-translations">(' + manage_links + ')</li>' if manage_links.present? && @at_least_a_moderator

    html += '</ul>
            </div>'

    translatable_lightbox_js_and_css

    html
  end

  def add_ons_item_form_beginning(form=nil)
    return unless form
    locale_dropdown(form, :default => I18n.locale) 
  end
  
end
