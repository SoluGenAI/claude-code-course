# Claude Code Workshop — March 2026

## Table of Contents

- [Team Plugin Marketplace](#team-plugin-marketplace)
- [Pre-work](#pre-work)
- [Session 1 | Claude Code Fundamentals](#session-1--claude-code-fundamentals)
- [Session 2 | Claude Ecosystem & Defining Team Workflows](#session-2--claude-ecosystem--defining-team-workflows)
- [Session 3 | Mini-Hackathon](#session-3--mini-hackathon)
- [Session 4 | Reset, Reflect, Publish](#session-4--reset-reflect-publish)

---

## Team Plugin Marketplace

This repo doubles as the SoluGenAI team's Claude Code plugin marketplace. Each developer owns a subdir (`ariel/`, `eyal/`, `lior/`, `netanel/`, `tamar/`) containing their own plugin. The marketplace catalog lives at the repo root: `.claude-plugin/marketplace.json`.

### Install a teammate's plugin

```
/plugin marketplace add SoluGenAI/claude-code-course
/plugin install lior-plugin@solugenai-team
```

### Update an installed plugin after a teammate pushes changes

```
/plugin marketplace update solugenai-team
/plugin update lior-plugin@solugenai-team
```

### Publishing your own plugin

See `the_actual_content/session_4/PLUGIN_BUILD_GUIDE.md` for the step-by-step.

---

## Pre-work

- [ ] Verify Claude Code v2.1.76 with: `claude --version`
- [ ] Clone the `claude-code-course` repo.
- [ ] Populate '.env' files in your subdir (with API keys for OpenAI and Tavily, provided by Elad)

---

## Session 1 | Claude Code Fundamentals

1. Course overview
2. Why Claude Code
3. Setup
4. **Claude Code Walkthrough** along with **Practice Project**
5. /insights
6. Questions

### Takeaways
- Understanding Claude Code's builtin features
- Setting up some Skills, Hooks, MCPs, Subagents, Rules, CLAUDE.md
- Practice project: Oscar the Chatbot

---

## Session 2 — Claude Ecosystem & Defining Team Workflows

Syncing on a shared team configuration and practices, after a deeper familiarity with the broader Claude Code ecosystem — community tools, remote execution, Claude CoWork, and more. 

### Takeaways
- Broader familiarity with Claude's possibilities
- Each person builds a plugin and shares with the team
- Upgraded and team-synced Claude Code env

---

## Session 3 — Mini-Hackathon

A dedicated build session. Putting theory to reality in full: Test-Driven agentic coding with Claude Code, around the same PRD. 
This is where everything from the course comes together.
Meeting obstacles and using the time with the highest priority not being the final product, but your Claude Code workflow fine-tuning.
The project will be announced at the start of the session.
Development would be using the 'claude --worktrees' feature.

### Takeaways
- A ready-for-**build-review** project per group.

> There will be a few days between Session 3 and Session 4. This time would be needed both in order to test the project (which would rely on some time passing...), and also to test the documentation quality you've established for yourself, to easily review it and deeply understand it a few days later.

---

## Session 4 — Reset, Reflect, Publish

Two months passed between Session 3 and Session 4 — long enough that this final session is reframed away from in-flight chatbot review and toward a reset + plugin-publishing workshop:

1. **Free Q&A and decompression.** What's been working, what's been frustrating, what's changed.
2. **`/insights` round-robin.** Everyone runs the built-in `/insights` command and shares one surprising number, one expected number, and one workflow change they'll make.
3. **Build & publish your plugin.** Each developer ships a Claude Code plugin in their own subdir, published to the team marketplace at the repo root, installable by every teammate with one command.
4. **Wrap.** Live install demo, post-course cadence.

### Takeaways
- Each participant publishes a working plugin teammates can install.
- Concrete data on personal Claude Code usage from `/insights`.
- The course repo is now the team's living plugin marketplace.

See `the_actual_content/session_4/00_SESSION_4_TALKING_POINTS.md` for the instructor script and `PLUGIN_BUILD_GUIDE.md` for the participant handout.
