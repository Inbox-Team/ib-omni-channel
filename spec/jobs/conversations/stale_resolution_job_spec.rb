require 'rails_helper'

RSpec.describe Conversations::StaleResolutionJob do
  subject(:job) { described_class.perform_later }

  let(:account) { create(:account) }
  let(:auto_resolve_after_ms) { 1_296_000_000 }
  let(:epsilon_ms) { 1 }

  it 'enqueues the job' do
    expect { job }.to have_enqueued_job(described_class)
      .on_queue('scheduled_jobs')
  end

  it 'resolves conversations across all accounts when last_activity_at is stale' do
    other_account = create(:account)

    with_modified_env GLOBAL_AUTO_RESOLVE_AFTER_MS: auto_resolve_after_ms.to_s do
      travel_to(Time.current) do
        now = Time.current
        stale_last_activity_at = now - ((auto_resolve_after_ms + epsilon_ms) / 1000.0)
        fresh_last_activity_at = now - ((auto_resolve_after_ms - epsilon_ms) / 1000.0)

        open_conversation = create(:conversation, account: account, status: :open, last_activity_at: stale_last_activity_at)
        pending_conversation = create(:conversation, account: account, status: :pending, last_activity_at: stale_last_activity_at)
        snoozed_conversation = create(:conversation, account: other_account, status: :snoozed, last_activity_at: stale_last_activity_at)

        fresh_conversation = create(:conversation, account: account, status: :open, last_activity_at: fresh_last_activity_at)
        already_resolved = create(:conversation, account: other_account, status: :resolved, last_activity_at: stale_last_activity_at)

        described_class.perform_now

        expect(open_conversation.reload.status).to eq('resolved')
        expect(pending_conversation.reload.status).to eq('resolved')
        expect(snoozed_conversation.reload.status).to eq('resolved')

        expect(fresh_conversation.reload.status).to eq('open')
        expect(already_resolved.reload.status).to eq('resolved')
      end
    end
  end

  it 'resolves only a limited number of conversations in a single execution' do
    stub_const('Limits::BULK_ACTIONS_LIMIT', 2)
    with_modified_env GLOBAL_AUTO_RESOLVE_AFTER_MS: auto_resolve_after_ms.to_s do
      travel_to(Time.current) do
        now = Time.current
        stale_last_activity_at = now - ((auto_resolve_after_ms + epsilon_ms) / 1000.0)

        create_list(:conversation, 3, account: account, status: :open, last_activity_at: stale_last_activity_at)

        described_class.perform_now

        expect(Conversation.resolved.count).to eq(Limits::BULK_ACTIONS_LIMIT)
      end
    end
  end
end
