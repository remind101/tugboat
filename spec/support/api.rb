module ApiExampleGroup
  extend ActiveSupport::Concern
  include Rack::Test::Methods

  included do
    before do
      Timecop.freeze Time.parse('2014-01-01 00:00:00 UTC')
    end

    after do
      Timecop.return
    end
  end

  def app
    Files.app
  end

  def verify_response(status)
    expect(last_response.status).to eq status
    verify format: :json do
      last_response.body
    end
  end
end
