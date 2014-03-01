require 'sinatra/base'
require 'sinatra/asset_pipeline'

module Shipr
  class Web < Sinatra::Base
    set :root, File.dirname(File.expand_path('../..', __FILE__))

    register Sinatra::AssetPipeline

    set :github_options, { }
    register Sinatra::Auth::Github

    configure :test do
      set :show_exceptions, false
      set :raise_errors, true
    end

    before do
      github_organization_authenticate!(Shipr.configuration.github_organization)
    end

    %w[/ /deploys/:id].each do |path|
      get path do
        @user = {
          username: github_user['attribs']['login'],
          gravatar: "http://www.gravatar.com/avatar/#{github_user['attribs']['gravatar_id']}"
        }
        haml :index
      end
    end

    get '/logout' do
      warden.logout
      redirect '/'
    end
  end
end
