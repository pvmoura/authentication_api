require 'spec_helper'

describe User do
  before { @user = User.new(name: "Pedro Moura", email: "email@email.com") }
  subject { @user }
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should be_valid }
  
  describe "when name not present" do
  	before { @user.name = "" }
  	it { should_not be_valid }
  end

  describe "when email not present" do
  	before { @user.email = "" }
  	it { should_not be_valid }
  end

  describe "when email is invalid" do
  	%w[bad@email.asdf bad#email.com bad@email,com].each do |failmail|
  	  @user.email = failmail
  	  expect(@user).not_to be_valid
  	end
  end

  describe "when email is valid" do
  	emails = %w[good@EMAIL.com weird@a.b.org WE_ier-d@e.tz f+l@emai.ly]
  	emails.each do |success|
  	  @user.email = success
  	  expect(@user).to be_valid
  	end
  end

  describe "when email already in system" do
  	before do
  	  duplicate_user = @user.dup
  	  duplicate_user.save
  	end

  	it { should_not be_valid }
  end



end
