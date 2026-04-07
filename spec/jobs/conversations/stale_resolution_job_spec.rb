require 'rails_helper'

RSpec.describe Conversations::StaleResolutionJob do
  subject(:job) { described_class.perform_later }

  let(:account) { create(:account) }

  it 'enqueues the job' do
    expect { job }.to have_enqueued_job(described_class)
      .on_queue('scheduled_jobs')
  end

  it 'resolves conversations across all accounts when last_activity_at is stale' do
    other_account = create(:account)

    open_conversation = create(:conversation, account: account, status: :open, last_activity_at: 16.days.ago)
    pending_conversation = create(:conversation, account: account, status: :pending, last_activity_at: 16.days.ago)
    snoozed_conversation = create(:conversation, account: other_account, status: :snoozed, last_activity_at: 16.days.ago)

    fresh_conversation = create(:conversation, account: account, status: :open, last_activity_at: 14.days.ago)
    already_resolved = create(:conversation, account: other_account, status: :resolved, last_activity_at: 16.days.ago)

    described_class.perform_now

    expect(open_conversation.reload.status).to eq('resolved')
    expect(pending_conversation.reload.status).to eq('resolved')
    expect(snoozed_conversation.reload.status).to eq('resolved')

    expect(fresh_conversation.reload.status).to eq('open')
    expect(already_resolved.reload.status).to eq('resolved')
  end

  it 'resolves only a limited number of conversations in a single execution' do
    stub_const('Limits::BULK_ACTIONS_LIMIT', 2)
    create_list(:conversation, 3, account: account, status: :open, last_activity_at: 16.days.ago)

    described_class.perform_now

    expect(Conversation.resolved.count).to eq(Limits::BULK_ACTIONS_LIMIT)
  end
end
