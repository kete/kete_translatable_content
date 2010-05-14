# convenience methods for setting translatable system settings
class SystemSetting
  def self.update_translatables
    Kete.translatable_system_settings.each { |name| SystemSetting.find_by_name(name).make_translatable }
  end
  def make_translatable
    update_attributes!(:takes_translations => true)
  end
end

