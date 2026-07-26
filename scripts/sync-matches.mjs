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

const MAX_H2H_ENTRIES = 5;

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

function parseOpponents(raw) {
  const opponents = raw.opponents ?? [];
  if (opponents.length < 2) return null;
  const teamAJson = opponents[0]?.opponent;
  const teamBJson = opponents[1]?.opponent;
  if (!teamAJson || !teamBJson) return null;
  return { teamAJson, teamBJson };
}

function parseMatch(raw, status) {
  const parsedOpponents = parseOpponents(raw);
  if (!parsedOpponents) return null;

  const scheduledAt = raw.scheduled_at ?? raw.begin_at;
  if (!scheduledAt) return null;

  const league = raw.league;
  const tournament = raw.tournament;

  return {
    id: String(raw.id),
    tournamentId: String(league?.id ?? tournament?.id ?? raw.id),
    tournamentName: league?.name ?? tournament?.name ?? 'Torneo',
    tier: mapTier(tournament?.tier),
    teamA: parseTeam(parsedOpponents.teamAJson),
    teamB: parseTeam(parsedOpponents.teamBJson),
    startTimeUtc: Timestamp.fromDate(new Date(scheduledAt)),
    bestOf: mapBestOf(raw.number_of_games),
    status,
    updatedAt: Timestamp.now(),
  };
}

function parsePastMatch(raw) {
  const parsedOpponents = parseOpponents(raw);
  if (!parsedOpponents) return null;
  const endAt = raw.end_at ?? raw.scheduled_at ?? raw.begin_at;
  if (!endAt || !raw.results || raw.results.length < 2) return null;

  const teamAId = String(parsedOpponents.teamAJson.id);
  const teamBId = String(parsedOpponents.teamBJson.id);
  const scoreFor = (teamId) => raw.results.find((r) => String(r.team_id) === teamId)?.score ?? 0;

  return {
    teamAId,
    teamBId,
    teamAScore: scoreFor(teamAId),
    teamBScore: scoreFor(teamBId),
    winnerId: raw.winner_id != null ? String(raw.winner_id) : null,
    tournamentName: raw.league?.name ?? raw.tournament?.name ?? 'Torneo',
    dateUtc: new Date(endAt),
  };
}

function buildHeadToHead(match, pastMatches) {
  const encounters = pastMatches
    .filter(
      (p) =>
        (p.teamAId === match.teamA.id && p.teamBId === match.teamB.id) ||
        (p.teamAId === match.teamB.id && p.teamBId === match.teamA.id),
    )
    .sort((a, b) => b.dateUtc - a.dateUtc)
    .slice(0, MAX_H2H_ENTRIES)
    .map((p) => {
      const sameOrder = p.teamAId === match.teamA.id;
      return {
        dateUtc: Timestamp.fromDate(p.dateUtc),
        tournamentName: p.tournamentName,
        teamAScore: sameOrder ? p.teamAScore : p.teamBScore,
        teamBScore: sameOrder ? p.teamBScore : p.teamAScore,
        winnerId: p.winnerId,
      };
    });

  return encounters;
}

async function fetchMatches(endpoint, status) {
  const response = await fetch(
    `https://api.pandascore.co/dota2/matches/${endpoint}?per_page=100&sort=begin_at`,
    { headers: { Authorization: `Bearer ${PANDASCORE_API_KEY}` } },
  );
  if (!response.ok) {
    throw new Error(`PandaScore respondió ${response.status} en ${endpoint}: ${await response.text()}`);
  }
  const data = await response.json();
  return data.map((raw) => parseMatch(raw, status)).filter(Boolean);
}

async function fetchPastMatches() {
  const response = await fetch(
    'https://api.pandascore.co/dota2/matches/past?per_page=100&sort=-end_at',
    { headers: { Authorization: `Bearer ${PANDASCORE_API_KEY}` } },
  );
  if (!response.ok) {
    console.warn(`No se pudo traer el historial de partidos pasados (HTTP ${response.status}) — se sigue sin historial cara a cara.`);
    return [];
  }
  const data = await response.json();
  return data.map(parsePastMatch).filter(Boolean);
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

const [upcoming, running, pastMatches] = await Promise.all([
  fetchMatches('upcoming', 'upcoming'),
  fetchMatches('running', 'running'),
  fetchPastMatches(),
]);

const matches = [...running, ...upcoming];

if (matches.length === 0) {
  console.warn('PandaScore devolvió 0 partidos — no se toca Firestore, probablemente un hipo transitorio de la API.');
  process.exit(0);
}

for (const match of matches) {
  match.headToHead = buildHeadToHead(match, pastMatches);
}

await replaceMatchesCollection(matches);
console.log(`Sincronizados ${matches.length} partidos (${running.length} en vivo), con historial cara a cara desde ${pastMatches.length} partidos pasados.`);
