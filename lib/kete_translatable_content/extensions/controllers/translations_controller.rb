TranslationsController.class_eval do
  uses_tiny_mce :options => Kete.translatable_tiny_mce_options, :only => %w{ new edit }

  include WorkerControllerHelpers

  after_filter :expire_locale_cache, :only => [:create, :update]
  after_filter :update_zoom_record_if_applicable, :only => [:create, :update]

  def edit
    @translation = @translated.translation_for(params[:id]) || @translatable_class::Translation.find(params[:id])
    if @translated.respond_to?("version")
      @translation = @translated.translate(:locale => (params[:to_locale] || I18n.locale.to_s)) unless @translation.version.to_i == @translated.version.to_i
    end

    render :template => "translations/versioned_edit"
  end

  # POST /translations
  # POST /translations.xml
  def create
    translation_params = params[:translation] || params[@translatable_params_name + '_translation']
    params[:version] ||= params[@translatable_key][:version] if params[@translatable_key]
    translation_params[:version] = params[:version].to_i if params[:version]
    @translation = @translatable.translate(translation_params)

    respond_to do |format|
      if @translation.save
        flash[:notice] = t('translations.controllers.created')
        # we redirect to translated object in the new translated version
        # assumes controller name is tableized version of class
        format.html { redirect_to url_for_translated(:locale => I18n.locale) }
        # TODO: adjust :location accordingly for being a nested route
        format.xml  { render :xml => @translation, :status => :created, :location => @translation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @translation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /translations/1
  # PUT /translations/1.xml
  def update
    respond_to do |format|
      translation_params = params[:translation] || params[@translatable_params_name + '_translation']
      params[:version] ||= params[@translatable_key][:version] if params[@translatable_key]
      translation_params[:version] = params[:version].to_i if params[:version]
      if @translation.update_attributes(translation_params)
        flash[:notice] = t('translations.controllers.updated')
        format.html { redirect_to url_for_translated(:locale => I18n.locale) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @translation.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def get_translation
    @translation = @translated.translation_for(params[:id]) || @translatable_class::Translation.find(params[:id])
    if @translated.respond_to?("version")
      @translation = @translated.translate(:locale => (params[:to_locale] || I18n.locale.to_s)) unless @translation.version.to_i == @translated.version.to_i
    end
  end

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
    @translatable = @translation.respond_to?("translatable") ? @translation.translatable : @translation
    if ITEM_CLASSES.include?(@translatable_class.to_s)
      expire_show_caches_for(@translatable)

      #Clear out the available for_list which may be updated
      clear_header_fragments_for(@translated)
      @translatable.translations.each do |translation|
        clear_header_fragments_for(translation.translatable)
      end

      return true
    elsif @translatable.is_a?(Tag)
      # we need to expire the tag part
      # for everything with that tag
      @translatable.taggings.each do |tagging|
        item = tagging.taggable

        # sort of redundent, but achieves what we want
        item.locale = @translatable.locale

        controller = zoom_class_controller(item.class.name)
        part = 'secondary_content_tags_[privacy]'
        resulting_part = cache_name_for(part, 'public')
        expire_fragment_for_all_versions_and_locale(item, { :controller => controller, :action => 'show', :id => item, :part => resulting_part })
        resulting_part = cache_name_for(part, 'private')
        expire_fragment_for_all_versions_and_locale(item, { :controller => controller, :action => 'show', :id => item, :part => resulting_part })
      end
    else
      expire_all_locale_caches
    end
  end

  def clear_header_fragments_for(item)
    item_class = item.class.name
    controller = zoom_class_controller(item_class)
    @privacy_type ||= (item.private? ? "private" : "public")
    return unless ITEM_CLASSES.include?(item_class)
    part = 'details_first_[privacy]'
    resulting_part = cache_name_for(part, @privacy_type)
    expire_fragment_for_all_versions_and_locale(item, { :controller => controller, :action => 'show', :id => item, :part => resulting_part })
  end

  def expire_fragment_for_all_versions_and_locale(item, name = {})
    #blank title or url_for comes up with something it shouldn't
    name[:id].title = ""  if name[:id].title

    name = name.merge(:id => item.id)
    
    file_path = "#{RAILS_ROOT}/tmp/cache/#{fragment_cache_key(name).gsub(/(\?|:)/, '.')}.cache"
    file_path.sub!("\/#{@translatable.locale}\/", "\/#{item.locale}\/")
    File.delete(file_path) if File.exists?(file_path)
  end

  def expire_all_locale_caches
      # this is the big hammer for translation clearing # it does the entire locale's cache if a translation changes
      # only use on UI element related models
      # Kete items (i.e. user generated content) should be done on an item by item basis
      expire_locale = @translatable.locale
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

  # filter that will trigger zoom record rebuild for translatable
  # if translatable.class is in ITEM_CLASSES
  def update_zoom_record_if_applicable
    @translatable = @translation.respond_to?("translatable") ? @translation.translatable : @translation
    if ITEM_CLASSES.include?(@translatable.class.name)
      rebuild_zoom_for_translatable
    end
  end

  def rebuild_zoom_for_translatable
    method_name = "rebuild_zoom_record_for"
    options = { :item => @translatable }
    
    worker_type = :generic_muted_worker
    worker_key = worker_key_for("generic_muted_worker_#{method_name}_#{@translatable_class.to_s}_#{@translatable.id}")

    # only allow a single cache clearing to happen at once
    MiddleMan.new_worker( :worker => worker_type,
                          :worker_key => worker_key )

    MiddleMan.worker(worker_type, worker_key).async_do_work( :arg => { :method_name => method_name, :options => options } )
    true
  end
end
