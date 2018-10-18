class HistoryTrackersController < ApplicationController
  before_action :get_trackable
  before_action :get_track, only: :show

  def index
    authorize @trackable, :edit # Must be a collaborator to view audit log
    @tracks = @trackable.history_tracks.includes(:modifier).reorder(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    authorize @trackable, :edit # Must be a collaborator to view audit
  end

  private

  def get_trackable
    params.each do |name, value|
      return @trackable = Regexp.last_match(1).classify.constantize.find(value) if name =~ /(.+)_id$/
    end
    nil
  end

  def get_track
    @track = HistoryTracker.find(params[:id])
  end
end
