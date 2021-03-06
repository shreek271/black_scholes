class ProductsController < ApplicationController
  include StringUtils

  before_action :set_product, only: [:edit, :show, :update, :destroy, :simulation_result, :set_call_price]
  before_action :set_call_put_price, only: [:show, :simulation_result]
  before_action :set_params_value, only: [:create, :update]

  def new
  	@product = Product.new
  end

  def create 	
    @product = Product.new(product_params)
    if @product.save
  	  flash[:success] = "Successfully Created The Product."
      redirect_to @product
    else
      flash[:danger] = "Something went wrong"
      render :new
    end
  end

  def edit
    @product.maturity_time = (@product.maturity_time*365).round
    @product.risk_free_rate = @product.risk_free_rate*100
    @product.volatility = @product.volatility*100
  end

  def update
  	if @product.update_attributes(product_params)
  	  flash[:success] = "Successfully Updated The Product."
      redirect_to @product
    else
      flash[:danger] = "Something went wrong"
      render :edit
    end
  end

  def simulation_result
    if params[:product][:s_id] == "sp"
      @sensitive_call_price = @product.price_call(params[:product][:sensitive_factor].to_f, @product.strike_price,@product.maturity_time , @product.risk_free_rate, @product.volatility, 0.0)
      @sensitive_put_price = @product.price_put(params[:product][:sensitive_factor].to_f, @product.strike_price,@product.maturity_time , @product.risk_free_rate, @product.volatility, 0.0)
    elsif params[:product][:s_id] == "et"
      params[:product][:sensitive_factor] = change_maturity_to_years(params[:product][:sensitive_factor])
      @sensitive_call_price = @product.price_call(@product.stock_price, @product.strike_price, params[:product][:sensitive_factor], @product.risk_free_rate, @product.volatility, 0.0)
      @sensitive_put_price = @product.price_put(@product.stock_price, @product.strike_price, params[:product][:sensitive_factor], @product.risk_free_rate, @product.volatility, 0.0)    
    elsif params[:product][:s_id] == "rfr"
      params[:product][:sensitive_factor] = change_to_decimal(params[:product][:sensitive_factor])
      @sensitive_call_price = @product.price_call( @product.stock_price, @product.strike_price, @product.maturity_time, params[:product][:sensitive_factor], @product.volatility, 0.0 )
      @sensitive_put_price = @product.price_put( @product.stock_price, @product.strike_price, @product.maturity_time, params[:product][:sensitive_factor], @product.volatility, 0.0 )
    elsif params[:product][:s_id] == "v"
      params[:product][:sensitive_factor] = change_to_decimal(params[:product][:sensitive_factor])  
      @sensitive_call_price = @product.price_call( @product.stock_price, @product.strike_price, @product.maturity_time, @product.risk_free_rate, params[:product][:sensitive_factor], 0.0 )
      @sensitive_put_price = @product.price_put( @product.stock_price, @product.strike_price, @product.maturity_time, @product.risk_free_rate, params[:product][:sensitive_factor], 0.0 )    
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def index
  	@products = Product.all.order('created_at DESC').paginate(page: params[:page], per_page: 10)
  end

  def destroy 
    if @product.destroy
      flash[:success] = "Deleted the Product"
      redirect_to products_path
    else
      flash[:danger] = "Something went wrong"
      redirect_to root_url
    end
  end

  private

  def set_product
    params_id = params[:id] || params[:product_id]
    @product = Product.find(params_id)
  end

  def product_params
  	params.require(:product).permit(:name, :risk_free_rate, :volatility, :strike_price, :maturity_time, :stock_price)
  end

  def set_params_value
    params[:product][:maturity_time] = change_maturity_to_years(params[:product][:maturity_time])
    params[:product][:risk_free_rate] = change_to_decimal(params[:product][:risk_free_rate])
    params[:product][:volatility] = change_to_decimal(params[:product][:volatility])
  end

  def set_call_put_price
    @call_price = @product.price_call( @product.stock_price, @product.strike_price, @product.maturity_time, @product.risk_free_rate, @product.volatility, 0.0 )
    @put_price = @product.price_put( @product.stock_price, @product.strike_price, @product.maturity_time, @product.risk_free_rate, @product.volatility, 0.0 )
  end

end