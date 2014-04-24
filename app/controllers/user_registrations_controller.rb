class UserRegistrationsController < Devise::RegistrationsController
  before_filter :load_kommunen, only: [:new, :create, :edit, :update]
  before_filter :load_quarters, only: [:new, :create, :edit, :update]

  def edit
    @subscriptions = SearchSubscription.where(email: current_user.email)
    @subscriptions_iniatives = Subscription.where(user_id: current_user.id)
    quarter_ids = current_user.quarter_subscriptions.pluck(:quarter_id)
    if quarter_ids.present?
      @quarter_subscriptions = Quarter.fetch_quarters_with_ids(quarter_ids)
    else
      @quarter_subscriptions = []
    end
  end

  private

  def load_kommunen
    @kommunen = Kommune.all
  end

  def load_quarters
    kommune = @kommunen.find { |x| x.id.to_s == resource.try(:kommune) }
    kommune ||= @kommunen.first
    @quarters = kommune.quarters
  end

  def after_sign_up_path_for(resource)
    edit_user_registration_path
  end

  def after_inactive_sign_up_path_for(resource)
    edit_user_registration_path
  end

  def after_update_path_for(resource)
    profile_path(resource)
  end
end
