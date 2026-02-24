<script setup>
import { ref, computed } from 'vue';
import { useAlert } from 'dashboard/composables';
import { useToggle } from '@vueuse/core';
import { useI18n } from 'vue-i18n';
import { useStore, useStoreGetters } from 'dashboard/composables/store';
import { useEmitter } from 'dashboard/composables/emitter';
import { useKeyboardEvents } from 'dashboard/composables/useKeyboardEvents';

import WootDropdownItem from 'shared/components/ui/dropdown/DropdownItem.vue';
import WootDropdownMenu from 'shared/components/ui/dropdown/DropdownMenu.vue';
import wootConstants from 'dashboard/constants/globals';
import {
  CMD_REOPEN_CONVERSATION,
  CMD_RESOLVE_CONVERSATION,
} from 'dashboard/helper/commandbar/events';

import ButtonGroup from 'dashboard/components-next/buttonGroup/ButtonGroup.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const store = useStore();
const getters = useStoreGetters();
const { t } = useI18n();

const arrowDownButtonRef = ref(null);
const isLoading = ref(false);

const [showActionsDropdown, toggleDropdown] = useToggle();
const closeDropdown = () => toggleDropdown(false);
const openDropdown = () => toggleDropdown(true);

const currentChat = computed(() => getters.getSelectedChat.value);

const isOpen = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.OPEN
);
const isPending = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.PENDING
);
const isResolved = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.RESOLVED
);
const isSnoozed = computed(
  () => currentChat.value.status === wootConstants.STATUS_TYPE.SNOOZED
);

const showAdditionalActions = computed(() => isOpen.value);

const showOpenButton = computed(() => {
  return isPending.value || isSnoozed.value;
});

const currentStatusLabel = computed(() => {
  const status = currentChat.value?.status;
  if (!status) return '';
  const key = `CONVERSATION.HEADER.STATUS_${status.toUpperCase()}`;
  return t(key);
});

const getConversationParams = () => {
  const allConversations = document.querySelectorAll(
    '.conversations-list .conversation'
  );

  const activeConversation = document.querySelector(
    'div.conversations-list div.conversation.active'
  );
  const activeConversationIndex = [...allConversations].indexOf(
    activeConversation
  );
  const lastConversationIndex = allConversations.length - 1;

  return {
    all: allConversations,
    activeIndex: activeConversationIndex,
    lastIndex: lastConversationIndex,
  };
};

// const openSnoozeModal = () => {
//   const ninja = document.querySelector('ninja-keys');
//   ninja.open({ parent: 'snooze_conversation' });
// };

const openPendingAtModal = () => {
  closeDropdown();
  const ninja = document.querySelector('ninja-keys');
  ninja.open({ parent: 'pending_at_conversation' });
};

const toggleStatus = (status, snoozedUntil) => {
  closeDropdown();
  isLoading.value = true;
  store
    .dispatch('toggleStatus', {
      conversationId: currentChat.value.id,
      status,
      snoozedUntil,
    })
    .then(() => {
      useAlert(t('CONVERSATION.CHANGE_STATUS'));
      isLoading.value = false;
    });
};

const onCmdOpenConversation = () => {
  toggleStatus(wootConstants.STATUS_TYPE.OPEN);
};

const onCmdResolveConversation = () => {
  toggleStatus(wootConstants.STATUS_TYPE.RESOLVED);
};

const keyboardEvents = {
  'Alt+KeyM': {
    action: () => arrowDownButtonRef.value?.$el.click(),
    allowOnFocusedInput: true,
  },
  'Alt+KeyE': {
    action: async () => {
      await toggleStatus(wootConstants.STATUS_TYPE.RESOLVED);
    },
  },
  '$mod+Alt+KeyE': {
    action: async event => {
      const { all, activeIndex, lastIndex } = getConversationParams();
      await toggleStatus(wootConstants.STATUS_TYPE.RESOLVED);

      if (activeIndex < lastIndex) {
        all[activeIndex + 1].click();
      } else if (all.length > 1) {
        all[0].click();
        document.querySelector('.conversations-list').scrollTop = 0;
      }
      event.preventDefault();
    },
  },
};

useKeyboardEvents(keyboardEvents);

useEmitter(CMD_REOPEN_CONVERSATION, onCmdOpenConversation);
useEmitter(CMD_RESOLVE_CONVERSATION, onCmdResolveConversation);
</script>

<template>
  <div class="relative flex items-center justify-end gap-2 resolve-actions">
    <span class="text-xs text-n-slate-11 whitespace-nowrap">
      {{ t('CONVERSATION.HEADER.STATUS_LABEL') }}: {{ currentStatusLabel }}
    </span>
    <ButtonGroup
      class="rounded-lg shadow outline-1 outline flex-shrink-0"
      :class="!showOpenButton ? 'outline-n-container' : 'outline-transparent'"
    >
      <Button
        v-if="isOpen"
        :label="t('CONVERSATION.HEADER.RESOLVE_ACTION')"
        size="sm"
        color="slate"
        no-animation
        class="ltr:rounded-r-none rtl:rounded-l-none !outline-0"
        :is-loading="isLoading"
        @click="onCmdResolveConversation"
      />
      <Button
        v-else-if="isResolved"
        :label="t('CONVERSATION.HEADER.REOPEN_ACTION')"
        size="sm"
        color="slate"
        no-animation
        :class="
          showAdditionalActions
            ? 'ltr:rounded-r-none rtl:rounded-l-none !outline-0'
            : 'rounded-lg !outline-0'
        "
        :is-loading="isLoading"
        @click="onCmdOpenConversation"
      />
      <Button
        v-else-if="showOpenButton"
        :label="t('CONVERSATION.HEADER.OPEN_ACTION')"
        size="sm"
        color="slate"
        no-animation
        :is-loading="isLoading"
        @click="onCmdOpenConversation"
      />
      <Button
        v-if="showAdditionalActions"
        ref="arrowDownButtonRef"
        icon="i-lucide-chevron-down"
        :disabled="isLoading"
        size="sm"
        no-animation
        class="ltr:rounded-l-none rtl:rounded-r-none !outline-0"
        color="slate"
        trailing-icon
        @click="openDropdown"
      />
    </ButtonGroup>
    <div
      v-if="showActionsDropdown"
      v-on-clickaway="closeDropdown"
      class="border rounded-lg shadow-lg border-n-strong dark:border-n-strong box-content p-2 w-fit z-10 bg-n-alpha-3 backdrop-blur-[100px] absolute block left-auto top-full mt-0.5 start-0 xl:start-auto xl:end-0 max-w-[12.5rem] min-w-[9.75rem] [&_ul>li]:mb-0"
    >
      <WootDropdownMenu class="mb-0">
        <WootDropdownItem v-if="isOpen">
          <Button
            :label="t('CONVERSATION.RESOLVE_DROPDOWN.PENDING_AT')"
            ghost
            slate
            sm
            start
            icon="i-lucide-clock"
            class="w-full"
            @click="() => openPendingAtModal()"
          />
        </WootDropdownItem>
        <WootDropdownItem v-if="isOpen">
          <Button
            :label="t('CONVERSATION.RESOLVE_DROPDOWN.PENDING_NOW')"
            ghost
            slate
            sm
            start
            icon="i-lucide-circle-dot-dashed"
            class="w-full"
            @click="() => toggleStatus(wootConstants.STATUS_TYPE.PENDING)"
          />
        </WootDropdownItem>
      </WootDropdownMenu>
    </div>
  </div>
</template>
