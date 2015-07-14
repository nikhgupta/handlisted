class ProviderDecorator < ApplicationDecorator
  def name
    model.name
  end

  def identifier
    name.underscore
  end
end
