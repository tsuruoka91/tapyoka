class ApplicationController < ActionController::Base
  rescue_from Faraday::UnauthorizedError, with: :render_unauthorized
  rescue_from TapyrusApi::FileNotFound, with: :render_unauthorized
  rescue_from TapyrusApi::UrlNotFound, with: :render_not_found

  private

  def render_unauthorized
    render template: 'layouts/401', status: :unauthorized
  end

  def render_not_found
    render template: 'layouts/404', status: :not_found
  end
end
