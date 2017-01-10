require 'active_support/concern'

module Products::Collection
  extend ActiveSupport::Concern

  included do
    before_filter :find_products, only: [:show]
    before_filter :paginate_collection, only: [:index]
  end

  def index
    @header ||= "all available #{params[:controller].pluralize}".titleize
    render "products/collection/index"
  end

  def show
    @header ||= instance.name.titleize
    respond_to do |format|
      format.json { render json: instance }
    end
    # render "products/collection/show", locals: { entity: params[:controller].singularize }
  end

  private

  def instance
    instance_variable_get("@#{params[:controller].singularize}") || scoped_model.find(params[:id])
  end

  def paginate_collection
    name = "@#{params[:controller].pluralize}"
    instance    = instance_variable_get name
    collection  = instance ? instance.page(params[:page]) : scoped_model.all
    @collection = instance_variable_set(name, collection.page(params[:page]))
  end

  def find_products
    instance_variable_set "@#{params[:controller].singularize}", instance
    method = instance.respond_to?(:all_products) ? :all_products : :products
    @products = instance.send(method).page params[:page]
  end

  def scoped_model
    model = params[:controller].singularize.classify.constantize
    model.respond_to?(:with_default_includes) ? model.with_default_includes : model
  end
end
