require 'faye/websocket'
require 'json'

class SpaBackend
  def initialize(app)
    @app = app
  end

  def call(env)
    p env
    @app.call(env)
  end
end
