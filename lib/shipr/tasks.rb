namespace :queues do
  namespace :update do
    task :run do
      Shipr::Queues::Update.run
    end
  end
end
