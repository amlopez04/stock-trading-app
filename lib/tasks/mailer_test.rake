namespace :mailer do
  desc "Test email delivery with Resend (production-like configuration)"
  task test: :environment do
    puts "=" * 60
    puts "Testing Email Delivery"
    puts "=" * 60
    
    # Get test email from environment or prompt
    test_email = ENV["TEST_EMAIL"] || begin
      print "Enter email address to send test email to: "
      $stdin.gets.chomp
    end
    
    if test_email.blank?
      puts "❌ No email address provided. Exiting."
      exit 1
    end
    
    puts "\n📧 Sending test email to: #{test_email}"
    puts "📬 Using delivery method: #{ActionMailer::Base.delivery_method}"
    
    # Test Devise confirmation email
    begin
      # Create a test user (or use existing)
      user = User.find_or_create_by(email: test_email) do |u|
        u.password = "test_password_123"
        u.password_confirmation = "test_password_123"
        u.confirmed_at = nil # Make it unconfirmed so we can test confirmation
      end
      
      # Send confirmation email
      puts "\n🔄 Sending Devise confirmation email..."
      user.send_confirmation_instructions
      
      puts "✅ Confirmation email sent successfully!"
      puts "\n📋 Email Details:"
      puts "   From: #{ActionMailer::Base.default[:from]}"
      puts "   To: #{test_email}"
      puts "   Subject: Confirmation instructions"
      
      if ActionMailer::Base.delivery_method == :smtp
        puts "\n✅ Using SMTP (Resend) - Check your inbox!"
        puts "   If you don't see it, check spam folder."
      else
        puts "\n⚠️  Using #{ActionMailer::Base.delivery_method} - Email opened in browser"
      end
      
    rescue => e
      puts "\n❌ Error sending email:"
      puts "   #{e.message}"
      puts "\n🔍 Troubleshooting:"
      puts "   1. Check your .env file has SMTP credentials"
      puts "   2. Verify SMTP_PASSWORD is set correctly"
      puts "   3. Make sure MAILER_SENDER is verified in Resend"
      puts "   4. Check Resend API key is valid"
      exit 1
    end
    
    puts "\n" + "=" * 60
    puts "Test complete!"
    puts "=" * 60
  end
  
  desc "Test email configuration"
  task check: :environment do
    puts "=" * 60
    puts "Email Configuration Check"
    puts "=" * 60
    
    puts "\n📧 Current Environment: #{Rails.env}"
    puts "📬 Delivery Method: #{ActionMailer::Base.delivery_method}"
    puts "🌐 Default URL Options: #{ActionMailer::Base.default_url_options}"
    
    if ActionMailer::Base.delivery_method == :smtp
      settings = ActionMailer::Base.smtp_settings
      puts "\n📮 SMTP Settings:"
      puts "   Address: #{settings[:address]}"
      puts "   Port: #{settings[:port]}"
      puts "   Domain: #{settings[:domain]}"
      puts "   Username: #{settings[:user_name]}"
      puts "   Password: #{settings[:password].present? ? '***' + settings[:password][-4..-1] : 'NOT SET'}"
      puts "   Authentication: #{settings[:authentication]}"
      
      if settings[:password].blank?
        puts "\n⚠️  WARNING: SMTP_PASSWORD is not set!"
        puts "   Add SMTP_PASSWORD to your .env file"
      end
    end
    
    puts "\n" + "=" * 60
  end
end

