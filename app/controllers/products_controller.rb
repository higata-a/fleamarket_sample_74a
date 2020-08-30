class ProductsController < ApplicationController
  def index
  end

  def new
    @product = Product.new
    # @images = @product.images.build
    @product.images.build
  end
  
  def show
  end

  def edit
    @product = Product.find(params[:id])
    @product.images.build
  end
  
  def create
    @product = Product.new(product_params)
    # @images = @product.images.build

    if @product.save
      redirect_to root_path, notice:'商品出品が完了しました'
    else
      render :new
    end
  end

  private
  # カテゴリ機能実装後に.merge(category_id: 1)の部分は修正
  def product_params
    params.require(:product).permit(:name, :description, :price, :condition_id, :size_id, 
    :prefecture_id, :days_until_shipping_id, :shipping_charge_id, :brand_id, images_attributes:[:image, :_destroy, :id])
    .merge(user_id: current_user.id)
    .merge(category_id: 1)
  end
  
end
