# -*- coding: utf-8 -*-
require 'json'
require 'yaml'
require 'twitter/json_stream'
require 'twitter'
require 'ykk'

module UnfavCounter
  class << self
    def config
      @config ||= Hash[YAML.load(open(File.expand_path('../config.yaml', __FILE__))).map {|k, v| [k.to_sym, v] }]
    end

    def client
      @client ||= Client.new(config)
    end

    def run!
      Signal.trap :INT do
        puts "\nexitting.."
        exit 0
      end

      puts 'starting...'
      start_stream
    end

    def start_stream
      EventMachine::run do
        stream = Twitter::JSONStream.connect(
          host: 'userstream.twitter.com',
          path: '/1.1/user.json',
          port: 443,
          ssl: true,
          oauth: {
            consumer_key: config[:consumer_key],
            consumer_secret: config[:consumer_secret],
            access_key: config[:oauth_token],
            access_secret: config[:oauth_token_secret]
          }
        )

        stream.each_item do |item|
          client.respond JSON.parse(item)
        end

        stream.on_error do |message|
          puts message
        end

        stream.on_max_reconnects do |timeout, retries|
          puts "max reconnected. timeout: #{timeout}, retries: #{retries}"
        end
      end
    end
  end

  class Client
    def initialize(config)
      @client = Twitter::Client.new config
      @store = YKK.new(dir: File.expand_path('../data', __FILE__))
    end

    def save(id)
      @store[id.to_s] ||= 0
      @store[id.to_s] += 1
    end

    def count_of(id)
      @store[id.to_s]
    end

    def respond(event)
      respond_unfav event if event['event'] == 'unfavorite'
    end

    def respond_unfav(event)
      from = event['source']['screen_name']
      id = event['source']['id']
      save id
      update "@#{from} |◞‸◟ ) あんふぁぼされた… (#{count_of(id)}回目)"
    end

    def update(msg)
      @client.update msg
    end
  end
end

UnfavCounter.run! if $0 == __FILE__
