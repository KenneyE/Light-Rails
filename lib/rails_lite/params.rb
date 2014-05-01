require 'uri'
require 'active_support'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  attr_reader :params

  def initialize(req, route_params = {})
    if req.is_a?(WEBrick::HTTPRequest)
      @permitted_keys = []
      @params = route_params
      @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
      @params.merge!(parse_www_encoded_form(req.body)) if req.body
    end
  end

  def [](key)
    self.params[key]
  end

  def permit(*keys)
    keys.each { |key| @permitted_keys << key }
  end

  def require(key)
    raise Params::AttributeNotFoundError if !@params.keys.include?(key)
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
    self.params.to_json
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    params_array = URI::decode_www_form(www_encoded_form).map do |param|
      value = param.last

      parse_key(param.first).reverse.inject(value) { |a, n| { n => a } }
    end

    hash = {}
    params_array.each do |param|
      hash.deep_merge!(param)
    end
    hash
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    parsed_key = key.split(/\]\[|\[|\]/)
  end
end
