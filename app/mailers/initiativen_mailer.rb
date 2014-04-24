class InitiativenMailer < ActionMailer::Base
   default from: APP[:default_from]

   def new_comment_email(comment, subscription)
     @initiative = subscription.subscribable
     @subscriber = subscription.user
     @comment = comment
     @comment_author = comment.user.try(:username) || comment.user_name
     mail(:to => @subscriber.email,
          :subject => "[#{APP[:name]}] Neuer Kommentar zur Initiative " + @initiative.title,
          :template_name => 'new_comment_mail')
   end
  def initiator_email(sender, initiative, text)
    @author = initiative.user
    @message = text
    @initiative = initiative
    @anfrager = sender
    mail(:to => @author.email, :subject => "[#{APP[:name]}] Nachricht zu Ihrer Initiative", :template_name => 'initiator_email')
  end

  def initiator_moderator_email(sender, initiative, text)
    @message = text
    @initiative = initiative
    @anfrager = sender
    mail(:to => "moderatoren@unserac.de", :subject => "[#{APP[:name]}] Nachricht von einem Initiator", :template_name => 'moderator_email')
  end

  def initiator_reminder(initiative)
    @initiative = initiative
    mail(:to => initiative.user.email, :subject => "[#{APP[:name]}]" + initiative.title, :template_name => 'initiator_reminder')
  end
 end
