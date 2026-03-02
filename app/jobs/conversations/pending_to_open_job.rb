class Conversations::PendingToOpenJob < ApplicationJob
  queue_as :low

  def perform
    Conversation
      .where(status: :pending)
      .where.not(snoozed_until: nil)
      .where(snoozed_until: 3.days.ago..Time.current)
      .find_each(batch_size: 100) do |conversation|
        conversation.snoozed_until = nil
        conversation.open!
      end
  end
end
