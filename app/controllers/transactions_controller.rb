class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show ]

  # GET /transactions or /transactions.json
  def index
    @transactions = Transaction.page(params[:page]).per(25).order('id DESC')
    @transactions = @transactions.joins(:user).where(user: { role: :user }) unless view_context.admin?
  end

  # GET /transactions/1 or /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
    @transaction.user_id = params[:user_id]
    @transaction.amount = 1
  end

  # GET /transactions/burn_new
  def burn_new
    @transaction = Transaction.new
    @transaction.user_id = params[:user_id]
    @transaction.amount = 1
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.token_id = ENV['TOKEN_ID']
    @transaction.transaction_type = Transaction.transaction_types[:transfer]
    respond_to do |format|
      if @transaction.save
        res = TapyrusApi.put_tokens_transfer(@transaction.token_id, address: @transaction.to_user.address, amount: @transaction.amount, access_token: @transaction.user.access_token)
        logger.info(res)
        if res.present?
          # 情報を更新
          @transaction.txid = res[:txid]
          @transaction.save!
          user = @transaction.user
          user.amount -= @transaction.amount
          user.save!
          to_user = @transaction.to_user
          to_user.amount += @transaction.amount
          to_user.save!
        else
          Rails.logger.error("#{self.class.name}##{__method__} res=#{res}")
          flash.now[:alert] = 'TapyrusAPIの接続で障害が発生しました'
          render :new, status: :unprocessable_entity
        end

        format.html { redirect_to transaction_url(@transaction), notice: "transaction was successfully created." }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /transactions/burn or /transactions/burn.json
  def burn
    @transaction = Transaction.new(transaction_params)
    @transaction.token_id = ENV['TOKEN_ID']
    @transaction.transaction_type = Transaction.transaction_types[:burn]
    respond_to do |format|
      if @transaction.save
        TapyrusApi.delete_token(@transaction.token_id, amount: @transaction.amount, access_token: @transaction.user.access_token)

        # 情報を更新
        user = @transaction.user
        user.amount -= @transaction.amount
        user.save!

        format.html { redirect_to transaction_url(@transaction), notice: "transaction was successfully created." }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :burn_new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:txid, :token_id, :transaction_type, :amount, :address, :user_id, :to_user_id, :memo)
    end
end
