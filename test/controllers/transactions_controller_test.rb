require "test_helper"
require 'minitest/mock'

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:one)
  end

  test "should get index" do
    get transactions_url
    assert_response :success
  end

  test "should get new" do
    get new_transaction_url(user_id: @transaction.user_id)
    assert_response :success
  end

  test "should create transaction" do
    assert_difference("Transaction.count") do
      TapyrusApi.stub(:put_tokens_transfer, {txid: @transaction.txid}) do
        post transactions_url, params: {
          transaction: {
            txid: @transaction.txid,
            token_id: @transaction.token_id,
            address: @transaction.address,
            transaction_type: @transaction.transaction_type,
            amount: @transaction.amount,
            user_id: @transaction.user_id,
            to_user_id: @transaction.to_user_id,
            memo: @transaction.memo
          }
        }
      end
    end

    assert_redirected_to transaction_url(Transaction.last)
  end

  test "should show transaction" do
    get transaction_url(@transaction)
    assert_response :success
  end
end
