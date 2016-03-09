class TransactionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :iframe, :status]
  before_filter :strip_iframe_protection

  def create
    @product = Product.find_by!(
      permalink: params[:permalink]
    )

    token = params[:stripeToken]

    sale = @product.sales.create(
      stripe_token: params[:stripeToken],
      amount: @product.price,
      email: params[:email],
      name: params[:fname] + " " + params[:lname],
      phone: params[:phone],
      line1: params[:line1],
      line2: params[:line2],
      city: params[:city],
      region: params[:state],
      postal_code: params[:postal_code],
      country:  'US',
    )

    if sale.save
      StripeCharger.perform_async(sale.guid)
      render json: { guid: sale.guid }
    else
      errors = sale.errors.full_messages
      render json: {
        error: errors.join(" ")
      }, status: 400
    end
  end

  def status
    @sale = Sale.where(guid: params[:guid]).first
    render nothing: true, status: 404 and return unless @sale
    render json: {guid: @sale.guid, status: @sale.state, error: @sale.error}
  end

  def new
    @product = Product.find_by!(permalink: params[:permalink])
  end

  def pickup
    @sale = Sale.find_by!(guid: params[:guid])
    @product = @sale.product
  end


  def download
    @sale = Sale.find_by!(guid: params[:guid])
    resp = HTTParty.get(@sale.product.file.url)
    filename = @sale.product.file.url
    send_data resp.body, :filename => File.basename(filename), :content_type => resp.headers['Content-Type']
  end


  def iframe
    @product = Product.find_by!(permalink: params[:permalink])
    @sale = Sale.new(product_id: @product)
  end

  def upsell
    @product = Product.find_by!(permalink: 'transform-x6')
    @sale = Sale.find_by!(guid: params[:guid])

  end

  private
  def strip_iframe_protection
    response.headers.delete('X-Frame-Options')
  end
end
