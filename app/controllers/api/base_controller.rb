class Api::BaseController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :set_headers, :check_url
	respond_to :json

	def me
    render status: :ok, json: {url: params[:url]}
	end

	def options
	  set_headers
	  # this will send an empty request to the client with 200 status code (OK, can proceed)
	  render :text => '', :content_type => 'text/plain'
	end

protected
  def check_url
  	failed, response = open_url(params[:url])
    if failed
      render status: 500, json: { message: response }
      return
    end
  end

	# Set CORS
  def set_headers
    headers["Access-Control-Allow-Origin"] = '*'
    headers['Access-Control-Expose-Headers'] = 'Etag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*, x-requested-with, Content-Type, If-Modified-Since, If-None-Match, Authorization'
    headers['Access-Control-Max-Age'] = '86400'
  end

  def open_url(url)
    failed = true  
    response_message = ""

    begin                                                            
      page = open(url, :allow_redirections => :safe)
      failed = false                                               
    rescue OpenURI::HTTPError => e                                   
      error_message = e.message                                      
      response_message = "response Code = #{e.io.status[0]}"         
    rescue SocketError => e                                          
      error_message = e.message                                      
      response_message = "host unreachable"                          
    rescue => e                                                      
      error_message = e.message                                      
      response_message = "unknown error"                             
    end     
    return failed, response_message
  end
end