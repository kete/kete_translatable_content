TranslationsController.class_eval do
  uses_tiny_mce :options => Kete.translatable_tiny_mce_options, :only => %w{ new edit }

  include WorkerControllerHelpers

  after_filter :expire_locale_cache, :only => [:create, :update]

  private

  %w{translatable translated}.each do |term|
    define_method("get_" + term) do
      params[:version] ||= params[@translatable_key][:version] if params[@translatable_key]
      if params[:version]
        value = @translatable_class.find(params[@translatable_key])
        value.revert_to(params[:version].to_i)
      else
        value = @translatable_class.find(params[@translatable_key])
      end

      instance_variable_set("@" + term, value)
    end
  end

  #Expire the cache of documents related to this record works on 
  #a wider scale if the record is relevant to the global UI.
  def expire_locale_cache
    #Kete items to be cleared individually
    if ZOOM_CLASSES.include?(@translatable_class.to_s)
      expire_show_caches_for(@translation)
      return true
    else
      # this is the big hammer for translation clearing # it does the entire locale's cache if a translation changes
      # only use on UI element related models
      # Kete items (i.e. user generated content) should be done on an item by item basis
      expire_locale = @translation.locale
      method_name = "clear_locale_cache"
      options = { :locale_to_clear => expire_locale }

      worker_type = :generic_muted_worker
      worker_key = worker_key_for("generic_muted_worker_#{method_name}_#{expire_locale}")

      # only allow a single cache clearing to happen at once
      MiddleMan.new_worker( :worker => worker_type,
                           :worker_key => worker_key )

      MiddleMan.worker(worker_type, worker_key).async_do_work( :arg => { :method_name => method_name, :options => options } )
      true
    end
  end
end
