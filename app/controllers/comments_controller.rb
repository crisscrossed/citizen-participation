class CommentsController < ApplicationController
  load_and_authorize_resource

  before_filter :ensure_valid_recaptcha, only: [:create]

  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(params[:comment])
    @comment.user = current_user

    if @comment.save
      subscriptions = Subscription.where(subscribable_id: @commentable.id, subscribable_type: @comment.commentable_type)
      if current_user
        subscriptions = subscriptions.where('subscriptions.user_id != ?', current_user.id)
      end
      subscriptions.each do |subscription|
        InitiativenMailer.new_comment_email(@comment, subscription).deliver
      end
      redirect_to @commentable, :notice => "Kommentar erfolgreich erstellt."
    else
      redirect_to @commentable, :alert => @comment.errors.full_messages.join("<br>").html_safe
    end
  end

  def update
    @commentable = find_commentable
    @comment.content = params[:comment][:content]

    if @comment.save
      redirect_to @commentable, :notice => "Kommentar erfolgreich aktualisiert."
    else
      redirect_to @commentable, :alert => @comment.errors.full_messages.join("<br>").html_safe
    end

  end

  def destroy
    @commentable = find_commentable
    @comment.destroy

    respond_to do |format|
      format.html do
        redirect_to @commentable, :alert => "Kommentar erfolgreich gelöscht."
      end
      format.json do
        if current_user.superadmin?
          head :no_content
        else
          render text: 'Access denied', status: 401
        end
      end
    end
  end

  private

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
  end
end
