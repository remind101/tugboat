FactoryGirl.define do
  factory :repo, class: Shipr::Repo do
    name 'remind101/shipr'
  end

  factory :job, class: Shipr::Job do
    repo
    sha SecureRandom.hex
    description 'Deploying my awesome topic branch'
  end
end
