---
name: ukentlige-oppdateringer
description: Kjør ukentlige Dependabot-oppdateringer for GitHub Actions-workflows i dette repoet
---

Du er en agent som utfører ukentlige oppdateringer av GitHub Actions-workflows for dette repoet. Dependabot har allerede åpnet PRer — din jobb er å samle dem på én branch og klargjøre for merge.


## Kontekst om repoet

- **Dependabot-konfigurert for**: GitHub Actions-workflows (`.github/workflows/`)
- **Ingen package manager** — kun workflow-filer oppdateres
- **CI/CD**: Deploy til dev skjer via `workflow_dispatch`


## Steg 1 — Finn ukenummer og opprett branch

```bash
WEEK=$(date +%V)
YEAR=$(date +%Y)
BRANCH="oppdateringer/uke-${WEEK}-${YEAR}"
git checkout main
git pull origin main
git checkout -b "$BRANCH"
echo "Branch opprettet: $BRANCH"
```


## Steg 2 — Hent og verifiser åpne Dependabot-PRer

```bash
gh pr list --author "app/dependabot" --state open --json number,title,headRefName,labels,author
```

### ⚠️ Sikkerhetssjekk før merge

**Verifiser for hver PR at:**
1. `author.login` er nøyaktig `app/dependabot`
2. Branch-navnet følger mønsteret `dependabot/github-actions/<action-navn>`
3. Endringer er begrenset til filer under `.github/workflows/`

```bash
gh pr view <nr> --json author,headRefName,files \
  | jq '{author: .author.login, branch: .headRefName, files: [.files[].path]}'
```

**Ikke merge PRer som:**
- Har en annen avsender enn `app/dependabot`
- Inneholder endringer utenfor `.github/workflows/`

### ⚠️ Major-versjonshopp i actions — les release notes

Dersom en PR bumper en action til en **ny major-versjon** (f.eks. `actions/checkout@v3` → `v4`):

```bash
# Les release notes for actionen
gh pr view <nr> --json body | jq -r '.body' | head -100
```

**Sjekk spesielt:**
- Er det endringer i inputs/outputs?
- Krever actionen ny versjon av runner-OS eller annen konfigurasjon?
- Er det `breaking`-endringer som påvirker eksisterende workflow-konfigurasjon?

### Prioriter sikkerhets-PRer

```bash
gh pr list --author "app/dependabot" --state open --json number,title,labels \
  | jq '.[] | select(.labels[].name | test("security"))'
```


## Steg 3 — Merge PRer

For hver PR:

```bash
git fetch origin <dependabot-branch>
git merge origin/<dependabot-branch> --no-edit
```

Ingen bygg/test-steg er nødvendig for rene workflow-oppdateringer.

### Revertering

```bash
git revert HEAD --no-edit
```


## Steg 4 — Push og lag PR

```bash
git push origin "$BRANCH"

gh pr create \
  --title "Ukentlige oppdateringer uke ${WEEK}" \
  --body "$(cat <<'EOF'
## Ukentlige GitHub Actions-oppdateringer

Denne PRen samler alle Dependabot-oppdateringer av GitHub Actions for uken.

### Inkluderte oppdateringer
<!-- Liste over oppdaterte actions med versjoner -->

### Skippet oppdateringer
<!-- PRer som ikke ble inkludert, med begrunnelse -->

### Verifisering
- [ ] CI-bygg er grønt etter merge

Merge til `main` etter godkjenning.
EOF
)" \
  --base main \
  --head "$BRANCH"
```


## Steg 5 — Instruksjon til mennesket

```
✅ Branch klar: oppdateringer/uke-<uke-nr>-<år>

Neste steg:
1. Gjennomgå PR-en
2. Godkjenn og merge mot main

Merget i denne runden:
<liste over actions som ble oppdatert>
```
