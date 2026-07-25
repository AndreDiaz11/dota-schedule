import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

const FIREBASE_SERVICE_ACCOUNT = process.env.FIREBASE_SERVICE_ACCOUNT;

if (!FIREBASE_SERVICE_ACCOUNT) {
  console.error('Falta la variable de entorno FIREBASE_SERVICE_ACCOUNT');
  process.exit(1);
}

initializeApp({ credential: cert(JSON.parse(FIREBASE_SERVICE_ACCOUNT)) });
const db = getFirestore();
const messaging = getMessaging();

function matchLabel(match) {
  return `${match.teamA?.name ?? 'TBD'} vs ${match.teamB?.name ?? 'TBD'}`;
}

const STALE_TOKEN_ERRORS = new Set([
  'messaging/invalid-registration-token',
  'messaging/registration-token-not-registered',
]);

async function main() {
  const now = Date.now();

  const [matchesSnap, groupsSnap] = await Promise.all([
    db.collection('matches').get(),
    db.collection('groups').get(),
  ]);

  const matches = matchesSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  let sentCount = 0;

  for (const groupDoc of groupsSnap.docs) {
    const group = groupDoc.data();
    const favoriteIds = new Set(group.favoriteTeamIds ?? []);
    const notifiedIds = new Set(group.notifiedMatchIds ?? []);
    const leadMinutes = group.notificationLeadMinutes ?? 30;
    const tokens = group.fcmTokens ?? [];

    if (favoriteIds.size === 0 || tokens.length === 0) continue;

    const dueMatches = matches.filter((match) => {
      if (notifiedIds.has(match.id)) return false;
      const isFavorite = favoriteIds.has(match.teamA?.id) || favoriteIds.has(match.teamB?.id);
      if (!isFavorite) return false;
      const startMs = match.startTimeUtc?.toMillis?.();
      if (!startMs) return false;
      const minutesUntil = (startMs - now) / 60000;
      return minutesUntil >= 0 && minutesUntil <= leadMinutes;
    });

    for (const match of dueMatches) {
      const minutesUntil = Math.round((match.startTimeUtc.toMillis() - now) / 60000);

      const response = await messaging.sendEachForMulticast({
        tokens,
        notification: {
          title: '¡Ya casi empieza!',
          body: `${matchLabel(match)} arranca en ${minutesUntil} min · ${match.tournamentName ?? 'Torneo'}`,
        },
      });

      const staleTokens = [];
      response.responses.forEach((r, i) => {
        if (!r.success && STALE_TOKEN_ERRORS.has(r.error?.code)) {
          staleTokens.push(tokens[i]);
        }
      });

      const update = { notifiedMatchIds: FieldValue.arrayUnion(match.id) };
      if (staleTokens.length > 0) {
        update.fcmTokens = FieldValue.arrayRemove(...staleTokens);
      }
      await groupDoc.ref.update(update);

      sentCount += response.successCount;
    }
  }

  console.log(`Notificaciones enviadas: ${sentCount}`);
}

await main();
