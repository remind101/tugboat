require 'sinatra/asset_pipeline/task'
Sinatra::AssetPipeline::Task.define! Shipr::Web

namespace :queues do
  namespace :update do
    task :run do
      Shipr::Queues::Update.run
    end
  end
end
