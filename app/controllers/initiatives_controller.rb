# encoding: utf-8

class InitiativesController < ApplicationController
  load_and_authorize_resource except: [:index]
  include LocationVariables

  def index
    @initiatives, @initiatives_map = search_models Initiative, params

    authorize! :index, Initiative

    respond_to do |format|
      format.html
      format.json do
        render json: json_for(@initiatives, @map_lat, @map_lng, @map_zoom)
      end
    end
  end

  def show
    @comments = @initiative.comments.arrange(:order => :created_at)

    if current_user
      @supporting = current_user.sympathies.exists?(:initiative_id => @initiative.id)
      @subscribed = current_user.subscriptions.exists?(:subscribable_id => @initiative.id, :subscribable_type => 'Initiative')
    end

    respond_to do |format|
      format.html
      format.json { render json: @initiative }
    end
  end

  def new
    @initiative = Initiative.new
    load_kommunen
    load_quarters

    respond_to do |format|
      format.html
      format.json { render json: @initiative }
    end
  end

  def edit
    load_kommunen
    load_quarters
  end

  def create
    @initiative = current_user.initiatives.build(params[:initiative])
    @initiative.visible = params[:visible].present? ? params[:visible] : true
    @initiative.subscriptions.build(user: current_user)

    respond_to do |format|
      if @initiative.save
        notificaiton = {
          Initiative => { new: [@initiative] }
        }
        QuarterSubscription.where('user_id != ?', current_user.id).where(quarter_id: @initiative.quarter_id).each do |subscription|
          SubscriptionMailer.quarter(subscription, notificaiton).deliver
        end

        format.html { redirect_to @initiative, notice: 'Die Initiative wurde erfolgreich erstellt.' }
        format.json { render json: @initiative, status: :created, location: @initiative }
      else
        format.html do
          load_quarters
          load_kommunen
          render action: "new"
        end
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @initiative.update_attributes(params[:initiative])
        notificaiton = {
          Initiative => { updated: [@initiative] }
        }
        # if @initiative.visible == true
        # QuarterSubscription.where('user_id != ?', current_user.id).where(quarter_id: @initiative.quarter_id).each do |subscription|
        #   SubscriptionMailer.notify(subscription, notificaiton).deliver
        # end
        # end
        # Send to subscriber
        format.html { redirect_to @initiative, notice: 'Die Initiative wurde erfolgreich gepeichert.' }
        format.json { head :no_content }
      else
        format.html do
          load_quarters
          load_kommunen
          render action: "edit"
        end
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @initiative.destroy

    respond_to do |format|
      format.html { redirect_to initiatives_url, notice: 'Initiative erfolgreich gelöscht.' }
      format.json { head :no_content }
    end
  end

  def support
    @initiative = Initiative.find(params[:id])
    unless @initiative.supporters.exists?(user_id: current_user.id)
      @initiative.supporters.create!(user: current_user)
    end

    @initiative.subscribe(current_user)

    @supporting = true

    respond_to do |format|
      format.js { render 'update_support' }
    end
  end

  def unsupport
    @initiative = Initiative.find(params[:id])
    if supporter = @initiative.supporters.find_by_user_id(current_user.id)
      supporter.destroy
    end

    @supporting = false

    respond_to do |format|
      format.js { render 'update_support' }
    end
  end

  def subscribe
    @initiative = Initiative.find(params[:id])
    @initiative.subscribe(current_user)

    @subscribed = true

    respond_to do |format|
      format.js { render 'update_subscription' }
    end
  end

  def unsubscribe
    @initiative = Initiative.find(params[:id])
    @initiative.unsubscribe(current_user)

    @subscribed = false

    respond_to do |format|
      format.js { render 'update_subscription' }
    end
  end

  def contact
    @initiative = Initiative.find(params[:id])
    render 'kontakt_form'
  end

  def contact_submit
    @initiative = Initiative.find(params[:id])
    text = params[:message][:body]
    respond_to do |format|
      if text.present?
        InitiativenMailer.initiator_email(current_user, @initiative, text).deliver
        format.html { redirect_to @initiative, notice: 'Die Nachricht wurde verschickt.' }
      else
        flash.now[:alert] = 'Leider keine Nachricht vorhanden.'
        format.html { redirect_to contact_initiative_path, notice: 'Ein Text für eine Nachricht fehlt.' }
      end
    end
  end

  def contact_moderator
    @initiative = Initiative.find(params[:id])
    render 'kontakt_moderator'
  end

  def contact_moderator_submit
    @initiative = Initiative.find(params[:id])
    text = params[:message][:body]
    respond_to do |format|
      if text.present?
        InitiativenMailer.initiator_moderator_email(current_user, @initiative, text).deliver

        format.html { redirect_to @initiative, notice: 'Die Nachricht wurde verschickt.' }
      else
        flash.now[:alert] = 'Leider keine Nachricht vorhanden.'
        format.html { redirect_to contact_moderator_initiative_path, notice: 'Ein Text für eine Nachricht fehlt.' }
      end
    end
  end

  private

  delegate :link_to, :escape_javascript, :truncate_html, :to => :view_context

  def json_for(initiatives, lat, lon, zoom)
    {
      :initiatives => initiatives.as_json.map do |initiative|
        initiative.merge({
          :popup => "<b>#{link_to initiative['title'], initiative_path(initiative)}</b>" +
          "<br><p>#{escape_javascript(truncate_html(initiative['content'].html_safe, :length => 50))}</p>" +
          "#{link_to 'Zur Initiative', initiative_path(initiative)}"
        })
      end,

      # To center map
      :location => {:lat => lat, :lon => lon},
      :zoom => zoom
    }
  end

  def load_kommunen
    @kommunen = Kommune.all
  end

  def load_quarters
    @quarters = []
    quarters = Quarter.all.sort_by(&:name)
    @quarters_id_to_location = quarters.each_with_object({}) do |quarter, hash|
      hash[quarter.id] = [quarter.lat, quarter.long]
    end
  end
end
