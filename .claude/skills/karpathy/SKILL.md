---
name: karpathy
description: Use before and during any coding task (writing, refactoring, fixing) to enforce 4 Karpathy-inspired principles that reduce wrong assumptions, overcomplication, unnecessary edits, and unclear success criteria. Apply when starting a non-trivial code change, when tempted to add abstractions, or when the user's request has ambiguity.
---

# Karpathy-Inspired Coding Guidelines

Four principles to counter LLM tendencies toward wrong assumptions, overcomplication, unnecessary edits, and lack of clarity. Source: forrestchang/andrej-karpathy-skills (MIT).

Apply these **in order** on every non-trivial coding task. Scale up enforcement for bigger changes; never drop entirely.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly — ask rather than guess when uncertain.
- Present multiple interpretations — never silently decide on ambiguities.
- Push back when warranted — suggest simpler approaches if they exist.
- Stop when confused — identify unclear elements and request clarification.

**Red flag to you:** writing code while still unsure what the user meant. Stop. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No unrequested features.
- No abstractions for single-use code.
- No speculative flexibility or configurability.
- No error handling for scenarios that cannot happen.
- Rewrite if 200 lines could be 50.

**Litmus test:** would an experienced engineer call this overcomplicated? If yes, simplify.

**Red flag to you:** "this might be useful later" / "in case we need it". Stop. Delete.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Do not improve adjacent code, comments, or formatting.
- Do not refactor working code.
- Match existing style, even if you'd prefer otherwise.
- Mention unrelated dead code — do not silently remove it.

**Orphaned code from your edits:**
- Remove imports/variables/functions your edits made unused.
- Preserve pre-existing dead code unless explicitly requested.

**Every altered line should directly connect to the user's request.**

**Red flag to you:** diff touches files the user didn't mention. Stop. Revert.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

- Convert instructions into declarative goals with verification steps.
- State brief plans with checkpoints for multi-step work.
- Use strong success criteria that let the LLM iterate independently.

**Red flag to you:** done "when the code compiles". Not a goal. Define verifiable behavior.

## Interaction with ARK-Project Rules

These principles stack with existing ARK CRITICAL rules (umlaute, db-techdetails, drawer-default, stammdaten, backup-before-bulk). When they conflict, ARK rules win (project-specific > generic).

For ARK specifically:
- **Think Before Coding** aligns with existing "feedback_ask_before_full_grundlagen" memory (ask before reading 225k Volltext).
- **Simplicity First** aligns with mockup-baseline consistency (no new patterns unless Peter OKs).
- **Surgical Changes** aligns with backup-before-bulk rule + Datei-Schutz-Regel.
- **Goal-Driven Execution** aligns with /ark-lint + /ark-drift-scan as verification gates.
