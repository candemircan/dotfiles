---
name: bio
description: "Canonical links to one person's scientific identity (webpage, Google Scholar, ORCID, GitHub, CV), plus a place to keep project-local notes about them. Defaults to Can Demircan; the identity block is editable. Load this when a task needs the person's author details or bio: a presentation title slide or author block, a talk or workshop bio, a paper author line, a grant or application blurb, a personal webpage edit, or any 'about the user' text. This skill holds no derived facts. Fetch the relevant link to read the current affiliation, title, bio, or publications."
---

# Bio

This skill holds one person's canonical identity links and a place to keep project-local notes about
them. It carries no derived facts (affiliation, title, publication list), because those go stale.
When a task needs a fact, fetch the link that owns it.

## Identity (editable defaults)

These default to Can Demircan. To reuse this skill for another person, edit this block. A project can
override any value in its notes file (see below), and the project value wins.

| Field | Value | Owns |
|---|---|---|
| Name | Can Demircan | The author name |
| Webpage | https://candemircan.github.io | Bio, affiliation, title, research interests, all social links |
| Scholar | https://scholar.google.com/citations?user=Hu7VKscAAAAJ&hl=en | Publication list, citation counts |
| CV | https://candemircan.github.io/cv/Demircan_cv.pdf | Education, awards, experience, full publication list |
| ORCID | https://orcid.org/0000-0001-6069-1761 | Stable author ID |
| GitHub | https://github.com/candemircan | Code and repositories |

## Project notes and artifacts

When you use this skill in a project, keep notes about the person in that project's context. Store
them where git does not track them. Steps:

1. Create `.bio/` in the project root.
2. Make git ignore it. Append `.bio/` to `.git/info/exclude` if that line is not already there. Do
   not edit the tracked `.gitignore`. If the project is not a git repo, skip this step.
3. Read `.bio/notes.md` first on every use. It may override the identity defaults above.
4. Write project-specific facts to `.bio/notes.md`. Examples: the person's role on this project, how
   they want to be credited, any field override, anything reusable across sessions.
5. Keep artifacts in `.bio/` too. Example: download the CV to `.bio/cv.pdf` and reuse it.

Update `.bio/notes.md` as you learn new project-specific facts. Do not put derived identity facts
there (affiliation, title, publications); fetch those from the links.

## Fetch map

- **Need a bio, affiliation, title, or research interests?** Fetch the webpage.
- **Need the publication list or citation counts?** Fetch Google Scholar.
- **Need education, awards, or the complete publication list?** Read the CV.
- **Need a stable author identifier?** Use the ORCID link as-is.

## How to read the CV

The CV is a binary PDF. A text web fetch cannot parse it. To read it:

1. Download it. In a project, save to `.bio/cv.pdf`:
   `curl -sL <CV url> -o .bio/cv.pdf`. Outside a project, use `$TMPDIR/cv.pdf`.
2. Read the saved file with the PDF-capable Read tool.

## Usage notes

- Fetch only the link you need. Do not paste a full publication list onto a slide.
- Every fact needs a network fetch. If a fetch fails or you are offline, say so. Do not invent a fact.
- For an author line, fetch the webpage for the current affiliation. Do not hardcode it here.
