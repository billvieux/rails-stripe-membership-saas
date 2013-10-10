class Subscription < ActiveRecord::Base
  attr_accessible :stripe_token, :coupon
  attr_accessor :stripe_token, :coupon  

  belongs_to :user
  before_save :update_stripe
  
  def update_stripe
    return true if user.email.include?(ENV['ADMIN_EMAIL'])
    return true if user.email.include?('@example.com') and not Rails.env.production?
    if customer_id.nil?
      if !stripe_token.present?
        raise "Stripe token not present. Can't create account."
      end
      if coupon.blank?
        customer = Stripe::Customer.create(
          :email => user.email,
          :description => user.name,
          :card => stripe_token,
          :plan => user.roles.first.name
        )
      else
        customer = Stripe::Customer.create(
          :email => user.email,
          :description => user.name,
          :card => stripe_token,
          :plan => user.roles.first.name,
          :coupon => coupon
        )
      end
    else
      customer = Stripe::Customer.retrieve(customer_id)
      if stripe_token.present?
        customer.card = stripe_token
      end
      customer.email = user.email
      customer.description = user.name
      customer.save
    end
    self.last_4_digits = customer.cards.data.first["last4"]
    self.customer_id = customer.id
    self.stripe_token = nil
    true
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "#{e.message}."
    self.stripe_token = nil
    false
  end
  
end
