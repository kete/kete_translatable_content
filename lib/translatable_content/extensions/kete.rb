# overriding the system setting methods so we can pull translated versions out
# for translatable ones
class Kete
  class << self
    def localized_value_from(setting_id)
      return nil unless I18n.default_locale != I18n.locale

      SystemSetting.find(setting_id).constant_value
    end


    def define_reader_method_for(setting)
      var_name = setting.constant_name.downcase

      class_variable_set('@@' + var_name, setting.constant_value)

      # create the template code
      code = Proc.new {
        localize_value = nil
        if setting.takes_translations?
          localized_value = localized_value_from(setting.id)
        end
        value = localized_value || class_variable_get('@@' + var_name)
      }
   
      metaclass.instance_eval do
        define_method(var_name, &code)
      end

      # create predicate method if boolean
      eval_value = setting.constant_value
      if eval_value.kind_of?(TrueClass) || eval_value.kind_of?(FalseClass)
        metaclass.instance_eval do
          define_method("#{var_name}?", &code)
        end
      end 
    end
  end
end
