StripeEvent.event_retriever = lambda do |params|
  return nil if StripeWebhook.exists?(stripe_id: params[:id])
  StripeWebhook.create!(stripe_id: params[:id])
  Stripe::Event.retrieve(params[:id])
end

StripeEvent.configure do |events|
  events.subscribe 'charge.dispute.created' do |event|
    StripeMailer.admin_dispute_created(event.data.object).deliver
  end

  events.subscribe 'charge.succeeded' do |event|
    charge = event.data.object
    ReceiptMailer.receipt(charge).deliver
    StripeMailer.admin_charge_succeeded(charge).deliver
  end
end
