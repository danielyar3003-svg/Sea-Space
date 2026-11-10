/// Candidate profile as returned by `/api/v1/profiles`.
class Experience {
  const Experience({
    this.id,
    this.vesselName,
    this.vesselType,
    this.employerName,
    this.position,
    this.duties = const [],
    this.startDate,
    this.endDate,
    this.notes,
  });

  factory Experience.fromJson(Map<String, dynamic> j) => Experience(
    id: j['id'] as String?,
    vesselName: j['vessel_name'] as String?,
    vesselType: j['vessel_type'] as String?,
    employerName: j['employer_name'] as String?,
    position: j['position'] as String?,
    duties: (j['duties'] as List? ?? const []).cast<String>(),
    startDate: j['start_date'] == null ? null : DateTime.parse(j['start_date'] as String),
    endDate: j['end_date'] == null ? null : DateTime.parse(j['end_date'] as String),
    notes: j['notes'] as String?,
  );

  final String? id;
  final String? vesselName;
  final String? vesselType;
  final String? employerName;
  final String? position;
  final List<String> duties;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  static String? _d(DateTime? d) => d?.toIso8601String().substring(0, 10);

  Map<String, dynamic> toJson() => {
    'vessel_name': vesselName,
    'vessel_type': vesselType,
    'employer_name': employerName,
    'position': position,
    'duties': duties,
    'start_date': _d(startDate),
    'end_date': _d(endDate),
    'notes': notes,
  };
}

const englishLevels = {
  'beginner': 'Beginner',
  'elementary': 'Elementary',
  'intermediate': 'Intermediate',
  'upper_intermediate': 'Upper-intermediate',
  'advanced': 'Advanced',
  'fluent': 'Fluent',
};

class CandidateProfile {
  const CandidateProfile({
    this.id,
    this.label = 'Main profile',
    this.isPrimary = false,
    this.fullName,
    this.nationality,
    this.englishLevel,
    this.yearsOfExperience,
    this.experienceIsApproximate = true,
    this.targetPositions = const [],
    this.experienceAreas = const [],
    this.summary,
    this.experience = const [],
  });

  factory CandidateProfile.fromJson(Map<String, dynamic> j) => CandidateProfile(
    id: j['id'] as String?,
    label: j['label'] as String,
    isPrimary: j['is_primary'] as bool? ?? false,
    fullName: j['full_name'] as String?,
    nationality: j['nationality'] as String?,
    englishLevel: j['english_level'] as String?,
    yearsOfExperience: j['years_of_experience'] == null
        ? null
        : double.parse(j['years_of_experience'].toString()),
    experienceIsApproximate: j['experience_is_approximate'] as bool? ?? true,
    targetPositions: (j['target_positions'] as List? ?? const []).cast<String>(),
    experienceAreas: (j['experience_areas'] as List? ?? const []).cast<String>(),
    summary: j['summary'] as String?,
    experience: [
      for (final e in (j['experience'] as List? ?? const [])) Experience.fromJson(e as Map<String, dynamic>),
    ],
  );

  /// The starting profile from the product brief. It is only a pre-filled form —
  /// nothing is saved until the user reviews and confirms it. No certificates,
  /// dates or qualifications are included because none were provided.
  static const suggestedInitial = CandidateProfile(
    label: 'Deck & fish processing',
    nationality: 'Ukrainian',
    englishLevel: 'intermediate',
    yearsOfExperience: 4,
    experienceIsApproximate: true,
    targetPositions: ['AB', 'Deckhand', 'Trawl Deckhand', 'Fish Factory Worker', 'Processing Crew'],
    experienceAreas: [
      'Krill factory operations',
      'Fish processing',
      'Holdman duties',
      'Deckhand duties',
      'Boatswain assistance',
      'Deck maintenance',
      'General fishing vessel operations',
    ],
  );

  static const suggestedInitialExperience = Experience(
    vesselName: 'M/V More Sodruzhestva',
    duties: [
      'Krill factory operations',
      'Fish processing',
      'Holdman duties',
      'Deckhand duties',
      'Boatswain assistance',
      'Deck maintenance',
    ],
  );

  final String? id;
  final String label;
  final bool isPrimary;
  final String? fullName;
  final String? nationality;
  final String? englishLevel;
  final double? yearsOfExperience;
  final bool experienceIsApproximate;
  final List<String> targetPositions;
  final List<String> experienceAreas;
  final String? summary;
  final List<Experience> experience;

  Map<String, dynamic> toJson() => {
    'label': label,
    'full_name': fullName,
    'nationality': nationality,
    'english_level': englishLevel,
    'years_of_experience': yearsOfExperience?.toStringAsFixed(1),
    'experience_is_approximate': experienceIsApproximate,
    'target_positions': targetPositions,
    'experience_areas': experienceAreas,
    'summary': summary,
  };
}
