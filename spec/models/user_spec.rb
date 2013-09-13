require 'spec_helper'

describe User do
  #before { @user = User.new(name: "Pedro Moura", email: "email@email.com",
  							#password: "hello", password_confirmation: "hello") }
  before do
  	@user = User.new(name: "Pedro Moura", email: "email@email.com")
  	@user.password = "hello"
  	@user.password_confirmation = "hello"
  end
  subject { @user }
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should be_valid }
  
  describe "when name not present" do
  	before { @user.name = "" }
  	it { should_not be_valid }
  end

  describe "when email not present" do
  	before { @user.email = "" }
  	it { should_not be_valid }
  end

  describe "when password is not present" do
	before do
	  @user = User.new(name: "Pedro Moura", email: "email@email.com")
	  @user.password = ""
	  @user.password_confirmation = ""
	end

  	it { should_not be_valid }
  end

  describe "when password and confirmation don't match" do
    before { @user.password_confirmation = @user.password.split("").shuffle.join() }
    it { should_not be_valid }
  end

  describe "when email is invalid" do
  	it "should be invalid" do
	  %w[bad@asdf bad#email.com bad@email,com].each do |failmail|
	  	@user.email = failmail
	  	expect(@user).not_to be_valid
	  end
  	end
  end

  describe "when email is valid" do
  	it "should be valid" do
  	  emails = %w[good@EMAIL.com weird@a.b.org WE_ier-d@e.tz f+l@emai.ly]
  	  emails.each do |success|
  	    @user.email = success
  	    expect(@user).to be_valid
  	  end
  	end
  end

  describe "when email already in system" do
  	before do
  	  duplicate_user = @user.dup
  	  duplicate_user.email = duplicate_user.email.upcase
  	  duplicate_user.save
  	end

  	it { should_not be_valid }
  end

  describe "return value of authenticate" do
  	before { @user.save }
  	let (:found_user) { User.where(email: @user.email).take(1)[0] }

  	describe "with valid password" do
  	  it { should eq found_user.authenticate(@user.password) }
  	end

  	describe "with invalid password" do
      let(:user_invalid_pass) { found_user.authenticate("not_password") }

      it { should_not eq user_invalid_pass }
      specify { expect(user_invalid_pass).to be_false }
    end
  end

end
