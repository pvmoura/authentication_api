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
	  response[:error] = "email is invalid"
	elsif parsed_data['password'] != parsed_data['password_confirmation']
	  response[:error] = "passwords don't match"
	end
  end

  return response
end

class UsersController < ApplicationController
  def sign_in
  	response = {}
  	if request.post?
  	  data = request.raw_post()
  	  if !data.empty?
	  	begin
	  	  parsed_data = JSON.parse data
	  	rescue
	  	  response[:error] = "malformed json"
	  	end

	  	if response.empty?
	  	  response = check_for_errors(parsed_data, response)
	  	  if response.empty?
	  	    # now login user
	  	    user = User.where(email: parsed_data.fetch('email')).take(1)[0]
	  	  	if user != nil
		  	  user = user.authenticate(parsed_data.fetch('password'))
		  	  if user != false
		  	  	user.auth_token = 's3kr3t-value'
		  	  	user.save
		  	  	user.name = user.name.gsub(/\s+/, "")
		  	  	response = user.as_json(except:
		  	  			   [:created_at, :last_modified, :updated_at, :password_digest])
		  	  else
		  	  	response[:error] = "email/password combination not found"
		  	  end
		  	else
		  	  response[:error] = "email not found in database"
		  	end
	  	  end
	  	end
	  else
	  	response[:error] = "No payload found"
	  end
  	  respond_to do |format|
  	    format.json { render json: response }
  	  end
  	else
  	  response[:error] = "No GETs allowed."
  	  respond_to do |format|
  	  	format.json { render json: response }
  	  end
  	end
  end

  def test
  end
end
