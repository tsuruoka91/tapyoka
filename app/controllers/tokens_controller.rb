class TokensController < ApplicationController
  def index
    @tokens = Kaminari.paginate_array(TapyrusApi.get_tokens.reverse).page(params[:page])
  end

  def new
    if request.fullpath.split('/').last == 'transfer'
      @form = Token::TransferForm.new
      @form.amount = 1
      return render :transfer
    else
      @form = Token::Form.new
    end
  end

  def create
    @form = Token::Form.new(create_params)
    if @form.validate
      res = TapyrusApi.post_tokens_issue(amount: @form.amount, token_type: @form.token_type, split: @form.split)
      logger.info(res)
      if res.present?
        redirect_to tokens_path, notice: 'Tokenを作成しました。反映されるまでしばらく時間がかかります。'
      else
        Rails.logger.error("#{self.class.name}##{__method__} res=#{res}")
        flash.now[:alert] = 'TapyrusAPIの接続で障害が発生しました'
        render :new, status: :unprocessable_entity
      end
    else
      render :new
    end
  rescue StandardError, RuntimeError => e
    Rails.logger.error(e)
    flash.now[:alert] = 'Tokenの作成に失敗しました'
    render :new
  end

  def transfer
    @form = Token::TransferForm.new(transfer_params)

    if @form.validate
      from_user = User.find @form.from_user
      to_user = User.find @form.to_user
      res = TapyrusApi.put_tokens_transfer(ENV['TOKEN_ID'], address: to_user.address, amount: @form.amount, access_token: from_user.access_token)
      logger.info(res)
      if res.present?
        t = Transaction.new
        t.txid = res[:txid]
        t.token_id = res[:token_id]
        t.transaction_type = Transaction.transaction_types[:transfer]
        t.amount = @form.amount
        t.user_id = from_user.id
        t.to_user_id = to_user.id
        t.address = to_user.address
        t.memo = @form.memo
        t.save!
        redirect_to tokens_path, notice: 'Tokenを送付しました。'
      else
        Rails.logger.error("#{self.class.name}##{__method__} res=#{res}")
        flash.now[:alert] = 'TapyrusAPIの接続で障害が発生しました'
        render :transfer, status: :unprocessable_entity
      end
    else
      render :transfer, status: :unprocessable_entity
    end
  rescue StandardError, RuntimeError => e
    Rails.logger.error(e)
    flash.now[:alert] = 'Tokenの送付に失敗しました'
    render :transfer, status: :unprocessable_entity
  end

  def burn_select
    @form = Token::BurnForm.new
    @form.amount = 1
  end

  def burn
    @form = Token::BurnForm.new(burn_params)

    if @form.validate
      user = User.find @form.user
      res = TapyrusApi.delete_token(ENV['TOKEN_ID'], amount: @form.amount, access_token: user.access_token)
      logger.info(res)
      t = Transaction.new
      t.token_id = ENV['TOKEN_ID']
      t.transaction_type = Transaction.transaction_types[:burn]
      t.amount = @form.amount
      t.user_id = user.id
      t.memo = @form.memo
      t.save!
      redirect_to tokens_path, notice: 'Tokenを焼却しました。'
    else
      render :burn_select, status: :unprocessable_entity
    end
  rescue StandardError, RuntimeError => e
    Rails.logger.error(e)
    flash.now[:alert] = 'Tokenの焼却に失敗しました'
    render :burn_select, status: :unprocessable_entity
  end

  private

  def create_params
    params.require(:token).permit(:amount, :token_type, :split)
  end

  def transfer_params
    params.require(:token).permit(:from_user, :to_user, :amount, :memo)
  end

  def burn_params
    params.require(:token).permit(:user, :amount, :memo)
  end
end
