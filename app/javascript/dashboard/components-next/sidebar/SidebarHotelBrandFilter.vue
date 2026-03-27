<script setup>
import { computed } from 'vue';
import { useStorage } from '@vueuse/core';
import { useI18n } from 'vue-i18n';
import { useHotelBrandSidebarFilter } from 'dashboard/composables/conversation/useHotelBrandSidebarFilter';
import SidebarGroupHeader from './SidebarGroupHeader.vue';
import SidebarGroupSeparator from './SidebarGroupSeparator.vue';

const LEAF_ROW_CLASS =
  'py-0.5 ltr:pl-3 rtl:pr-3 rtl:mr-3 ltr:ml-3 relative text-n-slate-11 child-item before:bg-n-slate-4 after:bg-transparent after:border-n-slate-4 before:left-0 rtl:before:right-0';

const { t } = useI18n();

const {
  hotelBrandAttribute,
  isHotelBrandFilterAvailable,
  groupedBrandOptions,
  selectedHotelBrandValue,
  hasHotelBrandActiveChild,
  applyHotelBrand,
} = useHotelBrandSidebarFilter();

const isExpanded = useStorage(
  'sidebar-hotel-brand-expanded',
  true,
  sessionStorage
);

const sectionLabel = computed(() => {
  return (
    hotelBrandAttribute.value?.attributeDisplayName || t('SIDEBAR.HOTEL_BRAND')
  );
});

const showSection = computed(() => isHotelBrandFilterAvailable.value);

function toggleExpanded() {
  isExpanded.value = !isExpanded.value;
}

async function onSelectAll() {
  await applyHotelBrand(null);
}

async function onSelectBrand(brandId) {
  await applyHotelBrand(brandId);
}

function isRowActive(brandId) {
  if (brandId === null) {
    return selectedHotelBrandValue.value === null;
  }
  return selectedHotelBrandValue.value === brandId;
}

function groupSectionLabel(groupId) {
  switch (groupId) {
    case 'kin_hotel_edition':
      return t('SIDEBAR.HOTEL_BRAND_GROUP_KIN_HOTEL_EDITION');
    case 'kin_wander':
      return t('SIDEBAR.HOTEL_BRAND_GROUP_KIN_WANDER');
    case 'kin_hotel':
      return t('SIDEBAR.HOTEL_BRAND_GROUP_KIN_HOTEL');
    case 'nik':
      return t('SIDEBAR.HOTEL_BRAND_GROUP_NIK');
    case 'other':
      return t('SIDEBAR.HOTEL_BRAND_GROUP_OTHER');
    default:
      return '';
  }
}
</script>

<template>
  <li
    v-show="showSection"
    class="grid gap-1 text-sm cursor-pointer select-none"
  >
    <SidebarGroupHeader
      :label="sectionLabel"
      icon="i-lucide-building-2"
      expandable
      :is-expanded="isExpanded"
      :is-active="false"
      :has-active-child="hasHotelBrandActiveChild"
      @toggle="toggleExpanded"
    />
    <ul
      v-show="isExpanded || hasHotelBrandActiveChild"
      class="grid m-0 list-none sidebar-group-children"
    >
      <li v-show="isExpanded || isRowActive(null)" :class="LEAF_ROW_CLASS">
        <button
          type="button"
          class="flex h-8 items-center gap-2 px-2 py-1 rounded-lg max-w-[9.438rem] w-full hover:bg-gradient-to-r from-transparent via-n-slate-3/70 to-n-slate-3/70 group"
          :class="{
            'text-n-blue-text bg-n-alpha-2': isRowActive(null),
          }"
          @click="onSelectAll"
        >
          <div class="flex-1 min-w-0 truncate text-left">
            {{ t('SIDEBAR.HOTEL_BRAND_ALL') }}
          </div>
        </button>
      </li>
      <template v-for="group in groupedBrandOptions" :key="group.id">
        <li class="grid gap-0.5 p-0 m-0 list-none">
          <SidebarGroupSeparator
            :label="groupSectionLabel(group.id)"
            class="my-1 ltr:pl-3 rtl:pr-3"
          />
          <ul class="grid gap-0.5 p-0 m-0 list-none">
            <li
              v-for="opt in group.items"
              v-show="isExpanded || isRowActive(opt.id)"
              :key="opt.id"
              :class="LEAF_ROW_CLASS"
            >
              <button
                type="button"
                class="flex h-8 items-center gap-2 px-2 py-1 rounded-lg max-w-[9.438rem] w-full hover:bg-gradient-to-r from-transparent via-n-slate-3/70 to-n-slate-3/70 group"
                :class="{
                  'text-n-blue-text bg-n-alpha-2': isRowActive(opt.id),
                }"
                @click="onSelectBrand(opt.id)"
              >
                <div class="flex-1 min-w-0 truncate text-left">
                  {{ opt.name }}
                </div>
              </button>
            </li>
          </ul>
        </li>
      </template>
    </ul>
  </li>
</template>
