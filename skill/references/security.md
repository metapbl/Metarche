# security — security policy

Ask the security questions in discover stage 4 and approve `docs/SECURITY_POLICY.md` together with the PRD in stage 5.
The docs stage carries the policy into the agent adapters; the build and audit stages check against it.
The baseline is OWASP ASVS 5.0 (V numbers) and OWASP Top 10:2025 (A numbers). Their text is not copied; only chapter numbers are cited.

## §1 Questions (discover stage 4)
Skip anything the PRD already answers. Ask them numbered, in one batch.
1. Components: what runs on the user's side (web front end, app, desktop) and on the server side (API, workers, database)?
2. Exposure: is it reachable from the internet, or used only on an internal network or locally?
3. Users: one person, several accounts, separate roles (admin, regular)?
4. Data: what is stored and transmitted? Classify each item with the §4 table.
5. Outside: external services such as payments, authentication or storage; incoming webhooks; files users upload.
6. Region and regulation: which regions' users is it offered to, and which regulations apply?
   - The skill does not interpret law. Record only the regulations the user names, as `[U]`.
   - If the user does not know, leave "check with a regulatory expert" in OPEN. The per-class protection in §4 applies regardless.

## §2 Security level
Recommend one from the answers and record it in DECISIONS with the reason.

| Level | When | Policy scope |
|---|---|---|
| Basic | local single-user tool, no network service | from §5 only secrets, external input and dependencies |
| L1 | exposed to the internet, little sensitive data | the relevant ASVS L1 chapters |
| L2 | accounts and roles; personal data, payments or credentials | the relevant ASVS L2 chapters. Most services land here |
| L3 | financial, medical or other high-risk data; a breach does great harm | ASVS L3. Recommend an external security review |

ASVS is web-centric. For desktop and CLI tools, pick only the relevant chapters (V5 files, V11 cryptography, V13 configuration, V15 dependencies).

## §3 Trust boundaries
- What ships to the user (browser, app, desktop) is in the user's hands. Assume its code and data can be read and changed.
- So every validation and permission decision happens on the server. Client-side validation is a convenience, not a control.
- In the policy's component table, write for each boundary "what comes in" and "the control at that boundary". Responses from external services and webhooks are untrusted input too.

## §4 Data classes and protection
ASVS V14.1 asks for sensitive data to be classified and the protection for each class documented. Below are Metarche's defaults; adjust them in the policy.

| Class | Examples | At rest | In transit | Logs and screen |
|---|---|---|---|---|
| Public | public posts | plain | TLS | no limits |
| Internal | settings, usage statistics | plain + access control | TLS | no limits |
| Sensitive | names, contacts, addresses, business secrets | access control; database or disk encryption from L2 | TLS | masked in logs; return only what is needed |
| Credentials | passwords, API keys, tokens | passwords as one-way hashes; keys and tokens hashed or encrypted as in §6 | TLS; never in URLs (V14.2.1) | never in logs or on screen |
| High-risk | ID numbers, cards and accounts, biometrics, health | first look for a way not to store it (cards via a payment provider); if stored, application-level encryption (§6) | TLS | never in logs; masked on screen |

- Whether to encrypt is decided by this class, not by law. If a regulation the user named is stricter, follow it.
- Also record a retention period and a deletion method for each class.

## §5 Rules by area
Copy into the policy only the lines that apply to the project.

### Client (V3, V14.3)
- No secrets (API keys, signing keys) inside. Anything in the build is public.
- No sensitive data in browser storage (localStorage, sessionStorage, IndexedDB) (V14.3.3). Sessions live in `HttpOnly; Secure; SameSite` cookies.
- Never insert user input as HTML. Use the framework's automatic escaping; bypasses such as `innerHTML` go through a sanitizing library.
- Start the CSP without `unsafe-inline` or `unsafe-eval`. Also set HSTS, `X-Content-Type-Options: nosniff` and `frame-ancestors`.
- On logout, clear the authentication data left on the client (V14.3.1).

