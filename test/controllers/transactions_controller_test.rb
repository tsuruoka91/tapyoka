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
      TapyrusApi.stub(:put_tokens_transfer, { txid: @transaction.txid }) do
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

    assert_redirected_to root_url
  end

  test "should show transaction" do
    get transaction_url(@transaction)
    assert_response :success
  end

  test "should get gift_new" do
    get gift_new_transactions_url(user_id: users(:one).id)
    assert_response :success
    assert_not_nil assigns(:transaction)
    assert_equal users(:one).id, assigns(:transaction).to_user_id
    assert_equal 1, assigns(:transaction).amount
  end

  test "should get burn_new" do
    get burn_new_transactions_url(user_id: users(:one).id)
    assert_response :success
    assert_not_nil assigns(:transaction)
    assert_equal users(:one).id, assigns(:transaction).user_id
    assert_equal 1, assigns(:transaction).amount
  end

  test "should create gift transaction successfully" do
    # Setup: Ensure users have sufficient amount
    gift_receiver = users(:two)
    admin_user = users(:admin)
    
    # 初期残高を設定
    admin_user.update(amount: 100)
    gift_receiver.update(amount: 50)
    
    # 初期残高を記録
    initial_admin_amount = admin_user.amount
    initial_receiver_amount = gift_receiver.amount
    
    assert_difference("Transaction.count") do
      TapyrusApi.stub(:put_tokens_transfer, { txid: "test_txid_123" }) do
        post gift_transactions_url, params: {
          transaction: {
            to_user_id: gift_receiver.id,
            amount: 10,
            memo: "Test gift"
          }
        }
      end
    end

    assert_redirected_to root_url
    
    # Check transaction was created correctly
    transaction = Transaction.last
    assert_equal admin_user.id, transaction.user_id  # 管理者
    assert_equal gift_receiver.id, transaction.to_user_id
    assert_equal 10, transaction.amount
    assert_equal "gift", transaction.transaction_type
    assert_equal "test_txid_123", transaction.txid
    
    # Check user balances were updated
    admin_user.reload
    gift_receiver.reload
    # 管理者ユーザーの残高が減少
    assert_equal initial_admin_amount - 10, admin_user.amount
    # 受取人の残高が増加
    assert_equal initial_receiver_amount + 10, gift_receiver.amount
  end

  test "should handle gift transaction failure" do
    gift_receiver = users(:two)
    
    assert_no_difference("Transaction.count") do
      post gift_transactions_url, params: {
        transaction: {
          to_user_id: gift_receiver.id,
          amount: -5,  # Invalid amount
          memo: "Invalid gift"
        }
      }
    end
    
    assert_response :unprocessable_content
  end

  test "should create burn transaction successfully" do
    # Setup: Ensure user has sufficient amount
    burn_user = users(:one)
    burn_user.update(amount: 100)
    
    assert_difference("Transaction.count") do
      TapyrusApi.stub(:delete_token, { txid: "burn_txid_123" }) do
        post burn_transactions_url, params: {
          transaction: {
            user_id: burn_user.id,
            amount: 20,
            memo: "Test burn"
          }
        }
      end
    end

    assert_redirected_to root_url
    
    # Check transaction was created correctly
    transaction = Transaction.last
    assert_equal burn_user.id, transaction.user_id
    assert_equal 20, transaction.amount
    assert_equal "burn", transaction.transaction_type
    assert_equal "burn_txid_123", transaction.txid
    
    # Check user balance was updated
    burn_user.reload
    assert_equal 80, burn_user.amount  # 100 - 20
  end

  test "should handle burn transaction failure" do
    burn_user = users(:one)
    
    assert_no_difference("Transaction.count") do
      post burn_transactions_url, params: {
        transaction: {
          user_id: burn_user.id,
          amount: 0,  # Invalid amount
          memo: "Invalid burn"
        }
      }
    end
    
    assert_response :unprocessable_content
  end

  test "should handle create transaction failure" do
    assert_no_difference("Transaction.count") do
      TapyrusApi.stub(:put_tokens_transfer, { txid: "test_txid" }) do
        post transactions_url, params: {
          transaction: {
            user_id: users(:one).id,
            to_user_id: nil,  # Missing required to_user_id for transfer
            amount: 10,
            memo: "Invalid transfer"
          }
        }
      end
    end
    
    assert_response :unprocessable_content
  end

  test "should handle TapyrusApi failure gracefully" do
    # Setup users
    sender = users(:one)
    receiver = users(:two)
    sender.update(amount: 100)
    receiver.update(amount: 50)
    
    assert_difference("Transaction.count") do
      TapyrusApi.stub(:put_tokens_transfer, nil) do  # API returns nil (failure)
        post transactions_url, params: {
          transaction: {
            user_id: sender.id,
            to_user_id: receiver.id,
            amount: 10,
            memo: "Test transfer with API failure"
          }
        }
      end
    end
    
    # Even if API fails, transaction should still be saved and balances updated
    assert_redirected_to root_url
    
    transaction = Transaction.last
    assert_nil transaction.txid  # txid should be nil when API fails
    
    # Balances should still be updated
    sender.reload
    receiver.reload
    assert_equal 90, sender.amount
    assert_equal 60, receiver.amount
  end
end
