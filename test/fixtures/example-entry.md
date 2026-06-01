---
title: Idempotency
created: 2026-05-31
updated: 2026-05-31
tags: [distributed-systems, http, reliability]
status: verified
sources:
  - https://www.rfc-editor.org/rfc/rfc9110#name-idempotent-methods
  - https://developer.mozilla.org/en-US/docs/Glossary/Idempotent
  - https://en.wikipedia.org/wiki/Idempotence
---

# Idempotency

An operation is idempotent if applying it many times has the same effect as applying it once.

## TL;DR
- **What:** repeating the operation does not change the result beyond the first application.
- **Why it matters:** it makes retries safe — the single most important property for reliability over unreliable networks.
- **Central tradeoff:** achieving it often requires extra machinery (idempotency keys, conditional writes, dedupe state) that you wouldn't need if delivery were perfectly reliable.
- **Read next:** RFC 9110 §9.2.2 for the precise HTTP definition.

## What it is
Formally, a function `f` is idempotent when `f(f(x)) = f(x)` for all `x` in its domain ([Wikipedia](https://en.wikipedia.org/wiki/Idempotence)). In systems work the practical form is: issuing the same request twice leaves the system in the same state as issuing it once.

In HTTP, `GET`, `PUT`, and `DELETE` are defined as idempotent, while `POST` is not — sending `PUT /users/42 {…}` twice yields the same stored resource, but `POST /users {…}` twice may create two records ([RFC 9110, §9.2.2](https://www.rfc-editor.org/rfc/rfc9110#name-idempotent-methods); [MDN](https://developer.mozilla.org/en-US/docs/Glossary/Idempotent)). Idempotency is about the *observable end state*, not the response: a second `DELETE` may return `404`, but the resource is still gone, so the method remains idempotent.

## Why this matters
Anything that retries — a network client, a message queue, a CI step, a git hook that may run more than once — needs idempotency to be safe. This repo's own installer is built on it: re-running `install.sh` detects its own markers and converges to the same state instead of duplicating the hook or the rules snippet. That is idempotency applied directly: the second run is a no-op in effect.

## Sources
- [RFC 9110 — HTTP Semantics, §9.2.2](https://www.rfc-editor.org/rfc/rfc9110#name-idempotent-methods) · the normative definition of idempotent HTTP methods.
- [MDN — Idempotent](https://developer.mozilla.org/en-US/docs/Glossary/Idempotent) · concise, example-driven web-developer framing.
- [Wikipedia — Idempotence](https://en.wikipedia.org/wiki/Idempotence) · the general mathematical definition across domains.
