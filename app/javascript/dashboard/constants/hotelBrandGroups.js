/**
 * Ordered brand groups for the Hotel Brand sidebar. First matching rule wins.
 *
 * Kin Hotel Edition – kin and edition
 * Kin Wander – kin and wander
 * Kin Hotel – kin and hotel (after the two above)
 * Nik – starts with nik or word nik
 * Other – everything else
 */
function normalize(name) {
  return String(name ?? '')
    .toLowerCase()
    .trim();
}

export const HOTEL_BRAND_GROUP_DEFS = [
  {
    id: 'kin_hotel_edition',
    labelKey: 'SIDEBAR.HOTEL_BRAND_GROUP_KIN_HOTEL_EDITION',
    match: name => {
      const n = normalize(name);
      return n.includes('kin') && n.includes('hotel') && n.includes('edition');
    },
  },
  {
    id: 'kin_wander',
    labelKey: 'SIDEBAR.HOTEL_BRAND_GROUP_KIN_WANDER',
    match: name => {
      const n = normalize(name);
      return n.includes('kin') && n.includes('wander');
    },
  },
  {
    id: 'kin_hotel',
    labelKey: 'SIDEBAR.HOTEL_BRAND_GROUP_KIN_HOTEL',
    match: name => {
      const n = normalize(name);
      return n.includes('kin') && n.includes('hotel');
    },
  },
  {
    id: 'nik',
    labelKey: 'SIDEBAR.HOTEL_BRAND_GROUP_NIK',
    match: name => {
      const n = normalize(name);
      return n.startsWith('nik') || /\bnik\b/.test(n);
    },
  },
  {
    id: 'other',
    labelKey: 'SIDEBAR.HOTEL_BRAND_GROUP_OTHER',
    match: () => true,
  },
];

/**
 * @param {{ id: string, name: string }[]} options
 * @returns {Array<{ id: string, labelKey: string, items: typeof options }>}
 */
export function groupBrandOptionsByName(options) {
  const buckets = HOTEL_BRAND_GROUP_DEFS.map(def => ({
    id: def.id,
    labelKey: def.labelKey,
    items: [],
  }));
  const idToBucket = Object.fromEntries(buckets.map(b => [b.id, b]));

  options.forEach(opt => {
    const name = String(opt.name ?? opt.id);
    const def = HOTEL_BRAND_GROUP_DEFS.find(d => d.match(name));
    if (def) {
      idToBucket[def.id].items.push(opt);
    }
  });

  return buckets.filter(b => b.items.length > 0);
}
