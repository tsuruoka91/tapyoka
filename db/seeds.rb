# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# 管理者ユーザーを作成
admin_user = User.find_by(id: 1)

if admin_user
  puts "管理者ユーザーは既に存在します: #{admin_user.name} (ID: #{admin_user.id})"
  puts "  - name: #{admin_user.name}"
  puts "  - access_token: #{admin_user.access_token}"
  puts "  - address: #{admin_user.address}"
  puts "  - amount: #{admin_user.amount}"
else
  # 新規作成の場合のみ
  admin_user = User.new(
    name: 'Admin User',
    access_token: 'admin_access_token_12345',
    address: 'admin_blockchain_address_xyz',
    amount: 10000
  )
  
  if admin_user.save
    puts "管理者ユーザーが作成されました: #{admin_user.name} (ID: #{admin_user.id})"
  else
    puts "管理者ユーザーの作成に失敗しました: #{admin_user.errors.full_messages.join(', ')}"
  end
  
  # IDが1でない場合の警告
  if admin_user.persisted? && admin_user.id != 1
    puts "警告: 管理者ユーザーのIDが1ではありません (ID: #{admin_user.id})"
  end
end
