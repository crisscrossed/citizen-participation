class PagesController < ApplicationController
  load_and_authorize_resource :except => [:start]

  def start
    authorize! :show, Page
    @initiativen = Initiative.where("lat != '' and visible = true").order('created_at desc').limit(100)
    @initiatives = Initiative.where("visible = true").order('created_at desc').limit(10)
    @kommunen = Kommune.all
    @quarters = all_quarters
    @quarters_id_to_location = @quarters.each_with_object({}) do |quarter, hash|
      hash[quarter.id] = { coords: [quarter.lat, quarter.long], kommune: quarter.kommune }
    end

    @antraeges = Antraege.where("lat != ''").select([:id, :kommune, :title, :lat, :long]).order('last_updated desc').limit(3)
    @constructions = Construction.current.with_location.order('start_date DESC').limit(100)

    # Select Aachen
    @selected_kommune = @kommunen.find { |k| k.id == 1 }
    # Select Innenstadt
    @selected_quarter = nil
    @streets = []

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @initiatives }
    end
  end

  def show
    @initiatives = Initiative.recent
    if params[:id]
      @page = Page.find(params[:id])
    else
      @page = Page.find_by_slug!(params[:slug])
    end

    respond_to do |format|
      format.html
      format.json { render json: @page }
    end
  end

  def new
    respond_to do |format|
      format.html
      format.json { render json: @page }
    end
  end

  def edit
  end

  def create

    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, notice: 'Page was successfully created.' }
        format.json { render json: @page, status: :created, location: @page }
      else
        format.html { render action: "new" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to @page, notice: 'Seite erfolgreich aktualisiert.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @page.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  private

  def fill_in_blanks(date_hash, first_day, last_day)
    (first_day..last_day).each do |current_day|
      date_hash[current_day.strftime('%Y-%m-%d')] ||= 0
    end
  end
  def load_recent_items
    @recent_ideas = Initiativen.recent
    @recent_comments = Comment.recent
  end
  private

  def sidebar
    false
  end
end


