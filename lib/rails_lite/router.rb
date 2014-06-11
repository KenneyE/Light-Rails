class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.path =~ self.pattern && req.request_method.downcase.to_sym == self.http_method
  end


  def run(req, res)
    pattern.match(req.path)
    route_params = self.pattern.named_captures.map
    self.controller_class.new(req, res, route_params).invoke_action(self.action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    ind = self.routes.find_index { |route| route.matches?(req) }
    ind.nil? ? nil : self.routes[ind]
  end

  def run(req, res)
    !!match(req) ? match(req).run(req, res) : res.status = 404
  end
end
