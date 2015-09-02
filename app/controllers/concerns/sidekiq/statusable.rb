require 'active_support/concern'

module Sidekiq::Statusable
  extend ActiveSupport::Concern

  included do
    before_action :set_job_id, only: [:fetch_status]
  end

  def fetch_status
    render json: response_with_error_html.to_json
  end

  private

  def set_job_id
    @job_id = params[:job_id]
  end

  def sidekiq_status
    sidekiq_data
    @sidekiq_status ||= Sidekiq::Status::status(@job_id).to_s.camelize
    set_default_error if @sidekiq_status.blank?
    @sidekiq_status
  end

  def sidekiq_data
    @sidekiq_data ||= Sidekiq::Status::get_all @job_id
    set_default_status if @sidekiq_data['errors'].present?
    @sidekiq_data
  end

  def set_default_status
    @sidekiq_status = 'Failed'
  end

  def set_default_error
    sidekiq_data['errors'] = 'Something took a long time.'
  end

  def response_data
    @response_data ||= {
      status: sidekiq_status,
      id: sidekiq_data['id'],
      errors: sidekiq_data['errors'],
    }
  end

  def response_with_error_html
    response_data[:error_html] = render_to_string(
      partial: 'status_errors', formats: [:html],
      layout: false, locals: { errors: response_data[:errors] }
    ) if response_data[:errors].present?
    response_data
  end
end
