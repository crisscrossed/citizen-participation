class QuartersController < ApplicationController
  def show
    @quarter_id = params[:id]
    @quarter = Quarter.find(params[:id])
    @initiatives = Initiative.with_location.within_quarter(params[:id]).where('visible = true')
    @streets = @quarter.streets
    @quarters = Quarter.all
    @antraeges = Antraege.with_location.within_quarter(params[:id]).select([:id, :kommune, :title, :lat, :long]).order('last_updated desc').limit(100)
    @comments = Comment.for_items(@initiatives.pluck(:id), @antraeges.pluck(:id)).recent
    @constructions = Construction.within_quarter(params[:id]).current.with_location.order('start_date DESC').limit(100)
    @selected_quarter = params[:id]
    @selected_kommune = @quarter.kommune
  end

  def initiatives
    initiatives = Initiative.within_quarter(params[:id])
    render json: initiatives
  end

  def streets
    # TODO: Sanitize the params[:name] for malicious SQL - checkx
    render json: Quarter.new(nil, params[:id]).streets
  end

  def subscribe
    @quarter_id = params[:id]
    unless current_user.quarter_subscriptions.exists?(quarter_id: params[:id])
      current_user.quarter_subscriptions.create!(quarter_id: params[:id])
    end

    @subscribed = true

    respond_to do |format|
      format.js { render 'update_subscription' }
    end
  end

  def unsubscribe
    @quarter_id = params[:id]
    if subscription = current_user.quarter_subscriptions.where(quarter_id: params[:id]).first
      subscription.destroy
    end

    @subscribed = false

    respond_to do |format|
      format.js { render 'update_subscription' }
    end
  end
end
