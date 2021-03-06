class TravisController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  
  def nomnom
    if not valid_request?
      puts "Invalid payload request for repository #{repo_slug}"
    else
      payload = JSON.parse(params[:payload])
      if payload['type'] == 'pull_request'
        parent = Repo.where(name: payload["repository"]["name"])[0]
        payload["parent"] = parent
        PullRequest.create!({repo_id: parent[:id], committer_name: payload['committer_name'], travis_identifier: payload['id'], name: env['HTTP_TRAVIS_REPO_SLUG'], build_status: payload['status'], status_message: payload['status_message'], build_url: payload['build_url'], commit_message: payload['message'], pull_request_number: payload['pull_request_number']})
      end
    end
    render json: payload, status: 201
  end

  private
  def valid_request?
    digest = Digest::SHA2.new.update("#{env['HTTP_TRAVIS_REPO_SLUG']}#{ENV['TRAVIS_CI_TOKEN']}")
    digest.to_s == authorization
  end

  def authorization
    env['HTTP_AUTHORIZATION']
  end

  def repo_slug
    env['HTTP_TRAVIS_REPO_SLUG']
  end
end