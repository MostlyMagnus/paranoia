class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
	print "create start"
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    
    if user.nil?
      # Error
	  print "user nil"
      flash.now[:error] = "Invalid email/password combination"
      @title = "Sign in"
      
      render 'new'
    else
		print "user not nil"
      sign_in user
      redirect_to user
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
end
