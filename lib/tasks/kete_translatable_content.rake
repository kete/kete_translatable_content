namespace :kete_translatable_content do
  desc "After running the migration, all records also need a locale value.  Assumes single locale site up till this point."
  task :update_with_default_locale  => :environment do
    Basket.record_timestamps = true
    Basket.all.each do |basket|
      basket.update_attributes!({ :do_not_sanitize => true, :locale => I18n.default_locale.to_s, :original_locale => I18n.default_locale.to_s})
    end
    Basket.record_timestamps = false
  end
end
