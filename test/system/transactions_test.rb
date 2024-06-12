require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  setup do
    @transaction = transactions(:one)
  end

  test "visiting the index" do
    visit transactions_url
    assert_selector "h1", text: "Transactions"
  end

  test "should create transaction" do
    visit transactions_url
    click_on "New transaction"

    fill_in "Address", with: @transaction.address
    fill_in "Amount", with: @transaction.amount
    fill_in "From user", with: @transaction.from_user_id
    fill_in "Memo", with: @transaction.memo
    fill_in "To user", with: @transaction.to_user_id
    fill_in "Token", with: @transaction.token_id
    fill_in "Txid", with: @transaction.txid
    click_on "Create Transaction"

    assert_text "Transaction was successfully created"
    click_on "Back"
  end

  test "should update Transaction" do
    visit transaction_url(@transaction)
    click_on "Edit this transaction", match: :first

    fill_in "Address", with: @transaction.address
    fill_in "Amount", with: @transaction.amount
    fill_in "From user", with: @transaction.from_user_id
    fill_in "Memo", with: @transaction.memo
    fill_in "To user", with: @transaction.to_user_id
    fill_in "Token", with: @transaction.token_id
    fill_in "Txid", with: @transaction.txid
    click_on "Update Transaction"

    assert_text "Transaction was successfully updated"
    click_on "Back"
  end

  test "should destroy Transaction" do
    visit transaction_url(@transaction)
    click_on "Destroy this transaction", match: :first

    assert_text "Transaction was successfully destroyed"
  end
end
