class CreditCardsController < ApplicationController
  before_action :move_to_root
  before_action :set_card, only: [:new, :show, :destroy, :buy, :pay ]

  require "payjp"

  def new
    if @card.present?  #カード情報が登録されている場合
      redirect_to credit_card_path(current_user.id)  #showアクションへ
    else
      card = CreditCard.where(user_id: current_user.id)
    end
  end

  def create
    #まず秘密鍵を取得し、payjpと照合
    Payjp.api_key = Rails.application.credentials[:PAYJP_SECRET_KEY]
    if params['payjp-token'].blank?
      redirect_to action: :new
    else
      # トークン発行後、payjp上で顧客データを生成(カードトークンを生成してもそれを紐付ける顧客が必要であるため)
      customer = Payjp::Customer.create(
        card: params['payjp-token'],  #newアクション後のJQueryで取得したトークンを顧客に紐付け
        metadata: {user_id: current_user.id},
        description: 'test'
      )
      #railsのDB上にもカード情報とそれに紐づく顧客情報を保存
      @card = CreditCard.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      if @card.save  #保存できたらカード登録完了ページへ遷移
        redirect_to regist_done_credit_cards_path
      else
        redirect_to action: :new  #保存できなければカード登録ページへ遷移
      end
    end
  end

  private
  def move_to_root  #ログインしていなければ、トップ画面に遷移
    redirect_to root_path unless user_signed_in?
  end

  def set_card   #各アクション内でuser_idとデータベースに保存れたcard情報を紐付けておく
    @card = CreditCard.find_by(user_id: current_user.id)
  end
end
