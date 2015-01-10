require 'byebug'
class ReposController < ApplicationController
  before_filter :get_repos, only: :index

  def index
    @repos = Repo.all
    
    render json: @repos, status: 200
  end

  private
  def get_repos
    Repo.github_repos
  end

  def repo_params
    params.require(:repo).permit(:name, :urls, :github_data)
  end
end