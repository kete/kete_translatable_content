AccountController.class_eval do
  def simple_return_tos
    # super + ['translations/new']
    ['find_related', 'translations/new']
  end
end
