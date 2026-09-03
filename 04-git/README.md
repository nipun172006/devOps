# My Git and GitHub Homework

I used a small local repository to practice staging, commits, branches, logs, and cherry-pick.

## git commit -m

I first tried committing a new file without staging it. Git did not include the file because it was still untracked.

![Commit without staging](evidence/commit-m.png)

## git commit -a -m

I changed a tracked file and created another untracked file. `git commit -a -m` committed the tracked change but left the new file untracked.

![Commit using the a option](evidence/commit-a.png)

I learned that `-a` automatically stages modified and deleted tracked files, but it does not add new files.

## Cherry-pick

I created a feature branch and made three commits.

![Feature branch commits](evidence/branch-commits.png)

I switched back to `main` and cherry-picked only the second feature commit.

![Cherry-pick result](evidence/cherry-pick.png)

Cherry-pick copied one selected change onto `main` without merging every commit from the feature branch.

My full command output and explanation are in [git-notes.md](git-notes.md).