### Server (V1, V2, V4, V6–V8, V16)
- Authentication (V6): do not build your own; use a proven library or service. Limit login attempts.
- Authorization (V8, A01): check on every request, per object ("may this user see this order?"). Deny by default.
- Input (V2): validate with allow lists (format, length, range). Do not filter with deny lists.
- Injection (V1, A05): SQL through parameterized queries, shell commands through argument arrays. Never concatenate strings.
- API (V4): CORS lists only allowed origins. State-changing requests are protected against CSRF (SameSite cookies or tokens). Rate-limit expensive operations.
- Files (V5): check uploads for size, type and extension, and store them outside the web root under random names.
- Errors (V16, A10): show users only generic messages. Fail closed (deny).
- Logs (V16, A09): log security events such as failed logins and denied permissions. Never log the data §4 forbids.

### Common (V11–V13, V15, A03)
- Transport (V12): TLS 1.2 or later on external links. From L2, TLS between internal services too.
- Configuration (V13): in production turn debug mode off and change default accounts. Keep secrets in environment variables or a secret manager.
- Secrets: never commit them to the repository. `.env.example` holds names only. Rotate anything exposed.
- Dependencies (V15.2, A03): commit lock files and settle a vulnerability check command (`npm audit`, `pip-audit`, etc.).

## §6 Encryption choices
- Do not implement cryptography yourself. Use the language's standard library or a widely used library (V11.2).
- The table follows the 2026 OWASP cheat sheets. Copy into the policy only the rows actually used.

| Purpose | Use | Do not use |
|---|---|---|
| Password storage | Argon2id (m=19 MiB, t=2, p=1); otherwise scrypt; legacy: bcrypt (cost 10 or more) | MD5, SHA-1 or SHA-256 alone, reversible encryption |
| Encrypting stored data | AES-256-GCM | ECB mode, home-made schemes |
| Integrity and signatures | HMAC-SHA-256, Ed25519 | home-made constructions such as `hash(key + message)` |
| Random values and tokens | the OS CSPRNG (`secrets`, `crypto.randomBytes`) | ordinary random functions |
| Transport | TLS 1.2 or later (1.3 where possible) | home-made channel encryption |

Key management (V11.1):
- Keep keys apart from the data. When encrypting stored data, wrap the data key (DEK) with a key-encryption key (KEK) held in a secret manager or KMS.
- List in the policy's "encryption inventory" every key, algorithm and certificate and what each protects (V11.1.2).
- Record when keys rotate (suspected exposure, a fixed period) and how.

## §7 Incident response
When a security problem is found during the build:
1. Stop the current work and tell the user.
2. Rate the severity by who can exploit it from where and how much harm it does.
3. If a secret is exposed, rotate it first, then fix the code. A value left in git history counts as exposed even after deletion.
4. Search the whole repository for the same kind of problem.
5. Record the cause in the trap log (T#), and if a machine can catch it, add a check (check hook, security pattern).

## §8 Carrying it into the agents (docs stage)
| Policy | Goes to |
|---|---|
| Secret locations | Claude Code: `.claude/settings.json` `permissions.deny` (`Read`, `Edit`); every agent: the AGENTS.md secret-file rule |
| Review criteria (this project's lines from §5) | Claude Code with the security-guidance plugin: `.claude/claude-security-guidance.md` (under 8 KB) |
| Banned patterns a machine can catch | security linters in the check hook; with the plugin also `.claude/security-patterns.json` (semgrep, bandit, etc.) |
| Dependency check command | AGENTS.md commands section, audit |

- `claude-security-guidance.md` and `security-patterns.json` are read by the official security-guidance plugin for Claude Code. Create them only when the plugin is used (docs.md §5).
- Limit: deny rules block commands that name the file, such as `cat .env`, but not indirect reads through `grep -r` or a script. OS-level blocking is the sandbox's job, and native Windows does not support it (WSL2 needed). This is why, from L2, production secrets do not belong on the development machine.
