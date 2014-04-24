class KommunensController < ApplicationController
  def show
    @kommune = Kommune.find(params[:id])
    @quarters = @kommune.quarters
    @initiatives = Initiative.with_location.within_kommune(@kommune.id).where('visible = true')
    @antraeges = Antraege.with_location.within_kommune(@kommune.id).select([:id, :kommune, :title, :lat, :long]).order('last_updated desc').limit(100)

    @comments = Comment.for_items(@initiatives.pluck(:id), @antraeges.pluck(:id)).recent
    @constructions = Construction.within_kommune(@kommune.id).current.with_location.order('start_date DESC').limit(100)

    @selected_kommune = params[:id]

    render layout: 'quarter'
  end

  def quartiere
    kommune = Kommune.find(params[:id])
    render json: kommune.quarters
  end
end