class HomeController < BaseController
  require 'gruff'

  before_action :login_required, only: [:tweet, :post_my_weight, :post_my_weight_30]
  def index
  end

  def tweet
    text = "ちわあああああああああす"
    twitter_client.update(text)
    flash[:notice] = "tweet: #{text}"
    redirect_to root_path
  end

  def post_my_weight
    text = "今の体重は#{params[:weight]}kgでした。#{params[:memo]}"
    begin
      @current_user.measurements.create!(weight: params[:weight], body_fat_percentage: params[:body_fat_percentage], memo: params[:memo])
      measurements = if @current_user.measurements.length >=7 then 
                       @current_user.measurements.slice(-7, 7)
                     else
                       @current_user.measurements
                     end
      grapher = Grapher.new
      graph_image = grapher.write_graph(measurements)
      if current_user.update_name
        name = params[:weight].to_s + "kg" + @current_user.check_increase + "の"+ @current_user.name
        twitter_client.update_profile({:name => name})
      end
      twitter_client.update_with_media(text, File.open(graph_image))
      flash[:notice] = "tweet: #{text}." 
    rescue ActiveRecord::RecordInvalid => invalid
      @errors = invalid.record.errors
    rescue => e
      flash[:alert] = e.message
    ensure
      render 'home/index'
    end
  end

  def post_my_weight_30
    text = "最近30回分のグラフです"
    measurements = Measurement.where("user_id = '?'", @current_user.id)
                     .order("created_at DESC")
                     .limit(30)
    measurements = measurements.sort
    grapher = Grapher.new
    graph_image = grapher.write_graph(measurements)
    twitter_client.update_with_media(text, File.open(graph_image))
    flash[:notice] = "tweet: #{text}." 
    redirect_to root_path
  end

  private
  def twitter_client
    Twitter::Client.new(
      :oauth_token        => @current_user.token,
      :oauth_token_secret => @current_user.secret
    )
  end
end
