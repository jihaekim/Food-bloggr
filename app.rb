require "sinatra"
require "sinatra/activerecord"

require './models/post.rb'
require './models/user.rb'

enable :sessions
set :database, {adapter:"postgresql", database:"foodie"}

get "/" do

    if session[:user_id]
        @user = User.find_by(id: session[:user_id])
        @user_posts= Post.where(user_id: session[:user_id]).order("created_at")
        @allusers = User.all
        @posts=Post.order("created_at DESC").limit(6)
        
        erb :signed_out_homepage
    else
        @posts=Post.order("created_at DESC").limit(6)
        @allusers = User.all
        erb :signed_out_homepage
    end
  
end




# sign in

get "/sign-in" do
    erb :sign_in, :layout=> :sign_in_up
end


post "/sign-in" do
    @user = User.find_by(username: params[:username])
    if @user && @user.password == params[:password]
        session[:user_id]= @user.id

        redirect'/'
    else 
        redirect'/sign-in'
    end
end

# logout

get "/sign-out" do
    session[:user_id] = nil;
    redirect '/'
end



#sign up

get "/sign-up" do
    erb :sign_up, :layout=> :sign_in_up
end


post "/sign-up" do
    @user = User.create(
    username: params[:username],
    password: params[:password],
    firstname: params[:firstname],
    lastname: params[:lastname],
    birthday: params[:birthday],
    email: params[:email]
    )

    session[:user_id] = @user.id

    redirect '/'
end




get "/create-post" do
    @user = User.find_by(id: session[:user_id])
 erb :create_post
end


post "/create-post" do

@user = User.find_by(id: session[:user_id])
@user_posts = @user.posts.order('id ASC').reorder('date DESC')
@current_post = @post
@allusers = User.all

 @post = Post.create(
     date: params[:date],
     title: params[:title],
     photo_url: params[:photourl],
     content: params[:content],
      user_id: @user.id
 )

redirect"/post/#{@post.id}"

end




# GET POSTS BY ID
get'/user/:id' do
    @user = User.find_by(id: session[:user_id])
    @current_user = User.find(params[:id])
    @current_user_posts = @current_user.posts
    @user_posts = @current_user.posts.order("created_at DESC")
    @allusers = User.all

#  @user_posts= Post.where(user_id: session[:user_id])

erb :user_posts
end

get '/users/:id/edit' do
    @user = User.find_by(id: session[:user_id])
    @current_user=User.find(params[:id])
    erb :edit_user
end

put '/users/:id' do
    @current_user = User.find(params[:id])
    @current_user.update(
    username: params[:username],
    password: params[:password],
    firstname: params[:firstname],
    lastname: params[:lastname],
    birthday: params[:birthday],
    email: params[:email]
    )
    redirect '/'
end

delete'/users/:id' do
    @current_user = User.find(params[:id])
    @current_user.destroy
    session[:user_id]=nil
    redirect '/'
end



# GET ALL POSTS
get'/posts' do
    @user = User.find_by(id: session[:user_id])
    #below shows all other peoples posts
    @allposts = Post.order("created_at DESC")
    @allusers= User.all
   
    erb :all_posts
end


get '/post/:id' do
    @current_post = Post.find(params[:id])
    @user = User.find_by(id: session[:user_id])
    @random_user = User.order('RANDOM()').limit(4)
    @allusers=User.all
    @posts= Post.all
    @few_posts = Post.order('RANDOM()').limit(3)
   erb :view_post
  
end

#EDIT THE POSTS

get '/posts/:id/edit' do
    @current_post = Post.find(params[:id])
    @user = User.find_by(id: session[:user_id])
    @random_user = User.order('RANDOM()').limit(4)
    erb :edit_post
end


put '/posts/:id' do
    @user = User.find_by(id: session[:user_id])
    @random_user = User.order('RANDOM()').limit(4)
    @current_post = Post.find(params[:id])
    @allusers=User.all
    @posts= Post.all
    @few_posts = Post.order('RANDOM()').limit(3)
    @current_post.update(date: params[:date],
    title: params[:title],
    photo_url: params[:photourl],
    content: params[:content])

    erb :view_post
  
end

delete '/posts/:id' do
    @current_post = Post.find(params[:id])
    @current_post.destroy
    redirect '/'
end

