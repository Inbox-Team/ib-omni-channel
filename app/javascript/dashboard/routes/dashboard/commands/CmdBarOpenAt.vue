<script setup>
import { ref, computed } from 'vue';
import { useStore, useStoreGetters } from 'dashboard/composables/store';
import { useAlert } from 'dashboard/composables';
import { useI18n } from 'vue-i18n';
import { useEmitter } from 'dashboard/composables/emitter';
import { getUnixTime } from 'date-fns';
import { findSnoozeTime } from 'dashboard/helper/snoozeHelpers';
import { CMD_OPEN_AT_CONVERSATION } from 'dashboard/helper/commandbar/events';
import wootConstants from 'dashboard/constants/globals';
import CustomOpenUntilModal from 'dashboard/components/CustomOpenUntilModal.vue';

const store = useStore();
const getters = useStoreGetters();
const { t } = useI18n();
const showCustomOpenAtModal = ref(false);

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

const onCmdOpenAtConversation = openAtType => {
  if (openAtType === wootConstants.SNOOZE_OPTIONS.UNTIL_CUSTOM_TIME) {
    showCustomOpenAtModal.value = true;
  } else {
    toggleStatus(
      wootConstants.STATUS_TYPE.PENDING,
      findSnoozeTime(openAtType) || null
    );
  }
};

const chooseOpenAtTime = customOpenAtTime => {
  showCustomOpenAtModal.value = false;
  if (customOpenAtTime) {
    toggleStatus(
      wootConstants.STATUS_TYPE.PENDING,
      getUnixTime(customOpenAtTime)
    );
  }
};

const hideCustomOpenAtModal = () => {
  store.dispatch('setContextMenuChatId', null);
  showCustomOpenAtModal.value = false;
};

useEmitter(CMD_OPEN_AT_CONVERSATION, onCmdOpenAtConversation);
</script>

<template>
  <woot-modal
    v-model:show="showCustomOpenAtModal"
    :on-close="hideCustomOpenAtModal"
  >
    <CustomOpenUntilModal
      @close="hideCustomOpenAtModal"
      @choose-time="chooseOpenAtTime"
    />
  </woot-modal>
</template>
