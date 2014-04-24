class SearchController < ApplicationController
  def index
    if Rails.env.production?
      @results = ThinkingSphinx.search(params[:q])
    else
      @results = Antraege.search(params[:q])
    end
  end
end
