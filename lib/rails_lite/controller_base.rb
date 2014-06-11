require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require_relative 'flash'


class ControllerBase
  attr_reader :params, :req, :res

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
    @already_built_response = false
  end


  def render_content(content, type)
    raise "Already built" if already_built_response?
    @res.content_type = type
    @res.body = content
    session.store_session(@res)
    @already_built_response = true
  end

  def already_built_response?
    !!@already_built_response
  end

  def redirect_to(url)
    raise "Already built" if already_built_response?
    @res.status = 302
    @res["Location"] = url
    session.store_session(@res)
    @already_built_response = true
  end


  def render(template_name)
    controller_name = self.class.name.underscore
    input = File.read("./views/#{controller_name}/#{template_name}.html.erb")
    render_content(ERB.new(input).result(binding), 'text/html')
  end


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
