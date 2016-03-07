class Sale < ActiveRecord::Base
  has_paper_trail
  include AASM


  aasm column: 'state' do
    state :pending, initial: true
    state :processing
    state :finished
    state :errored

    event :process, after: :charge_card do
      transitions from: :pending, to: :processing
    end

    event :finish do
      transitions from: :processing, to: :finished
    end

    event :fail do
      transitions from: :processing, to: :errored
    end
  end

  belongs_to :product
  before_save :populate_guid
  validates_uniqueness_of :guid

  private
  def populate_guid
    if new_record?
      while !valid? || self.guid.nil?
        self.guid = SecureRandom.random_number(1_000_000_000).to_s(36)
      end
    end
  end

  def charge_card
    begin
      save!
      charge = Stripe::Charge.create(
        amount: self.amount,
        currency: "usd",
        source: self.stripe_token,
        description: self.email,
        shipping: {
          address: {
            line1: self.line1,
            line2: self.line2,
            city: self.city,
            state: self.region,
            postal_code: self.postal_code,
            country: self.country,
          },
          name: self.name,
          phone: self.phone,
        },
      )
      balance = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)
      self.update(
        stripe_id:       charge.id,
        card_expiration: Date.new(charge.source.exp_year, charge.source.exp_month, 1),
        fee_amount:      balance.fee
      )
      self.finish!
    rescue Stripe::StripeError => e
      self.update_attributes(error: e.message)
      self.fail!
    end
  end
end
