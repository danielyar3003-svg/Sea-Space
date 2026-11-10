/// Models for companies, contacts, fleet and vacancies (Phase 3 API).
library;

DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String);
List<String> _strings(Object? v) => (v as List? ?? const []).cast<String>();
List<Map<String, dynamic>> _maps(Object? v) => (v as List? ?? const []).cast<Map<String, dynamic>>();

const hiringStatusLabels = {
  'actively_hiring': 'Actively hiring',
  'no_current_vacancies': 'No current vacancies',
  'speculative_accepted': 'Speculative applications accepted',
  'recruitment_agency': 'Recruitment agency',
  'unknown': 'Unknown hiring status',
};

const industryLabels = {
  'fishing': 'Fishing',
  'trawling': 'Trawling',
  'krill': 'Krill',
  'seafood_processing': 'Seafood processing',
  'factory_vessel': 'Factory vessels',
  'recruitment_agency': 'Recruitment agency',
  'ship_management': 'Ship management',
  'other': 'Other',
};

const verificationLabels = {
  'verified': 'Verified',
  'unverified': 'Unverified',
  'inferred': 'Inferred',
  'user_provided': 'Entered by you',
};

/// Source attribution shared by companies, contacts and vessels.
class Provenance {
  const Provenance({required this.status, this.sourceUrl, this.lastVerifiedAt});

  factory Provenance.fromJson(Map<String, dynamic> j) => Provenance(
    status: j['verification_status'] as String? ?? 'unverified',
    sourceUrl: j['source_url'] as String?,
    lastVerifiedAt: _date(j['last_verified_at']),
  );

  final String status;
  final String? sourceUrl;
  final DateTime? lastVerifiedAt;

  bool get isVerified => status == 'verified';
}

class CompanySummary {
  const CompanySummary({
    required this.id,
    required this.name,
    required this.hiringStatus,
    required this.provenance,
    this.countryCode,
    this.headquarters,
    this.industries = const [],
    this.contactsCount = 0,
    this.openVacanciesCount = 0,
  });

  factory CompanySummary.fromJson(Map<String, dynamic> j) => CompanySummary(
    id: j['id'] as String,
    name: j['name'] as String,
    hiringStatus: j['hiring_status'] as String,
    provenance: Provenance.fromJson(j),
    countryCode: j['country_code'] as String?,
    headquarters: j['headquarters'] as String?,
    industries: _strings(j['industries']),
    contactsCount: j['contacts_count'] as int? ?? 0,
    openVacanciesCount: j['open_vacancies_count'] as int? ?? 0,
  );

  final String id;
  final String name;
  final String hiringStatus;
  final Provenance provenance;
  final String? countryCode;
  final String? headquarters;
  final List<String> industries;
  final int contactsCount;
  final int openVacanciesCount;
}

class Website {
  const Website(this.id, this.url, this.kind);
  factory Website.fromJson(Map<String, dynamic> j) =>
      Website(j['id'] as String, j['url'] as String, j['kind'] as String);
  final String id;
  final String url;
  final String kind;
}

class SourceRef {
  const SourceRef({required this.id, required this.type, this.url, this.title, required this.retrievedAt});
  factory SourceRef.fromJson(Map<String, dynamic> j) => SourceRef(
    id: j['id'] as String,
    type: j['source_type'] as String,
    url: j['url'] as String?,
    title: j['title'] as String?,
    retrievedAt: DateTime.parse(j['retrieved_at'] as String),
  );
  final String id;
  final String type;
  final String? url;
  final String? title;
  final DateTime retrievedAt;
}

class Note {
  const Note(this.id, this.body, this.createdAt);
  factory Note.fromJson(Map<String, dynamic> j) =>
      Note(j['id'] as String, j['body'] as String, DateTime.parse(j['created_at'] as String));
  final String id;
  final String body;
  final DateTime createdAt;
}

class VesselLink {
  const VesselLink({
    required this.id,
    required this.role,
    required this.vesselId,
    required this.vesselName,
    required this.companyId,
    required this.companyName,
    this.isCrewingEmployer,
  });
  factory VesselLink.fromJson(Map<String, dynamic> j) => VesselLink(
    id: j['id'] as String,
    role: j['role'] as String,
    vesselId: j['vessel_id'] as String,
    vesselName: j['vessel_name'] as String,
    companyId: j['company_id'] as String,
    companyName: j['company_name'] as String,
    isCrewingEmployer: j['is_crewing_employer'] as bool?,
  );
  final String id;
  final String role;
  final String vesselId;
  final String vesselName;
  final String companyId;
  final String companyName;
  final bool? isCrewingEmployer;
}

