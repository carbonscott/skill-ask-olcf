# skill-ask-olcf

OLCF (Oak Ridge Leadership Computing Facility) documentation assistant. Searches the
[olcf-user-docs](https://github.com/olcf/olcf-user-docs) repository via a local FTS5 index
to answer questions about Frontier, Summit, Andes, NERSC-style accounts, scheduling, modules,
and OLCF policies.

This repository is **externalized** — it is the per-skill source-of-truth for `ask-olcf`,
centrally deployed to S3DF via the meta-deploy repo
[deploy-opencode](https://github.com/carbonscott/deploy-opencode) (see its
`skills.manifest.json`).

## Layout

```
claude/skills/ask-olcf/        # Claude Code skill (identical to opencode copy)
  SKILL.md
  env.sh
  env.local                    # S3DF facility config (OLCF_DOCS_ROOT etc.)
  setup.sh
  bin/                         # docs-index FTS5 search helper
opencode/skills/ask-olcf/      # opencode skill (byte-identical duplicate of claude/)
  …same files…
tools/olcf-docs/               # cron-side tooling (deployed to /sdf/.../tools/olcf-docs/)
  env.sh
  scripts/olcf-docs-cron.sh    # weekly git pull + FTS5 reindex
```

## Deploy targets (S3DF)

| Source in this repo                          | Deployed to                                                       |
|----------------------------------------------|-------------------------------------------------------------------|
| `opencode/skills/ask-olcf/`                  | `/sdf/group/lcls/ds/dm/apps/dev/opencode/skills/ask-olcf/`        |
| `tools/olcf-docs/`                           | `/sdf/group/lcls/ds/dm/apps/dev/tools/olcf-docs/`                 |

Performed by `deploy.sh ask-olcf` in the deploy-opencode meta-repo.

## Cron schedule

After deploy.sh has run, the cron job is installed on `sdfcron001`:

```
0 3 * * 0  /sdf/group/lcls/ds/dm/apps/dev/tools/olcf-docs/scripts/olcf-docs-cron.sh run >> /sdf/group/lcls/ds/dm/apps/dev/data/olcf-docs/cron.log 2>&1
```

Schedule: **weekly, Sunday 3:00 AM**.

Operator helpers (run on `sdfcron001`):

```
/sdf/group/lcls/ds/dm/apps/dev/tools/olcf-docs/scripts/olcf-docs-cron.sh enable   # install crontab entry
/sdf/group/lcls/ds/dm/apps/dev/tools/olcf-docs/scripts/olcf-docs-cron.sh disable  # remove it
/sdf/group/lcls/ds/dm/apps/dev/tools/olcf-docs/scripts/olcf-docs-cron.sh status   # current state + last log entries
```

**RE-ENABLE notice:** As of 2026-05-13 the audit found that `tools/olcf-docs/` was deployed
under `/sdf/group/lcls/ds/dm/apps/dev/tools/` but **no crontab entry was active** on
`sdfcron001`. This skill's first post-externalization deploy must therefore **re-enable**
the cron — it is not an update to an existing schedule.

The cron job performs:

1. `git -C /sdf/.../data/olcf-docs/olcf-user-docs pull --ff-only`
2. Rebuild the FTS5 index in `/sdf/.../data/olcf-docs/olcf-docs.db`
3. `chgrp -R ps-data` + `chmod -R g+rX` on the data dir so all ps-data members can read

## Data dependency

The corpus lives at `/sdf/group/lcls/ds/dm/apps/dev/data/olcf-docs/` (cloned from
`https://github.com/olcf/olcf-user-docs.git`). The cron refreshes it weekly. The skill
reads from this central location via `OLCF_DOCS_ROOT` (set in `env.local`).

## License

See upstream [olcf-user-docs](https://github.com/olcf/olcf-user-docs) for the documentation
content's license. The wrapper scripts in this repo follow deploy-opencode's license.
