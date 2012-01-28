class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    
    if user.nil?
      # Error	  
		#flash.now[:error] = "Invalid email/password combination"
		
		# Return a 0
		render :text => "0"
    else		
		sign_in user
		render :text => "1"
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
end
