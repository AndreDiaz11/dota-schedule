import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';

const PANDASCORE_API_KEY = process.env.PANDASCORE_API_KEY;
const FIREBASE_SERVICE_ACCOUNT = process.env.FIREBASE_SERVICE_ACCOUNT;

if (!PANDASCORE_API_KEY) {
  console.error('Falta la variable de entorno PANDASCORE_API_KEY');
  process.exit(1);
}
if (!FIREBASE_SERVICE_ACCOUNT) {
  console.error('Falta la variable de entorno FIREBASE_SERVICE_ACCOUNT');
  process.exit(1);
}

const serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT);
initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

const TIER_MAP = { s: 'tier1', a: 'tier1', b: 'tier2', c: 'tier3', d: 'qualifier' };

const REGION_BY_COUNTRY = {
  US: 'na', CA: 'na', MX: 'na',
  BR: 'sa', PE: 'sa', AR: 'sa', CL: 'sa', CO: 'sa', EC: 'sa', UY: 'sa', PY: 'sa', BO: 'sa', VE: 'sa',
  RU: 'eu', UA: 'eu', GR: 'eu', RS: 'eu', DE: 'eu', FR: 'eu', ES: 'eu', PT: 'eu', IT: 'eu', PL: 'eu',
  GB: 'eu', UK: 'eu', SE: 'eu', NO: 'eu', FI: 'eu', DK: 'eu', NL: 'eu', BE: 'eu', CZ: 'eu', SK: 'eu',
  RO: 'eu', BG: 'eu', KZ: 'eu',
  CN: 'cn',
  PH: 'sea', ID: 'sea', MY: 'sea', TH: 'sea', VN: 'sea', SG: 'sea', MM: 'sea',
};

function mapTier(tier) {
  return TIER_MAP[tier] ?? 'amateur';
}

function mapBestOf(games) {
  return { 1: 'bo1', 2: 'bo2', 3: 'bo3', 5: 'bo5' }[games] ?? 'bo1';
}

function mapRegion(countryCode) {
  if (!countryCode) return 'other';
  return REGION_BY_COUNTRY[countryCode.toUpperCase()] ?? 'other';
}

function parseTeam(json) {
  return {
    id: String(json.id),
    name: json.name ?? json.acronym ?? 'TBD',
    logoUrl: json.image_url ?? '',
    region: mapRegion(json.location),
  };
}

function parseMatch(raw) {
  const opponents = raw.opponents ?? [];
  if (opponents.length < 2) return null;

  const teamAJson = opponents[0]?.opponent;
  const teamBJson = opponents[1]?.opponent;
  if (!teamAJson || !teamBJson) return null;

  const scheduledAt = raw.scheduled_at ?? raw.begin_at;
  if (!scheduledAt) return null;

  const league = raw.league;
  const tournament = raw.tournament;

  return {
    id: String(raw.id),
    tournamentId: String(league?.id ?? tournament?.id ?? raw.id),
    tournamentName: league?.name ?? tournament?.name ?? 'Torneo',
    tier: mapTier(tournament?.tier),
    teamA: parseTeam(teamAJson),
    teamB: parseTeam(teamBJson),
    startTimeUtc: Timestamp.fromDate(new Date(scheduledAt)),
    bestOf: mapBestOf(raw.number_of_games),
    updatedAt: Timestamp.now(),
  };
}

async function fetchUpcomingMatches() {
  const response = await fetch(
    'https://api.pandascore.co/dota2/matches/upcoming?per_page=100&sort=begin_at',
    { headers: { Authorization: `Bearer ${PANDASCORE_API_KEY}` } },
  );
  if (!response.ok) {
    throw new Error(`PandaScore respondió ${response.status}: ${await response.text()}`);
  }
  const data = await response.json();
  return data.map(parseMatch).filter(Boolean);
}

async function replaceMatchesCollection(matches) {
  const collection = db.collection('matches');
  const existing = await collection.listDocuments();

  const BATCH_LIMIT = 400;
  for (let i = 0; i < existing.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    existing.slice(i, i + BATCH_LIMIT).forEach((doc) => batch.delete(doc));
    await batch.commit();
  }

  for (let i = 0; i < matches.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    matches.slice(i, i + BATCH_LIMIT).forEach((match) => {
      batch.set(collection.doc(match.id), match);
    });
    await batch.commit();
  }
}

const matches = await fetchUpcomingMatches();

if (matches.length === 0) {
  console.warn('PandaScore devolvió 0 partidos — no se toca Firestore, probablemente un hipo transitorio de la API.');
  process.exit(0);
}

await replaceMatchesCollection(matches);
console.log(`Sincronizados ${matches.length} partidos.`);
