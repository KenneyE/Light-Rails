require 'json'
require 'webrick'

class Session
  def initialize(req)
    found_cookie = nil
    req.cookies.each do |cookie|
      found_cookie = cookie if cookie.name == "_rails_lite_app"
    end
    @session = found_cookie.nil? ? {} : JSON.parse(found_cookie.value)
    @flash = @session.select { |key, val| key == :flash }
    @session.delete_if { |key, val| key == :flash }
  end

  def [](key)
    if key == :flash
      @flash[key]
    else
      @session[key]
     end
  end

  def []=(key, val)
    if key == :flash
      @flash[key] = val
      @session[:flash_count] = 2
      @session.merge(@flash)
    else
      @session[key] = val
    end
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @session.to_json)
  end
end
