SearchHelper.module_eval do
  def tag_show_link_options(tag)
    { :title => t('search_helper.tag_show_link_options.title_with_translations', :tag_name => tag.name) }
  end
end
