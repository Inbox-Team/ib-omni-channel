<script>
import { mapGetters } from 'vuex';

export default {
  components: {},
  props: {
    action: {
      type: Object,
      default: () => {},
    },
    isSelected: {
      type: Boolean,
      default: false,
    },
    compact: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['optionSelect'],
  computed: {
    ...mapGetters({
      widgetColor: 'appConfig/getWidgetColor',
    }),
  },
  methods: {
    onClick() {
      this.$emit('optionSelect', this.action);
    },
  },
};
</script>

<template>
  <li
    class="option"
    :class="{ 'is-selected': isSelected, 'option--compact': compact }"
    :style="{ borderColor: widgetColor }"
  >
    <button class="option-button button" @click="onClick">
      <span :style="{ color: widgetColor }">{{ action.title }}</span>
    </button>
  </li>
</template>

<style scoped lang="scss">
.option {
  @apply rounded-[5rem] border border-solid border-n-brand ltr:float-left rtl:float-right m-1 max-w-full;

  .option-button {
    @apply bg-transparent border-0 cursor-pointer h-auto leading-normal ltr:text-left rtl:text-right whitespace-normal rounded-[2rem] min-h-[2.5rem];

    span {
      display: inline-block;
      vertical-align: middle;
    }
  }

  &.option--compact {
    @apply m-0.5 flex items-center;

    .option-button {
      @apply rounded-[1.25rem] min-h-0 px-2.5 py-1 text-xs flex items-center justify-center ltr:text-center rtl:text-center;

      span {
        display: inline;
        line-height: 1;
      }
    }
  }
}
</style>
