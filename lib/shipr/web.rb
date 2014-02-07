require 'sinatra/base'
require 'sinatra/asset_pipeline'

module Shipr
  class Web < Sinatra::Base
    set :root, File.join(File.dirname(__FILE__), 'web')

    register Sinatra::AssetPipeline

    set :github_options, { }
    register Sinatra::Auth::Github

    configure :test do
      set :show_exceptions, false
      set :raise_errors, true

      Sprockets::Helpers.configure do |config|
        config.debug = true
      end
    end

    helpers do
      def jobs
        Job.order('id asc')
      end
    end

    before do
      github_organization_authenticate!(ENV['GITHUB_ORGANIZATION'])
    end

    get '/' do
      'ok'
    end

    get '/deploys/:id' do |id|
      @job = jobs.find(id)
      haml :job
    end

    configure :test, :development do
      get '/assets/*' do |path|
        env_sprockets = request.env.dup
        env_sprockets['PATH_INFO'] = path
        settings.sprockets.call env_sprockets
      end
    end
  end
end
