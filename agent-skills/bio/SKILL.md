---
name: bio
description: "Canonical links to Can Demircan's scientific identity: personal webpage, Google Scholar, ORCID, GitHub, and CV. Load this when a task needs Can's author details or bio: a presentation title slide or author block, a talk or workshop bio, a paper author line, a grant or application blurb, a personal webpage edit, or any 'about the user' text. This skill holds no derived facts. Fetch the relevant link to read the current affiliation, title, bio, or publications."
---

# Bio

This skill holds Can Demircan's canonical links, nothing else. It carries no affiliation, title, or
publication list, because those go stale. When a task needs a fact, fetch the link that owns it.

## Canonical links

| Link | Owns |
|---|---|
| https://candemircan.github.io | Bio, affiliation, title, research interests, all social links |
| https://scholar.google.com/citations?user=Hu7VKscAAAAJ&hl=en | Publication list, citation counts |
| https://candemircan.github.io/cv/Demircan_cv.pdf | Full CV: education, awards, experience, full publication list |
| https://orcid.org/0000-0001-6069-1761 | Stable author ID (currently sparse) |
| https://github.com/candemircan | Code and repositories |

## Fetch map

- **Need a bio, affiliation, title, or research interests?** Fetch the webpage.
- **Need the publication list or citation counts?** Fetch Google Scholar.
- **Need education, awards, or the complete publication list?** Read the CV.
- **Need a stable author identifier?** Use the ORCID link as-is.

## How to read the CV

The CV is a binary PDF. A text web fetch cannot parse it. To read it:

1. Download it: `curl -sL https://candemircan.github.io/cv/Demircan_cv.pdf -o "$TMPDIR/cv.pdf"`.
2. Read `$TMPDIR/cv.pdf` with the PDF-capable Read tool.

## Usage notes

- Fetch only the link you need. Do not paste a full publication list onto a slide.
- Every use needs a network fetch. If a fetch fails or you are offline, say so. Do not invent a fact.
- For an author line, fetch the webpage for the current affiliation. Do not hardcode it here.
