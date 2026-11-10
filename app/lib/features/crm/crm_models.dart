import '../../l10n/app_localizations.dart';

/// Pipeline statuses in board order (matches the API).
const applicationStatuses = [
  'discovered',
  'researched',
  'ready_to_contact',
  'draft_created',
  'sent',
  'waiting_for_reply',
  'follow_up_needed',
  'replied',
  'interview',
  'offer',
  'hired',
  'rejected',
  'no_vacancies',
  'keep_in_touch',
];

String statusLabel(AppLocalizations l, String s) => switch (s) {
  'discovered' => l.stDiscovered,
  'researched' => l.stResearched,
  'ready_to_contact' => l.stReadyToContact,
  'draft_created' => l.stDraftCreated,
  'sent' => l.stSent,
  'waiting_for_reply' => l.stWaitingForReply,
  'follow_up_needed' => l.stFollowUpNeeded,
  'replied' => l.stReplied,
  'interview' => l.stInterview,
  'offer' => l.stOffer,
  'hired' => l.stHired,
  'rejected' => l.stRejected,
  'no_vacancies' => l.stNoVacancies,
  'keep_in_touch' => l.stKeepInTouch,
  _ => s,
};

DateTime? _d(Object? v) => v == null ? null : DateTime.parse(v as String);

class FollowUp {
  const FollowUp({
    required this.id,
    required this.title,
    required this.dueAt,
    this.completedAt,
    this.applicationId,
    this.companyId,
    this.companyName,
    this.overdue = false,
  });

  factory FollowUp.fromJson(Map<String, dynamic> j) => FollowUp(
    id: j['id'] as String,
    title: j['title'] as String,
    dueAt: DateTime.parse(j['due_at'] as String),
    completedAt: _d(j['completed_at']),
    applicationId: j['application_id'] as String?,
    companyId: j['company_id'] as String?,
    companyName: j['company_name'] as String?,
    overdue: j['overdue'] as bool? ?? false,
  );

  final String id;
  final String title;
  final DateTime dueAt;
  final DateTime? completedAt;
  final String? applicationId;
  final String? companyId;
  final String? companyName;
  final bool overdue;

  bool get done => completedAt != null;
}

class StatusChange {
  const StatusChange(this.fromStatus, this.toStatus, this.note, this.changedAt);
  factory StatusChange.fromJson(Map<String, dynamic> j) => StatusChange(
    j['from_status'] as String?,
    j['to_status'] as String,
    j['note'] as String?,
    DateTime.parse(j['changed_at'] as String),
  );
  final String? fromStatus;
  final String toStatus;
  final String? note;
  final DateTime changedAt;
}

class Application {
  const Application({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.status,
    required this.updatedAt,
    this.position,
    this.contactId,
    this.contactName,
    this.notes,
    this.sentAt,
    this.lastReplyAt,
    this.nextFollowUpAt,
    this.history = const [],
    this.followUps = const [],
  });

  factory Application.fromJson(Map<String, dynamic> j) => Application(
    id: j['id'] as String,
    companyId: j['company_id'] as String,
    companyName: j['company_name'] as String,
    status: j['status'] as String,
    updatedAt: DateTime.parse(j['updated_at'] as String),
    position: j['position'] as String?,
    contactId: j['contact_id'] as String?,
    contactName: j['contact_name'] as String?,
    notes: j['notes'] as String?,
    sentAt: _d(j['sent_at']),
    lastReplyAt: _d(j['last_reply_at']),
    nextFollowUpAt: _d(j['next_follow_up_at']),
    history: [
      for (final h in (j['history'] as List? ?? const [])) StatusChange.fromJson(h as Map<String, dynamic>),
    ],
    followUps: [
      for (final f in (j['follow_ups'] as List? ?? const [])) FollowUp.fromJson(f as Map<String, dynamic>),
    ],
  );

  final String id;
  final String companyId;
  final String companyName;
  final String status;
  final DateTime updatedAt;
  final String? position;
  final String? contactId;
  final String? contactName;
  final String? notes;
  final DateTime? sentAt;
  final DateTime? lastReplyAt;
  final DateTime? nextFollowUpAt;
  final List<StatusChange> history;
  final List<FollowUp> followUps;
}

class PipelineStats {
  const PipelineStats({
    required this.total,
    required this.sent,
    required this.replied,
    required this.interviews,
    required this.offers,
    required this.overdueFollowUps,
    this.replyRate,
    this.medianDaysToReply,
  });

  factory PipelineStats.fromJson(Map<String, dynamic> j) => PipelineStats(
    total: j['total'] as int,
    sent: j['sent'] as int,
    replied: j['replied'] as int,
    interviews: j['interviews'] as int,
    offers: j['offers'] as int,
    overdueFollowUps: j['overdue_follow_ups'] as int,
    replyRate: (j['reply_rate'] as num?)?.toDouble(),
    medianDaysToReply: (j['median_days_to_reply'] as num?)?.toDouble(),
  );

  final int total;
  final int sent;
  final int replied;
  final int interviews;
  final int offers;
  final int overdueFollowUps;
  final double? replyRate;
  final double? medianDaysToReply;
}

class TimelineEvent {
  const TimelineEvent(this.at, this.kind, this.title, this.detail);
  factory TimelineEvent.fromJson(Map<String, dynamic> j) => TimelineEvent(
    DateTime.parse(j['at'] as String),
    j['kind'] as String,
    j['title'] as String,
    j['detail'] as String?,
  );
  final DateTime at;
  final String kind;
  final String title;
  final String? detail;
}

String timelineLabel(AppLocalizations l, String kind) => switch (kind) {
  'company_added' => l.tlCompanyAdded,
  'note' => l.tlNote,
  'contact_added' => l.tlContactAdded,
  'application_created' => l.tlApplicationCreated,
  'status_changed' => l.tlStatusChanged,
  'follow_up_created' => l.tlFollowUpCreated,
  'follow_up_done' => l.tlFollowUpDone,
  'vacancy_added' => l.tlVacancyAdded,
  'source_added' => l.tlSourceAdded,
  _ => kind,
};
