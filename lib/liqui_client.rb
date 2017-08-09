require "liqui_client/version"

require 'rest-client'
require 'openssl'
require 'addressable/uri'

module LiquiClient
  class << self
    attr_accessor :configuration
  end

  def self.setup
    @configuration ||= Configuration.new
    yield( configuration )
  end

  class Configuration
    attr_accessor :key, :secret

    def intialize
      @key    = ''
      @secret = ''
    end
  end

  def self.info
    get 'info'
  end

  def self.depth pair="eth_btc"
    get 'depth', pair
  end

  def self.ticker pair="eth_btc"
    get 'ticker', pair
  end

  def self.trades pair="eth_btc"
    get 'trades', pair
  end

  def self.balances
    post 'getInfo'
  end

  protected

  def self.resource_get
    @@resouce_get ||= RestClient::Resource.new( 'https://api.liqui.io/api/3/' )
  end

  def self.resource_post
    @@resouce_post ||= RestClient::Resource.new( 'https://api.liqui.io/tapi' )
  end

  def self.get( command, param=nil )
    command += ("/" + param) if not param.nil?
    resource_get[ command ].get
  end

  def self.post( command, params = {} )
    params[:method] = command
    params[:nonce] = Time.now.to_i
    resource_post.post params,  { Key: configuration.key , Sign: create_sign( params ) }
  end

  def self.create_sign( data )
    sc = configuration.secret
    encoded_data = Addressable::URI.form_encode( data )
    OpenSSL::HMAC.hexdigest( 'sha512', sc, encoded_data )
  end

end
