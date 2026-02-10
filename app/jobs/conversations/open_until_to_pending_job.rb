class Conversations::OpenUntilToPendingJob < ApplicationJob
  queue_as :low

  def perform
    Conversation
      .where(status: :open)
      .where.not(snoozed_until: nil)
      .where(snoozed_until: 3.days.ago..Time.current)
      .find_each(batch_size: 100, &:pending!)
  end
end
