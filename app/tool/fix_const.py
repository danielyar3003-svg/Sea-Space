"""Remove the nearest enclosing `const` for analyzer const-evaluation errors (one-off helper)."""
import re, subprocess, collections
CODES = {'invalid_constant', 'const_eval_method_invocation', 'non_constant_list_element',
         'const_with_non_constant_argument', 'non_constant_map_value', 'const_initialized_with_non_constant_value',
         'non_constant_default_value', 'const_constructor_param_type_mismatch', 'const_eval_property_access',
         'non_constant_map_element', 'const_constructor_with_non_const_super'}
for it in range(30):
    out = subprocess.run(['flutter', 'analyze', '--no-pub'], capture_output=True, text=True).stdout
    errs = collections.defaultdict(set)
    for line in out.splitlines():
        m = re.match(r"\s*error • .* • (.+?):(\d+):(\d+) • (\w+)", line)
        if m and m.group(4) in CODES:
            errs[m.group(1)].add((int(m.group(2)), int(m.group(3))))
    if not errs:
        print('done after', it, 'iterations'); break
    fixed = 0
    for f, pos in errs.items():
        text = open(f).read()
        lines = text.splitlines(keepends=True)
        offsets = [0]
        for l in lines: offsets.append(offsets[-1] + len(l))
        targets = set()
        for ln, col in pos:
            off = offsets[ln - 1] + col - 1
            i = text.rfind('const ', 0, off)
            # also 'const [' / 'const {' forms are covered by 'const '
            if i >= 0: targets.add(i)
        for i in sorted(targets, reverse=True):
            text = text[:i] + text[i + 6:]
            fixed += 1
        open(f, 'w').write(text)
    print('iteration', it, 'removed', fixed)
