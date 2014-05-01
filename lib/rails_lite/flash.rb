require_relative 'session'

class Flash
  def initialize(req)
    found_cookie = nil
    req.cookies.each do |cookie|
      found_cookie = cookie if cookie.name == "_rails_lite_app"
    end
    @session = found_cookie.nil? ? {} : JSON.parse(found_cookie.value)
  end

  def []=(key, val)
    @flash[key] = val
  end

  def [](key)
    @flash[key]
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)

  end
end