class CompanyDetail extends CompanySummary {
  const CompanyDetail({
    required super.id,
    required super.name,
    required super.hiringStatus,
    required super.provenance,
    super.countryCode,
    super.headquarters,
    super.industries,
    super.contactsCount,
    super.openVacanciesCount,
    this.speculativePolicy,
    this.careersUrl,
    this.recruitmentEmail,
    this.fleetSummary,
    this.description,
    this.websites = const [],
    this.sources = const [],
    this.notes = const [],
    this.vessels = const [],
  });

  factory CompanyDetail.fromJson(Map<String, dynamic> j) {
    final s = CompanySummary.fromJson(j);
    return CompanyDetail(
      id: s.id,
      name: s.name,
      hiringStatus: s.hiringStatus,
      provenance: s.provenance,
      countryCode: s.countryCode,
      headquarters: s.headquarters,
      industries: s.industries,
      contactsCount: s.contactsCount,
      openVacanciesCount: s.openVacanciesCount,
      speculativePolicy: j['speculative_policy'] as String?,
      careersUrl: j['careers_url'] as String?,
      recruitmentEmail: j['recruitment_email'] as String?,
      fleetSummary: j['fleet_summary'] as String?,
      description: j['description'] as String?,
      websites: [for (final w in _maps(j['websites'])) Website.fromJson(w)],
      sources: [for (final x in _maps(j['sources'])) SourceRef.fromJson(x)],
      notes: [for (final n in _maps(j['notes'])) Note.fromJson(n)],
      vessels: [for (final v in _maps(j['vessels'])) VesselLink.fromJson(v)],
    );
  }

  final String? speculativePolicy;
  final String? careersUrl;
  final String? recruitmentEmail;
  final String? fleetSummary;
  final String? description;
  final List<Website> websites;
  final List<SourceRef> sources;
  final List<Note> notes;
  final List<VesselLink> vessels;
}

class Contact {
  const Contact({
    required this.id,
    required this.companyId,
    required this.kind,
    required this.contactStatus,
    required this.provenance,
    this.companyName,
    this.fullName,
    this.jobTitle,
    this.email,
    this.emailStatus,
    this.phone,
    this.linkedinUrl,
    this.domainMatchesCompany,
  });

  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
    id: j['id'] as String,
    companyId: j['company_id'] as String,
    kind: j['contact_kind'] as String,
    contactStatus: j['contact_status'] as String,
    provenance: Provenance.fromJson(j),
    companyName: j['company_name'] as String?,
    fullName: j['full_name'] as String?,
    jobTitle: j['job_title'] as String?,
    email: j['email'] as String?,
    emailStatus: j['email_status'] as String?,
    phone: j['phone'] as String?,
    linkedinUrl: j['linkedin_url'] as String?,
    domainMatchesCompany: j['domain_matches_company'] as bool?,
  );

  final String id;
  final String companyId;
  final String kind;
  final String contactStatus;
  final Provenance provenance;
  final String? companyName;
  final String? fullName;
  final String? jobTitle;
  final String? email;
  final String? emailStatus;
  final String? phone;
  final String? linkedinUrl;
  final bool? domainMatchesCompany;

  bool get isGeneric => kind == 'generic_inbox';
  String get displayName => fullName ?? (isGeneric ? 'Recruitment inbox' : email ?? 'Unnamed contact');
}

class VesselType {
  const VesselType(this.id, this.code, this.name, this.typicalPositions);
  factory VesselType.fromJson(Map<String, dynamic> j) => VesselType(
    j['id'] as String,
    j['code'] as String,
    j['name'] as String,
    _strings(j['typical_positions']),
  );
  final String id;
  final String code;
  final String name;
  final List<String> typicalPositions;
}

class Vessel {
  const Vessel({
    required this.id,
    required this.name,
    required this.provenance,
    this.imoNumber,
    this.flagCountryCode,
    this.type,
    this.fishingSpecialization,
    this.links = const [],
    this.potentialPositions = const [],
  });

  factory Vessel.fromJson(Map<String, dynamic> j) => Vessel(
    id: j['id'] as String,
    name: j['name'] as String,
    provenance: Provenance.fromJson(j),
    imoNumber: j['imo_number'] as String?,
    flagCountryCode: j['flag_country_code'] as String?,
    type: j['vessel_type'] == null ? null : VesselType.fromJson(j['vessel_type'] as Map<String, dynamic>),
    fishingSpecialization: j['fishing_specialization'] as String?,
    links: [for (final l in _maps(j['links'])) VesselLink.fromJson(l)],
    potentialPositions: _strings(j['potential_positions']),
  );

