<script>
import ChatOption from 'shared/components/ChatOption.vue';

export default {
  name: 'SuggestionChips',
  components: {
    ChatOption,
  },
  props: {
    items: {
      type: Array,
      default: () => [],
    },
    disabled: {
      type: Boolean,
      default: false,
    },
    size: {
      type: String,
      default: 'compact',
      validator: value => ['compact', 'comfortable'].includes(value),
    },
  },
  emits: ['select'],
  computed: {
    options() {
      return this.items.map((item, index) => ({
        ...item,
        id: item.value || index,
      }));
    },
    wrapperClass() {
      return this.size === 'comfortable' ? 'mt-2 mb-1' : 'mt-0.5';
    },
  },
  methods: {
    onSelect(option) {
      if (this.disabled) {
        return;
      }

      this.$emit('select', option);
    },
  },
};
</script>

<template>
  <ul
    class="w-full"
    :class="[wrapperClass, { 'pointer-events-none opacity-50': disabled }]"
  >
    <ChatOption
      v-for="option in options"
      :key="option.id"
      :action="option"
      :size="size"
      class="list-none p-0"
      @option-select="onSelect"
    />
  </ul>
</template>
