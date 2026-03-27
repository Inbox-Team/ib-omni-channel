import { computed } from 'vue';
import { useStore } from 'vuex';
import { useMapGetter } from 'dashboard/composables/store';
import { useSnakeCase } from 'dashboard/composables/useTransformKeys';
import filterQueryGenerator from 'dashboard/helper/filterQueryGenerator';
import { emitter } from 'shared/helpers/mitt';
import { BUS_EVENTS } from 'shared/constants/busEvents';

export const HOTEL_BRAND_ATTRIBUTE_KEY = 'hotel_brand';

/**
 * Sidebar quick filter for the `hotel_brand` conversation custom attribute.
 * Mirrors advanced filter behavior: merge with existing `appliedFilters`, then fetch.
 */
export function useHotelBrandSidebarFilter() {
  const store = useStore();
  const conversationAttributes = useMapGetter(
    'attributes/getConversationAttributes'
  );
  const appliedFilters = useMapGetter('getAppliedConversationFiltersV2');

  const hotelBrandAttribute = computed(() =>
    conversationAttributes.value.find(
      a => a.attributeKey === HOTEL_BRAND_ATTRIBUTE_KEY
    )
  );

  const isHotelBrandFilterAvailable = computed(() => {
    const attr = hotelBrandAttribute.value;
    return (
      attr &&
      Array.isArray(attr.attributeValues) &&
      attr.attributeValues.length > 0
    );
  });

  const brandOptions = computed(() => {
    const values = hotelBrandAttribute.value?.attributeValues ?? [];
    return values.map(v => ({ id: v, name: v }));
  });

  const selectedHotelBrandValue = computed(() => {
    const row = appliedFilters.value.find(
      f => f.attributeKey === HOTEL_BRAND_ATTRIBUTE_KEY
    );
    if (!row?.values?.length) return null;
    const v = row.values[0];
    if (typeof v === 'object' && v !== null && 'id' in v) return v.id;
    return v;
  });

  /** Matches SidebarGroup "hasActiveChild": keep nested rows visible when collapsed if a brand or "All" is active */
  const hasHotelBrandActiveChild = computed(() => {
    const hasHotelFilter = appliedFilters.value.some(
      f => f.attributeKey === HOTEL_BRAND_ATTRIBUTE_KEY
    );
    return selectedHotelBrandValue.value !== null || !hasHotelFilter;
  });

  function buildHotelBrandCondition(brandValue) {
    return {
      attributeKey: HOTEL_BRAND_ATTRIBUTE_KEY,
      filterOperator: 'equal_to',
      values: [{ id: brandValue, name: brandValue }],
      queryOperator: 'and',
      attributeModel: 'customAttributes',
    };
  }

  function mergeHotelBrandIntoFilters(brandValue) {
    const rest = appliedFilters.value.filter(
      f => f.attributeKey !== HOTEL_BRAND_ATTRIBUTE_KEY
    );
    if (brandValue === null) {
      return rest;
    }
    return [...rest, buildHotelBrandCondition(brandValue)];
  }

  async function applyHotelBrand(brandValue) {
    const merged = mergeHotelBrandIntoFilters(brandValue);
    const snakePayload = useSnakeCase(JSON.parse(JSON.stringify(merged)));
    store.dispatch('setConversationFilters', snakePayload);
    store.dispatch('bulkActions/clearSelectedConversationIds');
    store.dispatch('conversationPage/reset');
    store.dispatch('emptyAllConversations');
    emitter.emit(BUS_EVENTS.CONVERSATION_FILTERS_APPLIED, merged);

    if (!merged.length) {
      await store.dispatch('fetchAllConversations');
      return;
    }

    const fetchPayload = useSnakeCase(JSON.parse(JSON.stringify(merged)));
    const page =
      store.getters['conversationPage/getCurrentPageFilter']('appliedFilters') +
      1;
    await store.dispatch('fetchFilteredConversations', {
      queryData: filterQueryGenerator(fetchPayload),
      page,
    });
  }

  return {
    hotelBrandAttribute,
    isHotelBrandFilterAvailable,
    brandOptions,
    selectedHotelBrandValue,
    hasHotelBrandActiveChild,
    applyHotelBrand,
  };
}
