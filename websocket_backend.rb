require "faye/websocket"
require "json"

class WebsocketBackend
  KEEPALIVE_TIME = 15 # in seconds
  APPLICATION_NAME = "web-sms-chat"

  def initialize(app)
    @app = app
    @clients = []
    @commands = {}
    @get_catapult_client = Proc.new do |message|
      auth = message["auth"]
      Bandwidth::Client.new(auth["userId"], auth["apiToken"], auth["apiSecret"])
    end

    # Check auth data, balance and return phone number for messages
    @commands["signIn"] = Proc.new do |message, socket|
      message["auth"] = message["data"]
      client = @get_catapult_client.call(message)
      application_name = "web-sms-chat on #{socket.env["HTTP_HOST"]}"
      puts "Getting account's balance"
      result = Bandwidth::Account.get(client)
      raise "You have no enough amount of money on your account" if result[:balance].to_f <= 0
      puts "Getting application id"
      application_id = ((Bandwidth::Application.list(client, {size: 1000}).select {|app| app.name == application_name})[0] || {})[:id]
      unless application_id
        puts "Creating new application on Catapult"
        application = Bandwidth::Application.create(client, {
          name: application_name,
          incoming_message_url: "http://#{socket.env["HTTP_HOST"]}/#{message["auth"]["userId"]}/callback"
        })
        application_id = application[:id]
      end
      puts "Getting phone number"
      phone_number = (Bandwidth::PhoneNumber.list(client, {application_id: application_id, size: 1})[0] || {})[:number]
      unless phone_number
        puts "Reserving new phone number on Catapult"
        number = (Bandwidth::AvailableNumber.search_local(client, {city: "Cary", state: "NC", quantity: 1})[0] || {})[:number]
        Bandwidth::PhoneNumber.create(client, {number: number, application_id: application_id})
        phone_number = number
      end
      socket.user_id = message["auth"]["userId"]
      {"phoneNumber": phone_number}
    end

    # Get messages
    @commands["getMessages"] = Proc.new do |message, socket|
      socket.user_id = message["auth"]["userId"]
      client = @get_catapult_client.call(message)
      puts "Get messages"
      messages = Bandwidth::Message.list(client, {size: 1000, from: message["data"]["phoneNumber"], direction: "out"})
        .concat(Bandwidth::Message.list(client, {size: 1000, to: message["data"]["phoneNumber"], direction: "in"}))
      messages.sort do |m1, m2|
        time1 = DateTime.parse(m1[:time])
        time2 = DateTime.parse(m2[:time])
        time1 <=> time2
      end
    end

    # Send a message
    @commands["sendMessage"] = Proc.new do |message, socket|
      socket.user_id = message["auth"]["userId"]
      client = @get_catapult_client.call(message)
      puts "Sending a  message"
      Bandwidth::Message.create(client, message["data"])
    end
  end

  def call(env)
    env["websockets"] = @clients
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
      class << ws
        attr_accessor :user_id

        def emit_event(event_name, data = {})
          self.send JSON.generate({eventName: event_name, data: data})
        end
      end
      ws.on :open do |event|
        p [:open, ws.object_id]
        @clients << ws
      end

      ws.on :message do |event|
        puts "Received new message #{event.data}"
        message = {}
        begin
          message = JSON.parse(event.data)
        rescue
          puts "Invalid format of received data #{event.data}"
        end
        send_error = Proc.new do |err|
          ws.emit_event("#{message["command"]}.error.#{message["id"]}", err);
        end
        handler = @commands[message["command"]]
        return send_error.call "Command #{message["command"]} is not implemented" unless handler
        puts "Executing command #{message["command"]} with data #{message["data"]}"
        begin
          result = handler.call(message, ws)
          ws.emit_event("#{message["command"]}.success.#{message["id"]}", result)
        rescue Exception => err
          send_error.call err.message
          puts err.backtrace
        end
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
        ws = nil
      end

      # Return async Rack response
      ws.rack_response

    else
      @app.call(env)
    end
  end

end
