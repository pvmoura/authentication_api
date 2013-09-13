require 'json'

def is_valid_email(email)
  regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  return true if email.match(regex)
  false
end

def check_for_errors(parsed_data, response)
  required_keys = ['name', 'email', 'password', 'password_confirmation']
  required_keys.each do |key|
    if !parsed_data.keys.include? key
	  response[:error] = "missing required param: #{key}"
	  break
	elsif parsed_data[key].empty?
	  response[:error] = "#{key} param is empty"
	  break
	end
  end

  if response.empty? && parsed_data.keys.length == 4
	if !is_valid_email(parsed_data.fetch('email'))
	  response[:error] "email is invalid"
	end
  end

  return response
end

class UsersController < ApplicationController
  def sign_in
  	if request.post?
  	  response = {}
  	  begin
  	  	parsed_data = JSON.parse params[:data]
  	  rescue
  	    response[:error] = "malformed json"
  	  end

  	  if response.empty?
  	    response = check_for_errors(parsed_data, response)
  	  	if response.empty?
  	  	# now login user
  	  	  user = User.where(email: parsed_data.fetch('email')).take(1)
  	  	  user = user.authenticate(parsed_data.fetch('password'))
  	  	  if user != false
  	  	  	user.generate_new_auth_token()
  	  	  	response = user.as_json(except:
  	  	  			   [:id, :created_at, :last_modified, :updated_at, :password_digest])
  	  	  end
  	  	end
  	  end
  	  respond_to do |format|
  	  	format.json { render json: response }
  	  end
  	end
  end
end
