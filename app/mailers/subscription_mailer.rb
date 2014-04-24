class SubscriptionMailer < ActionMailer::Base
  default from: APP[:default_from]

  def confirmation(subscription)
    @subscription = subscription
    mail(to: subscription.email, subject: "Confirm subscription")
  end

  def notify(subscription, models)
    @subscription = subscription
    @models = models
    mail(to: subscription.email, subject: "Themen-Abo")
  end

  def quarter(subscription, models)
    @subscription = subscription
    @models = models
    mail(to: subscription.email, subject: "Ortsteil-Abo")
  end
end