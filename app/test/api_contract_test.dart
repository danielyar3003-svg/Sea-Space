// Parses responses captured from the real FastAPI backend
// (backend/scripts/export_api_contract.py) with the app's models, so the app and the
// server cannot drift apart unnoticed.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sea_space/features/companies/company_models.dart';
import 'package:sea_space/features/crm/crm_models.dart';
import 'package:sea_space/features/home/dashboard_repository.dart';
import 'package:sea_space/features/profile/profile_models.dart';

void main() {
  final data = jsonDecode(File('test/fixtures/api_contract.json').readAsStringSync()) as Map<String, dynamic>;
  List<Map<String, dynamic>> list(String k) => (data[k] as List).cast<Map<String, dynamic>>();

  test('companies and company detail', () {
    final s = CompanySummary.fromJson(list('companies').single);
    expect(s.name, 'Contract Fishing AS');
    expect(s.industries, ['krill']);
    expect(s.contactsCount, 1);
    final d = CompanyDetail.fromJson(data['company_detail'] as Map<String, dynamic>);
    expect(d.provenance.status, 'user_provided');
    expect(d.websites.single.url, 'https://contract.example/');
    expect(d.notes.single.body, 'Note');
    expect(d.vessels.single.role, 'operator');
    expect(d.vessels.single.isCrewingEmployer, isNull);
  });

  test('contacts, fleet, vacancies, targets', () {
    final c = Contact.fromJson(list('contacts').single);
    expect(c.isGeneric, isTrue);
    expect(c.emailStatus, 'public_unverified');
    expect(c.domainMatchesCompany, isTrue);
    expect(c.companyName, 'Contract Fishing AS');
    expect(list('vessel_types').map(VesselType.fromJson), hasLength(9));
    final v = Vessel.fromJson(list('vessels').single);
    expect(v.imoNumber, '9074729');
    expect(v.links.single.companyName, 'Contract Fishing AS');
    expect(v.potentialPositions, isNotEmpty);
    final vac = Vacancy.fromJson(list('vacancies').single);
    expect(vac.status, 'unverified');
    expect(vac.salaryText, '3000 EUR / monthly');
    expect(list('targets').map(ResearchTarget.fromJson).map((t) => t.name), contains('Samherji'));
  });

  test('duplicate error, dashboard, profile', () {
    final dup = data['duplicate_error'] as Map<String, dynamic>;
    expect(dup['status'], 409);
    final detail = (dup['body'] as Map)['detail'] as Map<String, dynamic>;
    expect(detail['can_override'], isTrue);
    expect((detail['candidates'] as List).single['name'], 'Contract Fishing AS');
    final dash = DashboardSummary.fromJson(data['dashboard'] as Map<String, dynamic>);
    expect(dash.counts.companies, 1);
    expect(dash.newCompanies.single.title, 'Contract Fishing AS');
    final p = CandidateProfile.fromJson(data['primary_profile'] as Map<String, dynamic>);
    expect(p.yearsOfExperience, 4);
    expect(p.englishLevel, 'intermediate');
  });

  test('CRM: application, board, stats, follow-ups, timeline', () {
    final app = Application.fromJson(data['application_detail'] as Map<String, dynamic>);
    expect(app.status, 'sent');
    expect(app.companyName, 'Contract Fishing AS');
    expect(app.history.first.fromStatus, 'discovered');
    expect(app.history.first.note, 'CV sent');
    expect(app.followUps.single.done, isFalse);
    expect(app.nextFollowUpAt, isNotNull);
    final board = list('board');
    expect(board.map((c) => c['status']), applicationStatuses);
    final stats = PipelineStats.fromJson(data['stats'] as Map<String, dynamic>);
    expect(stats.sent, 1);
    expect(stats.replyRate, 0);
    expect(FollowUp.fromJson(list('follow_ups').single).companyName, 'Contract Fishing AS');
    final kinds = list('timeline').map(TimelineEvent.fromJson).map((e) => e.kind).toSet();
    expect(
      kinds,
      containsAll(['company_added', 'application_created', 'status_changed', 'follow_up_created']),
    );
    expect((data['me'] as Map)['locale'], 'en');
  });
}
