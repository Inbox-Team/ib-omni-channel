<script>
import DatePicker from 'vue-datepicker-next';
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    DatePicker,
    NextButton,
  },
  emits: ['close', 'chooseTime'],

  data() {
    return {
      openUntilTime: null,
      lang: {
        days: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        yearFormat: 'YYYY',
        monthFormat: 'MMMM',
      },
    };
  },

  methods: {
    onClose() {
      this.$emit('close');
    },
    chooseTime() {
      this.$emit('chooseTime', this.openUntilTime);
    },
    disabledDate(date) {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      return date < yesterday;
    },
    disabledTime(date) {
      const now = new Date();
      now.setMinutes(now.getMinutes() + 1);
      return date < now;
    },
  },
};
</script>

<template>
  <div class="flex flex-col">
    <woot-modal-header
      :header-title="$t('CONVERSATION.CUSTOM_OPEN_UNTIL.TITLE')"
    />
    <form
      class="modal-content w-full pt-2 px-5 pb-6"
      @submit.prevent="chooseTime"
    >
      <DatePicker
        v-model:value="openUntilTime"
        type="datetime"
        inline
        input-class="mx-input "
        :lang="lang"
        :disabled-date="disabledDate"
        :disabled-time="disabledTime"
      />
      <div class="flex flex-row justify-end w-full gap-2 px-0 py-2">
        <NextButton
          faded
          slate
          type="reset"
          :label="$t('CONVERSATION.CUSTOM_OPEN_UNTIL.CANCEL')"
          @click.prevent="onClose"
        />
        <NextButton
          type="submit"
          :label="$t('CONVERSATION.CUSTOM_OPEN_UNTIL.APPLY')"
        />
      </div>
    </form>
  </div>
</template>
