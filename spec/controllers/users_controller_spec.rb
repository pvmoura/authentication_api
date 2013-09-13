require 'spec_helper'
require 'json'

describe UsersController do
  before do
  	user = User.new(name: 'John Doe', email: 'john@doe.com')
  	user.password = 's3kr3t'
  	user.password_confirmation = 's3kr3t'
  	user.save
  end
  let(:json_params) { {name: 'John Doe', email: 'john@doe.com', password: 's3kr3t', password_confirmation: 's3kr3t'} }

  describe "when json is malformed" do
  	it "should return the following error message" do
  	  json_params = "{name:John Doe, "
  	  post '/users/sign_in.json', json_params
  	  expected_error = {error: 'malformed json'}
  	  last_response.body.should eql expected_error.to_json
  	end
  end


  describe "when a key is missing" do
  	it "should return the following error message" do
	  json_params.each do |key, value|
	  	data = json_params.dup
	  	data.delete(key)
	  	data = JSON.dump data
	  	post '/users/sign_in.json', data
	  	expected_error = {error: "missing required param: #{key}"}
	  	last_response.body.should eql expected_error.to_json
	  end
	end
  end

  describe "when a parameter is missing" do
  	it "should return the following error message" do
	  json_params.each do |key, value|
	  	data = json_params.dup
	  	data[key] = ""
	  	data = JSON.dump data
	  	post '/users/sign_in.json', data
	  	expected_error = {error: "#{key} param is empty"}
	  	last_response.body.should eql expected_error.to_json
	  end
	end
  end

  describe "when email is not well formed" do
  	it "should return the following error message" do
	  %w[bad@asdf bad#email.com bad@email,com].each do |failmail|
	    json_params[:email] = failmail
	    data = JSON.dump json_params
	  	post '/users/sign_in.json', data
	  	expected_error = {error: "email is invalid"}
	  	last_response.body.should eql expected_error.to_json
	  end
	end
  end

  describe "when passwords don't match" do
  	it "should return the following error message" do
  	  json_params[:password_confirmation] = 'asdf'
  	  data = JSON.dump json_params
	  post '/users/sign_in.json', data
	  expected_error = {error: "passwords don't match"}
	  last_response.body.should eql expected_error.to_json
	end
  end

  describe "when incorrect email is submitted" do
  	it "should return the following error message" do
  	  json_params[:email] = 'asdf@asdf.com'
  	  data = JSON.dump json_params
  	  post '/users/sign_in.json', data
  	  expected_error = {error: "email not found in database"}
  	  last_response.body.should eql expected_error.to_json
  	end
  end

  describe "when incorrect password is submitted" do
  	it "should return the following error message" do
  	  json_params[:password] = 'asdf'
  	  json_params[:password_confirmation] = 'asdf'
  	  data = JSON.dump json_params
  	  post '/users/sign_in.json', data
  	  expected_error = {error: "email/password combination not found"}
  	  last_response.body.should eql expected_error.to_json
  	end
  end

  describe "when correct information is passed" do
  	it "should return the user credentials" do
  	  data = JSON.dump json_params
  	  post '/users/sign_in.json', data
  	  expected_result = {
  	  	"auth_token"=> "s3kr3t-value",
  	  	"email"=> "john@doe.com",
	    "id"=> 1,
	    "name"=> "JohnDoe"
	  }
  	  last_response.body.should eql expected_result.to_json
  	end
  end
end