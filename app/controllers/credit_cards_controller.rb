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

  def show
    # ログイン中のユーザーのクレジットカード登録の有無を判断
    @card = CreditCard.find_by(user_id: current_user.id)
    if @card.blank?
      # 未登録なら新規登録画面に
      redirect_to action: "new" 
    else
      # 前前回credentials.yml.encに記載したAPI秘密鍵を呼び出します。
      Payjp.api_key = Rails.application.credentials.dig(:payjp, :PAYJP_SECRET_KEY)
      # ログインユーザーのクレジットカード情報からPay.jpに登録されているカスタマー情報を引き出す
      customer = Payjp::Customer.retrieve(@card.customer_id)
      # カスタマー情報からカードの情報を引き出す
      @customer_card = customer.cards.retrieve(@card.card_id)

      ##カードのアイコン表示のための定義づけ
      @card_brand = @customer_card.brand
      case @card_brand
      when "Visa"
        # 例えば、Pay.jpからとってきたカード情報の、ブランドが"Visa"だった場合は返り値として
        # (画像として登録されている)Visa.pngを返す
        @card_src = "visa.png"
      when "JCB"
        @card_src = "jcb.png"
      when "MasterCard"
        @card_src = "master.png"
      when "American Express"
        @card_src = "amex.png"
      when "Diners Club"
        @card_src = "diners.png"
      when "Discover"
        @card_src = "discover.png"
      end

      #  viewの記述を簡略化
      ## 有効期限'月'を定義
      @exp_month = @customer_card.exp_month.to_s
      ## 有効期限'年'を定義
      @exp_year = @customer_card.exp_year.to_s.slice(2,3)
    end
  end

  def destroy
    # ログイン中のユーザーのクレジットカード登録の有無を判断
    @card = CreditCard.find_by(user_id: current_user.id)
    if @card.blank?
      # 未登録なら新規登録画面に
      redirect_to action: "new"
    else
      # 前前回credentials.yml.encに記載したAPI秘密鍵を呼び出します。
      Payjp.api_key = Rails.application.credentials.dig(:payjp, :PAYJP_SECRET_KEY)
      # ログインユーザーのクレジットカード情報からPay.jpに登録されているカスタマー情報を引き出す
      customer = Payjp::Customer.retrieve(@card.customer_id)
      # そのカスタマー情報を消す
      customer.delete
      @card.delete
      # 削除が完了しているか判断
      if @card.destroy
      # 削除完了していればdestroyのビューに移行
      # destroyビューを作るのが面倒であれば、flashメッセージを入れてトップページやマイページに飛ばしてもOK

      else
        # 削除されなかった場合flashメッセージを表示させて、showのビューに移行
        redirect_to credit_card_path(current_user.id), alert: "削除できませんでした。"
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
