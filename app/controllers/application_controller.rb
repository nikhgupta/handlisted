class ApplicationController < ActionController::Base
  include Pundit
  serialization_scope :view_context

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def after_sign_in_path_for(resource_or_scope)
    root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    products_path
  end

  def self.set_pagination_headers(name, options = {})
    after_filter(options) do |controller|
      results    = instance_variable_get("@#{name}")
      headers["X-#{name.to_s.singularize.titleize}-Pagination"] = {
        resource: name,
        header: "X-#{name.to_s.singularize.titleize}-Pagination",
        total: results.total_count,
        total_pages: results.total_pages,
        first_page: results.current_page == 1,
        last_page: results.next_page.blank?,
        previous_page: results.prev_page,
        next_page: results.next_page,
        out_of_bounds: results.out_of_range?,
        offset: results.offset_value
      }.to_json
    end
  end
end
