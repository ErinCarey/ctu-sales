class ReceiptMailer < ActionMailer::Base
  add_template_helper ApplicationHelper
  def receipt(charge)
    @charge = charge
    @sale = Sale.find_by!(stripe_id: @charge.id)
    html = render_to_string('receipt_mailer/receipt.html')

    pdf = Docverter::Conversion.run do |c|
      c.from = 'html'
      c.to = 'pdf'
      c.content = html
    end

    attachments['receipt.pdf'] = pdf
    mail(to: @sale.email_address, subject: 'Receipt for your purchase')
  end
end
