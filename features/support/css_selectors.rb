module CssSelectors
  def provider_icon_for(provider)
    first "a.btn-social.#{provider.camelize.parameterize}"
  end

  def add_identity_for(provider)
    first(".add_identities .icon-#{provider}")
  end
end

World(CssSelectors)
