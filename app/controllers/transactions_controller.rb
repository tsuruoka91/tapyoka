class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]

  # GET /transactions or /transactions.json
  def index
    @transactions = Transaction.page(params[:page]).per(25).order('id DESC')
  end

  # GET /transactions/1 or /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
    @transaction.amount = 1
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.token_id = ENV['TOKEN_ID']
    respond_to do |format|
      if @transaction.valid?

        res = TapyrusApi.put_tokens_transfer(@transaction.token_id, address: @transaction.to_user.address, amount: @transaction.amount, access_token: @transaction.user.access_token)
        logger.info(res)
        if res.present?
          @transaction.txid = res[:txid]
          @transaction.save!
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

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to transaction_url(@transaction), notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to transactions_url, notice: "transaction was successfully destroyed." }
      format.json { head :no_content }
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
