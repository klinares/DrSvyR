---
id: "jpsm/fund_comp_data_display_SURV727/lectures/01-02-Github"
source: "jpsm"
course: "SURV727"
course_title: "Fundamentals of Computing and Data Display"
doc_type: "lecture"
title: "Git and GitHub"
original: "fund_comp_data_display_SURV727/lectures/01-02-Github.pdf"
pages: 17
sha256: "9219b523c1fea29b6d53c1a8d53a1265535abdece668fa471adb947812e8c074"
converted_by: "google/gemini-4-argon"
converted_at: "2026-11-14T21:00:54"
---

<!-- page 1 -->

# Git and GitHub
## Fundamentals of Computing and Data Display

Brian Kim

[email]

<!-- page 2 -->

# Motivation

**Reproducibility** is a key part of **how science is conducted**, and thus it is also a key part of how **data science is conducted**.

**Collaboration** is a key part of success in interdisciplinary fields. **Data Science** is by its nature a highly interdisciplinary field.

Fundamentals of Computing and Data Display  
Git and GitHub

<!-- page 3 -->

# Git and GitHub

Organizing coding projects

* Data/ coding projects often involve many iterations
* Organizing versions particularly difficult in collaborative projects
* Manual versioning (final_paper_version_x.doc) can become cumbersome

$\rightarrow$ Version control management systems!

* Keep track of changes (**who** changed **what** code **when**?)
* Most recent version visible, previous versions can be restored
* Work best with text files (e.g. .txt, .R, .md, .tex)

---

Fundamentals of Computing and Data Display | Git and GitHub | 3 / 16

<!-- page 4 -->

# Git and GitHub

Organizing coding projects

* Data/ coding projects often involve many iterations
* Organizing versions particularly difficult in collaborative projects
* Manual versioning (final_paper_version_x.doc) can become cumbersome

$\rightarrow$ Version control management systems!

* Keep track of changes (**who** changed **what** code **when**?)
* Most recent version visible, previous versions can be restored
* Work best with text files (e.g. .txt, .R, .md, .tex)

---
Fundamentals of Computing and Data Display | Git and GitHub | 3 / 16

<!-- page 5 -->

# Git and GitHub

(Why) Git and GitHub?

* Git is a version control management system
  * `https://git-scm.com/`
  * (Most) popular software for organizing coding projects
  * Other VCSs available, e.g. Subversion (SVN)

* GitHub is a **remote host** for **local** Git repositories
  * Widely used provider for sharing and storing Git projects online
  * Can also be used as a file hoster without Git
  * GitHub alternative; GitLab

Fundamentals of Computing and Data Display | Git and GitHub | 4 / 16

<!-- page 6 -->

# Git

Working with Git
- Command line
- Graphical User Interface (GUI)
  - Git GUI
  - `https://git-scm.com/downloads/guis`
  - `https://desktop.github.com/`
  - **RStudio**

Git configuration
- First-Time Git Setup
  - `git config --global user.name "Your name"`
  - `git config --global user.email [email]`
  - `git config --global core.editor editor_name`

<!-- page 7 -->

Git

# Git init

Initialize a Git repository

* Create a new (local) project
  * `git init`
* Create a new (local) R project
  * Initialize Git within an RStudio project
* Clone an existing remote project
  * `git clone`

Fundamentals of Computing and Data Display | Git and GitHub | 6 / 16

<!-- page 8 -->

Git

# Git workflow

Figure: Git workflow$^1$

add
commit
push
Working Directory
Staging (index)
Local Repository
Remote Repository
reset
fetch
reset [commit]
pull

---

$^1$`https://zeroturnaround.com/rebellabs/git-commands-and-best-practices-cheat-sheet/`

Fundamentals of Computing and Data Display
Git and GitHub

<!-- page 9 -->

Git

# Example

