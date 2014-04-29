require 'uri'
require 'active_support'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params

  def initialize(req, route_params = {})
    if req.is_a?(WEBrick::HTTPRequest)
      @params = {}
      @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
      @params.merge!(parse_www_encoded_form(req.body)) if req.body
    end
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
    @params.to_json
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
