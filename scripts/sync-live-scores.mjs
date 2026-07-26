import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

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

async function fetchRunning() {
  const response = await fetch('https://api.pandascore.co/dota2/matches/running?per_page=100', {
    headers: { Authorization: `Bearer ${PANDASCORE_API_KEY}` },
  });
  if (!response.ok) {
    throw new Error(`PandaScore respondió ${response.status} en running: ${await response.text()}`);
  }
  return response.json();
}

const running = await fetchRunning();

if (running.length === 0) {
  console.log('No hay partidos en vivo ahora mismo.');
  process.exit(0);
}

const collection = db.collection('matches');
const batch = db.batch();
let updated = 0;

for (const raw of running) {
  const opponents = raw.opponents ?? [];
  if (opponents.length < 2) continue;
  const teamAId = opponents[0]?.opponent?.id != null ? String(opponents[0].opponent.id) : null;
  const teamBId = opponents[1]?.opponent?.id != null ? String(opponents[1].opponent.id) : null;
  if (!teamAId || !teamBId) continue;

  const results = raw.results ?? [];
  const scoreFor = (id) => results.find((r) => String(r.team_id) === id)?.score ?? 0;

  batch.set(
    collection.doc(String(raw.id)),
    { liveScore: { teamAScore: scoreFor(teamAId), teamBScore: scoreFor(teamBId) } },
    { merge: true },
  );
  updated++;
}

if (updated > 0) {
  await batch.commit();
}
console.log(`Marcador en vivo actualizado en ${updated} partidos.`);