```
> cd my_working_directory
> git init
# create some_file.R
# hack, do some work, hack
# hack
> git status # check current state of repository
> git add some_file.R
> git commit -m "Initial commit"
# hack
# more hacking
> git diff # show differences between file version
> git commit -am "Add important code"
> git log # list of previous commits
```

Fundamentals of Computing and Data Display

Git and GitHub

<!-- page 10 -->

Git

# Git concepts

Branches

* A branch is a set of code changes that are kept separate
* Default branch created by `git init`: `main`
* Pointer to current branch: `HEAD`

`.gitignore`

* A file that tells Git which types of (e.g. temporary) files to ignore

Remotes

* A remote is an external repository to sync with
* Set up by `git clone` or `git remote add`
* Default remote name: `origin`

Fundamentals of Computing and Data Display | Git and GitHub | 9 / 16

<!-- page 11 -->

# GitHub

Add a Git project to GitHub

1. Create a new clean repository via the GitHub web interface
2. Copy the resulting remote repository URL
   * `https://github.com/user_name/repo_name.git`
3. Add remote repo to Git project; `git remote add`
4. Interact with remote repo with `git push` and `git pull`

**Notes!**

* Public repositories are visible to everyone (open read access)
* Never push sensitive information (e.g. passwords) to a remote repository!

<!-- page 12 -->

GitHub

# Example continued

```
> git remote add origin url
> git remote -v # list remote repositories
> git push origin main # push changes to GitHub
# sleep
> git pull origin main # update local repository
# hack, hack, hack, make some changes
> git commit -am "Some changes again"
> git push # push to GitHub
```

Fundamentals of Computing and Data Display  
Git and GitHub

<!-- page 13 -->

GitHub

# Branching

Git allows to play around with new/ experimental code via branches

1. Create a new branch “experimental” and switch to it: `git checkout -b experimental`
   1. `git branch experimental`
   2. `git checkout experimental`
2. Add and commit changes in new branch
   * ...until new branch is ready to be merged...
3. Switch back to main branch: `git checkout main`
4. Merge (no longer) experimental branch into main: `git merge experimental`
   * Resolve merge conflicts

Fundamentals of Computing and Data Display | Git and GitHub | 12 / 16

<!-- page 14 -->

git, GitHub and RStudio

# git, GitHub and RStudio

Connect RStudio and git

* Initialize new git repository
  1. Create a new RStudio project
  2. Project options > Git/SVN panel > “Version control system” from “None” to “Git”
* Clone existing remote repository
  1. Create Project > Version Control > Git
  2. Copy&paste repo URL from GitHub
* `http://r-pkgs.had.co.nz/git.html`

Fundamentals of Computing and Data Display  
Git and GitHub

<!-- page 15 -->

git, GitHub and RStudio

# git, GitHub and RStudio

The git pane

* Diff: Opens the commit window (to review differences)
* Commit: Opens the commit window (to commit changes)
* Pull: Pull changes from remote repo
* Push: Push changes to remote repo
* Files
  * M Modified: Contents of the file have changed
  * ? Untracked: A new file that Git hasn't seen before
  * D Deleted: File has been deleted
  * Tick checkbox to stage/add a file

Fundamentals of Computing and Data Display | Git and GitHub | 14 / 16

<!-- page 16 -->

git, GitHub and RStudio

# git, GitHub and RStudio

Figure: The commit window

Fundamentals of Computing and Data Display

Git and GitHub

<!-- page 17 -->

# Resources

- Pro Git book
  - `https://git-scm.com/book/en/v2`
- Cheatsheet
  - `https://services.github.com/on-demand/downloads/github-git-cheat-sheet.pdf`
- Resource collection
  - `https://try.github.io/`
- Git and GitHub
  - `https://help.github.com/articles/git-and-github-learning-resources/`
- Git and R, RStudio
  - `http://happygitwithr.com`
  - Gandrud, C. (2015). Reproducible Research with R and R Studio. New York: Chapman and Hall/CRC.
