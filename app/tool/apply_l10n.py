"""One-off helper: replace exact English UI literals with context.l10n.<key>."""
import re, sys, pathlib
sys.path.insert(0, 'tool')
from strings import S

en2key = {}
for k, v in S.items():
    en2key.setdefault(v[0], k)
overrides = {
    'tools_screens.dart': {'Verified': 'filterVerified', 'Unverified': 'filterUnverified', 'Fleet': 'fleet'},
    'discover_screen.dart': {'Unverified': 'vacUnverified'},
    'contact_dialog.dart': {'Entered by you': 'emailEnteredByYou'},
    'research_sheet.dart': {'Recruitment inbox': 'hintRecruitmentInbox'},
    'dashboard_screen.dart': {'Companies': 'statCompanies'},
    'profile_screen.dart': {'Profile': 'profile'},
}
skip = {'company_models.dart', 'profile_models.dart', 'features.dart', 'app_config.dart', 'api_client.dart',
        'l10n.dart', 'demo_backend.dart', 'demo_companies.dart', 'auth_service.dart'}
lit = re.compile(r"'((?:[^'\\$]|\\.)+)'")
total = 0
for f in sorted(pathlib.Path('lib').rglob('*.dart')):
    if f.name in skip or 'l10n' in f.parts or f.name.startswith('app_localizations'):
        continue
    src = f.read_text()
    ov = overrides.get(f.name, {})
    n = 0
    def rep(m):
        global n
        text = m.group(1).replace("\\'", "'")
        key = ov.get(text) or en2key.get(text)
        if not key:
            return m.group(0)
        globals()['n'] += 1
        return f'context.l10n.{key}'
    lines = []
    for line in src.splitlines(keepends=True):
        if line.lstrip().startswith(('import ', 'export ', '//')):
            lines.append(line); continue
        lines.append(lit.sub(rep, line))
    new = ''.join(lines)
    if new != src:
        if "core/l10n.dart'" not in new:
            depth = len(f.relative_to('lib').parts) - 1
            imp = "import '" + ('../' * depth) + "core/l10n.dart';\n"
            # insert after the last import line
            idx = [m.end() for m in re.finditer(r"^import [^\n]+\n", new, re.M)][-1]
            new = new[:idx] + imp + new[idx:]
        f.write_text(new)
        print(f, n); total += n
print('replaced', total)
