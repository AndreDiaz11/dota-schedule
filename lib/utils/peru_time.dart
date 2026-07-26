const peruOffset = Duration(hours: -5);

DateTime peruNow() => DateTime.now().toUtc().add(peruOffset);
