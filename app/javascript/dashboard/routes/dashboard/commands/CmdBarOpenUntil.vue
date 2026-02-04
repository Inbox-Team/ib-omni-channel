<script setup>
import { ref, computed } from 'vue';
import { useStore, useStoreGetters } from 'dashboard/composables/store';
import { useAlert } from 'dashboard/composables';
import { useI18n } from 'vue-i18n';
import { useEmitter } from 'dashboard/composables/emitter';
import { getUnixTime } from 'date-fns';
import { findSnoozeTime } from 'dashboard/helper/snoozeHelpers';
import { CMD_OPEN_UNTIL_CONVERSATION } from 'dashboard/helper/commandbar/events';
import wootConstants from 'dashboard/constants/globals';
import CustomOpenUntilModal from 'dashboard/components/CustomOpenUntilModal.vue';

const store = useStore();
const getters = useStoreGetters();
const { t } = useI18n();
const showCustomOpenUntilModal = ref(false);

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

const onCmdOpenUntilConversation = openUntilType => {
  if (openUntilType === wootConstants.SNOOZE_OPTIONS.UNTIL_CUSTOM_TIME) {
    showCustomOpenUntilModal.value = true;
  } else {
    toggleStatus(
      wootConstants.STATUS_TYPE.OPEN,
      findSnoozeTime(openUntilType) || null
    );
  }
};

const chooseOpenUntilTime = customOpenUntilTime => {
  showCustomOpenUntilModal.value = false;
  if (customOpenUntilTime) {
    toggleStatus(
      wootConstants.STATUS_TYPE.OPEN,
      getUnixTime(customOpenUntilTime)
    );
  }
};

const hideCustomOpenUntilModal = () => {
  store.dispatch('setContextMenuChatId', null);
  showCustomOpenUntilModal.value = false;
};

useEmitter(CMD_OPEN_UNTIL_CONVERSATION, onCmdOpenUntilConversation);
</script>

<template>
  <woot-modal
    v-model:show="showCustomOpenUntilModal"
    :on-close="hideCustomOpenUntilModal"
  >
    <CustomOpenUntilModal
      @close="hideCustomOpenUntilModal"
      @choose-time="chooseOpenUntilTime"
    />
  </woot-modal>
</template>
