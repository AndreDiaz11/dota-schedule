export const TIER_MAP = { s: 'tier1', a: 'tier1', b: 'tier2', c: 'tier3', d: 'qualifier' };

export function mapTier(tier) {
  return TIER_MAP[tier] ?? 'amateur';
}
