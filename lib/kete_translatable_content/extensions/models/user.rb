# extensions to the kete user model
class User
  def basket_permissions
    select = "roles.id AS role_id, roles.name AS role_name, baskets.id AS basket_id, baskets.urlified_name AS basket_urlified_name, baskets.name AS basket_name"
    join = "INNER JOIN baskets on roles.authorizable_id = baskets.id"
    permissions = roles.find_all_by_authorizable_type('Basket', :select => select, :joins => join)

    # query for matching translations for the baskets in one go
    basket_ids = permissions.collect { |p| p.basket_id.to_i }
    translations = Basket::Translation.all(:basket_id => basket_ids, :locale => I18n.locale.to_s)

    logger.debug("what is locale: " + I18n.locale.inspect )
    logger.debug("what are translations: " + translations.inspect )

    permissions_hash = Hash.new
    permissions.each do |permission|
      p = permission.attributes

      # grab the appropriate name for the basket based on locale
      translation = translations.select { |t| t.basket_id == p['basket_id'].to_i }.first
      p['basket_name'] = translation ? translation.name : p['basket_name']

      permissions_hash[p['basket_urlified_name'].to_sym] = {
        :id => p['basket_id'].to_i,
        :role_id => p['role_id'].to_i,
        :role_name => p['role_name'],
        :basket_name => p['basket_name']
      }
    end
    permissions_hash
  end
end
