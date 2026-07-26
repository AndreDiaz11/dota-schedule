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

function mapTier(tier) {
  return TIER_MAP[tier] ?? 'amateur';
}

function pickBestStage(stages) {
  return stages.find((s) => s.has_bracket) ?? stages[0] ?? null;
}

function parseSeries(raw, status) {
  const stages = raw.tournaments ?? [];
  if (stages.length === 0) return null;

  const bestStage = pickBestStage(stages);
  const prizepool = stages.map((s) => s.prizepool).find((p) => p != null) ?? null;
  const country = stages.map((s) => s.country).find((c) => c != null) ?? null;
  const winnerId = raw.winner_type === 'Team' && raw.winner_id != null ? String(raw.winner_id) : null;

  return {
    id: String(raw.id),
    leagueId: String(raw.league_id ?? raw.league?.id ?? ''),
    leagueName: raw.league?.name ?? 'Torneo',
    leagueImageUrl: raw.league?.image_url ?? '',
    seasonName: raw.full_name || raw.name || '',
    tier: mapTier(bestStage?.tier),
    type: bestStage?.type ?? 'online',
    prizepool,
    country,
    beginAtUtc: raw.begin_at ? Timestamp.fromDate(new Date(raw.begin_at)) : null,
    endAtUtc: raw.end_at ? Timestamp.fromDate(new Date(raw.end_at)) : null,
    status,
    winnerId,
    winnerName: null,
    winnerLogoUrl: null,
    updatedAt: Timestamp.now(),
  };
}

async function fetchSeries(endpoint, status) {
  const response = await fetch(
    `https://api.pandascore.co/dota2/series/${endpoint}?per_page=50&sort=-begin_at`,
    { headers: { Authorization: `Bearer ${PANDASCORE_API_KEY}` } },
  );
  if (!response.ok) {
    throw new Error(`PandaScore respondió ${response.status} en series/${endpoint}: ${await response.text()}`);
  }
  const data = await response.json();
  return data.map((raw) => parseSeries(raw, status)).filter(Boolean);
}

async function resolveWinners(tournaments) {
  const withWinner = tournaments.filter((t) => t.status === 'past' && t.winnerId);
  await Promise.all(
    withWinner.map(async (t) => {
      try {
        const response = await fetch(`https://api.pandascore.co/teams/${t.winnerId}`, {
          headers: { Authorization: `Bearer ${PANDASCORE_API_KEY}` },
        });
        if (!response.ok) return;
        const team = await response.json();
        t.winnerName = team.name ?? team.acronym ?? null;
        t.winnerLogoUrl = team.image_url ?? null;
      } catch {
        // sin ganador resuelto, no es crítico
      }
    }),
  );
}

async function replaceTournamentsCollection(tournaments) {
  const collection = db.collection('tournaments');
  const existing = await collection.listDocuments();

  const BATCH_LIMIT = 400;
  for (let i = 0; i < existing.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    existing.slice(i, i + BATCH_LIMIT).forEach((doc) => batch.delete(doc));
    await batch.commit();
  }

  for (let i = 0; i < tournaments.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    tournaments.slice(i, i + BATCH_LIMIT).forEach((t) => {
      batch.set(collection.doc(t.id), t);
    });
    await batch.commit();
  }
}

const [running, upcoming, past] = await Promise.all([
  fetchSeries('running', 'running'),
  fetchSeries('upcoming', 'upcoming'),
  fetchSeries('past', 'past'),
]);

const tournaments = [...running, ...upcoming, ...past];

if (tournaments.length === 0) {
  console.warn('PandaScore devolvió 0 torneos — no se toca Firestore, probablemente un hipo transitorio de la API.');
  process.exit(0);
}

await resolveWinners(tournaments);
await replaceTournamentsCollection(tournaments);
console.log(`Sincronizados ${tournaments.length} torneos (${running.length} en curso, ${upcoming.length} próximos, ${past.length} finalizados).`);
