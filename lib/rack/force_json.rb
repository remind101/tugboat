class Rack::ForceJSON
  def initialize(app)
    @app = app
  end

  def call(env)
    env['ACCEPT']       = 'application/json'
    env['CONTENT_TYPE'] = 'application/json'
    @app.call(env)
  end
end
