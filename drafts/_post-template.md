---
title:
series: Dashboards as code, learned in public
part: P?
dct_version: 0.8.0
board: https://github.com/<user>/dbt-charts-learning/blob/p?/boards/<file>.yml
status: drafting
---

<!--
HOW TO WRITE THESE POSTS

The job is to teach dbt Charts. Everything that does not serve that goes in
the repo, and the post links to it.

Belongs in the post:
  boards, queries, charts, layout, what a dct message means, what the tool
  can and cannot do, and the judgement calls behind a dashboard.

Belongs in the repo, linked not explained:
  installation, operating system differences, shell problems, version pinning,
  anything about getting a machine ready rather than about charts.

Writing rules:
  - One idea per paragraph. Two to four sentences.
  - Lead with the concrete thing, then explain it. Show the YAML, then the render.
  - Define a term the first time it appears, or do not use it.
  - Plain words over precise-sounding ones. Cut any sentence that only proves
    you did the work.
  - Headings say what the section is about, so the post can be skimmed.
  - Read it once asking "would a busy reader stop here?" and cut what makes
    them stop.

Length: aim for 1,200 to 1,600 words. If it runs longer, something belongs
in the repo or in a later post.
-->

_Written against dct 0.8.0. The syntax changes before 1.0, so check the version before copying code._

<!-- Open with a rendered board and one observation about it that sets up the post. -->

## What you will be able to do

One short paragraph. The reader can do or understand X by the end.

## Getting set up

Link the repo tag. Only mention setup that is new in this post; send the rest
to the README and `TROUBLESHOOTING.md`.

## Build

The YAML first, then the render, then the explanation — one short section per
block of the file.

## What the tool told me

One real message from dct, quoted, and what it means. Prefer messages that
teach something about how boards work over messages about a broken machine.

## Where it falls short

Limits found in this module. Link the upstream issue where there is one.

## Next

One line pointing to the next post, and a link to the board in the repo.
