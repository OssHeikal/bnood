/// UI clock in Africa/Cairo. Egypt uses UTC+2 year-round (no DST as of 2024–2026).
DateTime cairoLocalNow([DateTime? reference]) {
  final utc = (reference ?? DateTime.now()).toUtc();
  return utc.add(const Duration(hours: 2));
}

/// Morning greeting before 12:00 Cairo local; evening from 12:00 onward.
bool cairoIsMorning(DateTime cairoLocal) => cairoLocal.hour < 12;
