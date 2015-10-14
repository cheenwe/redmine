    user = User.new :firstname => "Redmine",
                    :lastname => "Admin",
                    :mail => "cxhyun@13.com",
                    :mail_notification => "only_my_events",
                    :status => 1
    user.login = 'admin'
    user.password = "123123123"
    user.admin = true
    user.save!
puts "add create success"