class ApplicationController < ActionController::API
  def process_action(*args)
    super
  rescue ActionDispatch::Http::Parameters::ParseError => exception
    render json: {status: "Error", message: "Invalid JSON payload"}, status: :bad_request
  end
end
