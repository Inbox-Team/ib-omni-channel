<script setup>
import { ref, computed } from 'vue';
import { useStore, useStoreGetters } from 'dashboard/composables/store';
import { useAlert } from 'dashboard/composables';
import { useI18n } from 'vue-i18n';
import { useEmitter } from 'dashboard/composables/emitter';
import { getUnixTime } from 'date-fns';
import { findSnoozeTime } from 'dashboard/helper/snoozeHelpers';
import { CMD_PENDING_AT_CONVERSATION } from 'dashboard/helper/commandbar/events';
import wootConstants from 'dashboard/constants/globals';
import CustomOpenUntilModal from 'dashboard/components/CustomOpenUntilModal.vue';

const store = useStore();
const getters = useStoreGetters();
const { t } = useI18n();
const showCustomPendingAtModal = ref(false);

const selectedChat = computed(() => getters.getSelectedChat.value);
const contextMenuChatId = computed(() => getters.getContextMenuChatId.value);

const toggleStatus = async (status, snoozedUntil) => {
  await store.dispatch('toggleStatus', {
    conversationId: selectedChat.value?.id || contextMenuChatId.value,
    status,
    snoozedUntil,
  });
  store.dispatch('setContextMenuChatId', null);
  useAlert(t('CONVERSATION.CHANGE_STATUS'));
};

const onCmdPendingAtConversation = pendingAtType => {
  if (pendingAtType === wootConstants.SNOOZE_OPTIONS.UNTIL_CUSTOM_TIME) {
    showCustomPendingAtModal.value = true;
  } else {
    toggleStatus(
      wootConstants.STATUS_TYPE.OPEN,
      findSnoozeTime(pendingAtType) || null
    );
  }
};

const choosePendingAtTime = customPendingAtTime => {
  showCustomPendingAtModal.value = false;
  if (customPendingAtTime) {
    toggleStatus(
      wootConstants.STATUS_TYPE.OPEN,
      getUnixTime(customPendingAtTime)
    );
  }
};

const hideCustomPendingAtModal = () => {
  store.dispatch('setContextMenuChatId', null);
  showCustomPendingAtModal.value = false;
};

useEmitter(CMD_PENDING_AT_CONVERSATION, onCmdPendingAtConversation);
</script>

<template>
  <woot-modal
    v-model:show="showCustomPendingAtModal"
    :on-close="hideCustomPendingAtModal"
  >
    <CustomOpenUntilModal
      @close="hideCustomPendingAtModal"
      @choose-time="choosePendingAtTime"
    />
  </woot-modal>
</template>
