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
  },
  emits: ['select'],
  computed: {
    options() {
      return this.items.map((item, index) => ({
        ...item,
        id: item.value || index,
      }));
    },
  },
  methods: {
    onSelect(option) {
      this.$emit('select', option);
    },
  },
};
</script>

<template>
  <ul class="w-full mt-0.5">
    <ChatOption
      v-for="option in options"
      :key="option.id"
      :action="option"
      compact
      class="list-none p-0"
      @option-select="onSelect"
    />
  </ul>
</template>
