class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # Adds Hydra behaviors into the application controller
  include Hydra::Controller::ControllerBehavior
  # Adds Sufia behaviors into the application controller
  include Sufia::Controller

  #rescue_from ActiveFedora::ObjectNotFoundError, ActiveFedora::ActiveObjectNotFoundError do |exception|
  #  render '/errors/not_found', status: :not_found
  #end

  #rescue_from StandardError, with: :exception_handler
  def exception_handler(exception)
    if ActionDispatch::ExceptionWrapper.rescue_responses[exception.class.name]
      wrapper = ActionDispatch::ExceptionWrapper.new(env, exception)
      render_response_for_error(wrapper)
    else
      raise exception
    end
  end
  protected :exception_handler

  def set_return_location_from_status_code(status_code)
    if status_code == 401
      session['user_return_to'] = env['ORIGINAL_FULLPATH']
    end
  end

  protected :set_return_location_from_status_code

  def render_response_for_error(exception)
    set_return_location_from_status_code(exception.status_code)
    render "/errors/#{exception.status_code}", status: exception.status_code, layout: !request.xhr?
  end
  protected :render_response_for_error

  layout 'curate_nd/2_column'

  protect_from_forgery

  def show_action_bar?
    true
  end
  helper_method :show_action_bar?

  def show_site_search?
    true
  end
  helper_method :show_site_search?

  protected
  def agreed_to_terms_of_service!
    return false unless current_user
    if current_user.agreed_to_terms_of_service?
      return current_user
    else
      redirect_to new_terms_of_service_agreement_path
      return false
    end
  end

end
