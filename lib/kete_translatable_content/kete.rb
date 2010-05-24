# overriding the system setting methods so we can pull translated versions out
# for translatable ones
class Kete
  class << self
    def localized_value_from(setting_id)
      return nil unless I18n.default_locale != I18n.locale

      SystemSetting.find(setting_id).constant_value
    end

    def reader_proc_for(setting)
      method_name = setting.constant_name.downcase

      Proc.new {
        if setting.respond_to?(:takes_translations?) && setting.takes_translations?
          localized_value = localized_value_from(setting.id)
          return localized_value if localized_value
        end

        method_name = method_name.sub('?', '') if method_name.include?('?')
        class_variable_get('@@' + method_name)
      }
    end
  end
end
