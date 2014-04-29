require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    found_cookie = nil
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_app"
        found_cookie = cookie
      end
    end
    @session = found_cookie.nil? ? {} : JSON.parse(found_cookie.value)
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @session.to_json)
  end
end
