require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require_relative 'flash'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "Already built" if already_built_response?
    @res.content_type = type
    @res.body = content
    session.store_session(@res)
    @already_built_response = true
  end

  # helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "Already built" if already_built_response?
    @res.status = 302
    @res["Location"] = url
    session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    input = File.read("./views/#{controller_name}/#{template_name}.html.erb")
    session[:flash_count] -= 1 unless session[:flash_count].nil?
    render_content(ERB.new(input).result(binding), 'text/html')
  end


  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def reset_session!
    @session = Session.new(@req)
  end

  def flash
    @session[:flash_count] = 2
    @session[:flash]
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    non_csrf_actions = [:index, :show, :edit, :new]
    if non_csrf_actions.include?(name) || verify_authenticity_token
      self.send(name)
    else
      reset_session!
    end
  end

  def form_authenticity_token
     session[:_csrf_token] ||= SecureRandom.base64(32)
  end

  def verify_authenticity_token
    @params[:_csrf_token] == session[:_csrf_token]
  end
end
