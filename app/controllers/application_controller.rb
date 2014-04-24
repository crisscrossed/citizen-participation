class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :sidebar
  #after_filter :store_location

  layout :layout_by_resource

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Sie haben leider keine Berechtigung diese Seite zu sehen"

    if user_signed_in?
      redirect_to root_url
    else
      session['user_return_to'] = request.fullpath
      redirect_to new_user_session_path
    end
  end

  def layout_by_resource
    if params[:controller] == "pages" && params[:action] == "start"
      "start"
    elsif params[:controller] == "quarters" && params[:action] == "show" or params[:controller] == "kommunens" && params[:action] == "show"
      "quarter"
    elsif params[:controller] == "initiatives" && params[:action] == "index"
      "initiativen"
    elsif params[:controller] == "antraege" && params[:action] == "index"
      "antraeges"
    elsif params[:controller] == "constructions" && params[:action] == "index"
      "baustellen"
    elsif params[:controller] == "antraege" && params[:action] == "show" or params[:controller] == "initiative" && params[:action] == "show" or params[:controller] == "constructions" && params[:action] == "show" or params[:controller] == "neuigkeiten" && params[:action] == "show"
      "detail"
    else
      "application"
    end
  end

  def all_quarters
    @all_quarters ||= Quarter.all
  end
  helper_method :all_quarters

  def all_kommune
    @all_kommune ||= Kommune.all
  end
  helper_method :all_kommune

  def ensure_valid_recaptcha
    if !current_user
      if !verify_recaptcha
        redirect_to :back, alert: 'Der SPAM-Schutz Test wurde leider nicht bestanden.'
      end
    end
  end

end