  final String id;
  final String name;
  final Provenance provenance;
  final String? imoNumber;
  final String? flagCountryCode;
  final VesselType? type;
  final String? fishingSpecialization;
  final List<VesselLink> links;
  final List<String> potentialPositions;
}

class Vacancy {
  const Vacancy({
    required this.id,
    required this.employerName,
    required this.position,
    required this.status,
    required this.sourceUrl,
    required this.discoveredAt,
    this.companyId,
    this.countryCode,
    this.vesselType,
    this.salaryMin,
    this.salaryMax,
    this.currency,
    this.salaryPeriod,
    this.rotation,
    this.deadline,
    this.lastVerifiedAt,
  });

  factory Vacancy.fromJson(Map<String, dynamic> j) => Vacancy(
    id: j['id'] as String,
    employerName: j['employer_name'] as String,
    position: j['position'] as String,
    status: j['status'] as String,
    sourceUrl: j['source_url'] as String,
    discoveredAt: DateTime.parse(j['discovered_at'] as String),
    companyId: j['company_id'] as String?,
    countryCode: j['country_code'] as String?,
    vesselType: j['vessel_type'] as String?,
    salaryMin: j['salary_min']?.toString(),
    salaryMax: j['salary_max']?.toString(),
    currency: j['currency'] as String?,
    salaryPeriod: j['salary_period'] as String?,
    rotation: j['rotation'] as String?,
    deadline: _date(j['application_deadline']),
    lastVerifiedAt: _date(j['last_verified_at']),
  );

  final String id;
  final String employerName;
  final String position;
  final String status;
  final String sourceUrl;
  final DateTime discoveredAt;
  final String? companyId;
  final String? countryCode;
  final String? vesselType;
  final String? salaryMin;
  final String? salaryMax;
  final String? currency;
  final String? salaryPeriod;
  final String? rotation;
  final DateTime? deadline;
  final DateTime? lastVerifiedAt;

  String? get salaryText {
    if (salaryMin == null && salaryMax == null) return null;
    String n(String v) => v.endsWith('.00') ? v.substring(0, v.length - 3) : v;
    final range = [salaryMin, salaryMax].whereType<String>().map(n).join('–');
    return '$range ${currency ?? ''}${salaryPeriod == null ? '' : ' / ${salaryPeriod!.replaceAll('_', ' ')}'}'
        .trim();
  }
}

/// A discovery finding: a fact with the page it came from. Never a verification claim.
class Finding {
  const Finding({
    required this.kind,
    required this.value,
    required this.sourceUrl,
    this.excerpt = '',
    this.hints = const {},
  });
  factory Finding.fromJson(Map<String, dynamic> j) => Finding(
    kind: j['kind'] as String,
    value: j['value'] as String,
    sourceUrl: j['source_url'] as String,
    excerpt: j['excerpt'] as String? ?? '',
    hints: (j['hints'] as Map?)?.cast<String, dynamic>() ?? const {},
  );
  final String kind;
  final String value;
  final String sourceUrl;
  final String excerpt;
  final Map<String, dynamic> hints;

  bool get importable => const {'email', 'careers_page', 'contact_page', 'speculative_policy'}.contains(kind);
}

class ResearchReport {
  const ResearchReport({
    required this.pagesChecked,
    required this.pagesSkipped,
    required this.findings,
    required this.limitations,
  });
  factory ResearchReport.fromJson(Map<String, dynamic> j) => ResearchReport(
    pagesChecked: _strings(j['pages_checked']),
    pagesSkipped: [for (final s in _maps(j['pages_skipped'])) '${s['url']} — ${s['reason']}'],
    findings: [for (final f in _maps(j['findings'])) Finding.fromJson(f)],
    limitations: _strings(j['limitations']),
  );
  final List<String> pagesChecked;
  final List<String> pagesSkipped;
  final List<Finding> findings;
  final List<String> limitations;
}

class ResearchTarget {
  const ResearchTarget(this.name, this.companyId);
  factory ResearchTarget.fromJson(Map<String, dynamic> j) =>
      ResearchTarget(j['name'] as String, j['company_id'] as String?);
  final String name;
  final String? companyId;
}
