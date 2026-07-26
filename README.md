# Pulse

App para Android y Windows que muestra el calendario de próximos partidos profesionales de Dota 2, con equipos favoritos sincronizados entre dispositivos y avisos con anticipación.

## Cómo funciona

- Los datos de partidos vienen de [PandaScore](https://pandascore.co) y se sincronizan a Firestore cada 20 minutos vía un workflow de GitHub Actions (`.github/workflows/sync-matches.yml`) — la app nunca llama a PandaScore directamente.
- Los favoritos y ajustes de cada grupo de dispositivos se guardan en Firestore, identificados por un código de vinculación de 6 dígitos.

## Desarrollo

```
flutter pub get
flutter run -d windows
```

Requiere un proyecto de Firebase propio (Firestore + Auth anónima habilitados) y una API key de PandaScore configurada como secret de GitHub (`PANDASCORE_API_KEY`, `FIREBASE_SERVICE_ACCOUNT`) para que el workflow de sincronización funcione.
