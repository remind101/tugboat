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
  end
end
