class StripeMailer < ActionMailer::Base
  add_template_helper ApplicationHelper

  default from: 'support@changethatup.com'

  def admin_dispute_created(charge)
    @charge = charge
    @sale = Sale.find_by(stripe_id: @charge.id)
    if @sale
      mail(to: 'support@changethatup.com', subject: "Dispute created on charge #{@sale.guid} (#{charge.id})").deliver
    end
  end

  def admin_charge_succeeded(charge)
    @charge = charge
    @sale = Sale.find_by(stripe_id: @charge.id)
    mail(to: 'support@changethatup.com', subject: 'Purchase succeeded')
  end

  def receipt(charge)
    @charge = charge
    @sale = Sale.find_by!(stripe_id: @charge.id)
    mail(to: @sale.email, subject: "Thanks for purchasing #{@sale.product.name}")
  end
end
