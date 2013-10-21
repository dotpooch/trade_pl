=begin
class API < Grape::API

#set :views, "../app/views/layouts/application"
set :views, :'../app/views/layouts/application'
#set :views, Proc.new { File.join(root, "../app/views/layouts/application") }
#set :views, File.dirname(__FILE__) + '/templates'

#set :erb, layout => :"layout/application" # or whatever rendering engine you chose
#One important thing to remember is that you always have to reference templates with symbols, even if they’re in a subdirectory (in this case use :'subdir/template'). Rendering methods will render any strings passed to them directly. 
#Templates are assumed to be located directly under the ./views directory. To use a different views directory:

#set :views, settings.root + '/templates'

#One important thing to remember is that you always have to reference templates with symbols, even if they’re in a subdirectory (in this case, use :'subdir/template'). You must use a symbol because otherwise rendering methods will render any strings passed to them directly


  #version 'v1'#, :using => :header, :vendor => 'twitter', :format => :json

  helpers do
#    def current_user
#      @current_user ||= User.authorize!(env)
#    end

 #   def authenticate!
 #     error!('401 Unauthorized', 401) unless current_user
 #   end
  end

 # resource :statuses do
 #   get :public_timeline do
 #     Tweet.limit(20)
 #   end

  #  get :home_timeline do
  #    authenticate!
  #    current_user.home_timeline
  #  end

    get '/homes' do
      @home="Hello Works!"
      {'hello' => @home}
    end

 # end

  #resource :account do
   # before{ authenticate! }

    #get '/private' do
     # "Congratulations, you found the secret!"
    #end
  #end
end
=end
