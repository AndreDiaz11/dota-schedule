export const REGION_BY_COUNTRY = {
  US: 'na', CA: 'na', MX: 'na', PR: 'na',

  BR: 'sa', AR: 'sa', CL: 'sa', PE: 'sa', CO: 'sa', EC: 'sa', UY: 'sa', PY: 'sa', BO: 'sa', VE: 'sa', GY: 'sa', SR: 'sa',

  GB: 'eu', UK: 'eu', IE: 'eu', FR: 'eu', DE: 'eu', ES: 'eu', PT: 'eu', IT: 'eu', NL: 'eu', BE: 'eu',
  LU: 'eu', CH: 'eu', AT: 'eu', SE: 'eu', NO: 'eu', DK: 'eu', IS: 'eu', GR: 'eu', MT: 'eu', CY: 'eu',
  PL: 'eu', CZ: 'eu', SK: 'eu', HU: 'eu', RO: 'eu', BG: 'eu', HR: 'eu', SI: 'eu', RS: 'eu', BA: 'eu',
  ME: 'eu', MK: 'eu', AL: 'eu', XK: 'eu', LT: 'eu', LV: 'eu', EE: 'eu', MD: 'eu',
  RU: 'eu', UA: 'eu', BY: 'eu', KZ: 'eu', AM: 'eu', GE: 'eu', AZ: 'eu', UZ: 'eu', KG: 'eu', TJ: 'eu', TM: 'eu',
  TR: 'eu',

  CN: 'cn', HK: 'cn', MO: 'cn', TW: 'cn',

  PH: 'sea', ID: 'sea', MY: 'sea', TH: 'sea', VN: 'sea', SG: 'sea', MM: 'sea', KH: 'sea', LA: 'sea', BN: 'sea', IN: 'sea',
};

export function mapRegion(countryCode) {
  if (!countryCode) return 'other';
  return REGION_BY_COUNTRY[countryCode.toUpperCase()] ?? 'other';
}
