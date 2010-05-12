# overriding the system setting methods so we can pull translated versions out
# for translatable ones
class Kete
  class << self
    def define_reader_method_for(setting)
      method_name = setting.constant_name.downcase

      class_variable_set('@@' + method_name, SystemSetting.find_by_name(setting.name).constant_value)

      # create the template code
      code = Proc.new {
        method_name = method_name.sub('?', '') if method_name.include?('?')

        value = nil
        if setting.takes_translations? && I18n.locale != I18n.default_locale
          value = SystemSetting.find_by_name(setting.name).constant_value
        else
          value = class_variable_get('@@' + method_name)
        end
      }
   
      metaclass.instance_eval { define_method(method_name, &code) }

      # create predicate method if boolean
      eval_value = setting.constant_value
      if eval_value.kind_of?(TrueClass) || eval_value.kind_of?(FalseClass)
        metaclass.instance_eval { define_method("#{method_name}?", &code) }
      end 
    end
  end
end
