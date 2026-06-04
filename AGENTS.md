# AGENTS.md

## Purpose

This repository is for the Ubuntu Server Advanced documentation site.

`ubuntu_advanced_lab.md` is the source reference. Keep it unchanged.

## Source Of Truth

- Treat `ubuntu_advanced_lab.md` as read-only.
- Preserve the technical meaning of the source material.
- Improve wording, structure, and consistency in derived site content where useful.
- Keep the tone professional and minimal.

## Site Structure

- Split the content into one file per top-level chapter only.
- Include all 11 top-level chapters from the reference file.
- Do not create separate files for subsections unless explicitly requested.
- Chapter 11 is included in scope.
- Keep `migration.md` at the repository root as the internal migration tracker.
- Keep `playground.md` at the repository root as the internal lab machine inventory.
- Keep `commands.md` at the repository root as the internal record of successfully executed training commands.

## Writing Rules

- Keep explanations concise.
- Do not over-explain unless explicitly asked.
- Prefer direct, task-focused wording.
- Normalize inconsistent formatting from the source.
- Keep command examples close to the original intent, but rewrite for clarity when needed.

## Command Formatting

- Add a short comment immediately above each command block.
- Use one command block per command.
- Do not group multiple commands under one shared comment or one shared expected-result block.
- Each command must be followed by an admonition in this form:

```md
??? example "Expected result"
    Expected output or verification notes.
```

- Commands and expected results must remain in pairs.
- Each command must have its own paired expected-result admonition.
- Use expected results to show the actual command output or a close representative example of what the output looks like.
- Prefer concrete output over description or interpretation.
- If a command produces no output, use a placeholder such as `No output.`
- If exact output may vary, keep the example realistic and focus on the visible success signals in the command output.

## Lab Flow

- Default to an interactive workflow only when the user explicitly asks for an interactive session during live training.
- Present one lab step at a time when running the lab with the user.
- Before every lab command in an interactive session, state the exact command you recommend next and explain its intent in one short sentence.
- Show the student-facing command exactly as the student should see and run it, even if the actual executed command uses SSH wrappers or other environment-specific prefixes.
- Do not skip the intent explanation, even for obvious or repetitive commands.
- In an interactive session, run one command at a time only.
- In an interactive session, wait for explicit user approval before running each command.
- In an interactive session, after the user runs a command that completes without further input, double-check the result before moving on.
- In an interactive session, do not update `commands.md`; the live session already covers the command flow and duplicating it adds no value.
- In an interactive session, after each command, report the result and explain what it means before moving on.
- In an interactive session, if the user says `go`, treat that as approval to proceed with the recommended next step.

## Editing Rules

- Prefer the smallest correct change.
- Keep existing deployment artifacts such as `helm/` and `Dockerfile` unless explicitly asked to change them.
- Do not remove source material that belongs to the training.
- Do not run `mkdocs build` or otherwise attempt to build the MkDocs site unless the user explicitly asks for it.

## Tracking Files

- Update `migration.md` when a chapter or subchapter is migrated.
- Track subchapters in `migration.md`, not just top-level chapters.
- Mark a chapter as `Complete` only after all commands in that chapter have been run and their results have been documented.
- Update `playground.md` whenever a lab machine is added, changed, or reassigned.
- Use `playground.md` for internal execution context only; it is not part of the training content.
- Update `commands.md` only outside live interactive training sessions.
- Record only commands from the training material that actually succeeded.
- Record the exact command string that was actually executed successfully, including any required SSH wrappers or environment-specific prefixes.
- Do not replace the executed command with a simplified or student-facing form in `commands.md`.
- Do not record failed commands, exploratory commands, or commands that were corrected before a successful run.

## Agent Routing

### Required Routing Rules

- For discovery tasks, the main agent must delegate the first pass to `explore`.
- For analysis tasks, the main agent must gather evidence with `explore` first and then delegate reasoning to `general`.
- For active-change tasks, the main agent may perform direct local edits and narrowly scoped supporting reads, but must not do broad discovery directly when `explore` fits the task.
- Direct main-agent inspection is allowed only for narrow follow-up reads tied to a known file/path, an edit already in progress, or a verification step.

### Agent Roles and Selection

- **Read-Only Tasks (`explore`):** Use the `explore` agent for discovery work: searching the repository, reading files, inspecting documentation, understanding existing patterns, summarizing findings, and running read-only commands. This includes exploratory diagnostics against remote machines, Kubernetes clusters, or other environments when the intent is observation rather than change.
- **Active Tasks (`general`):** Use the `general` agent for actions that interact with systems in a non-read-only way, execute commands with side effects, or perform external operations with side effects. The main agent may still perform direct local file edits and narrowly scoped supporting reads as allowed by the routing rules above.
- **Keep Context Small:** Use the smallest relevant files, snippets, or command outputs needed to answer the question. Avoid loading large files or broad documentation into the main context unless necessary.

### Delegation Rules

- Do not ask sub-agents to guess missing targets, credentials, command syntax, deployment details, or environment assumptions.
- When delegating, provide the exact target, task objective, known constraints, commands or files involved, safety limits, and expected behavior.
- Ask sub-agents to return concise factual results: what was inspected or changed, commands run, files touched, important output, errors, and current state.
- Delegate the smallest safe unit of work. Avoid broad or open-ended instructions when a precise task can be given.
- When tasks are independent and do not rely on each other, prefer parallel delegation. Keep dependent work sequential.

### Main-Agent Restrictions

- The main agent must not perform active external-system work directly when `general` is the appropriate isolation boundary.
- The main agent remains responsible for orchestration, deciding whether evidence is sufficient, choosing follow-up actions, and producing the final user-facing answer.

### Execution and Safety

- **Targeted Searches:** When checking syntax, behavior, or implementation details, search for specific symbols, filenames, commands, or keywords instead of reading entire large references.
- **Bounded Recovery:** If a delegated command or operation fails because of syntax, quoting, missing tools, minor environment mismatch, or a similar manageable issue, the sub-agent may make a small number of reasonable corrective attempts when the next step is clear and low risk. Do not drift into open-ended trial and error.
- **Stop on Unclear or Risky Errors:** If the failure suggests permissions issues, unexpected state, unclear prompts, target ambiguity, or a risk of side effects, stop and report the exact failure instead of guessing.
- **Handle Failures Safely:** Return the attempted command or action, the exact error, any corrective attempts made, relevant output, and the observed state. The main agent should review the failure before deciding the next step.
- **Avoid Hidden Assumptions:** Do not infer environment-specific details unless they are documented or already verified.
- **Protect Secrets:** Never print, log, echo, or expose secret values. Prefer non-interactive secret handling where possible, and avoid prompts that may reveal sensitive data.
- **Fail Fast on Repeated Errors:** If the same operation keeps failing after a small number of reasonable corrective attempts, stop for that target and return the facts. Do not continue experimenting without a corrected instruction.
- **Main-Agent Orchestration:** The main agent is responsible for reviewing results, deciding follow-up actions, and delegating corrected tasks when needed.

### Git Workflow

- In this repository, a user request to `git commit` counts as an explicit request for the full repository git workflow.
- Delegate the full git workflow to the `general` subagent.
- Use a single short commit message only, no longer than 80 characters.
- Do not add a commit body unless the user explicitly asks for one.
- Follow this sequence:
  1. `git add ...`
  2. `git commit -m "..."`
  3. `git pull --rebase`
  4. `git push`
- Do not stop after creating a local commit unless the user explicitly asks for a local-only commit.
- Do not run this workflow unless the user explicitly asks for `git commit` or otherwise clearly requests a commit.

## Post-Task Updates

- **Verify Results:** After active work completes, verify that the observed result matches the intended change.
- **Minimal Sub-Agent Verification:** Ask sub-agents to perform minimal verification appropriate to the task before returning. Examples include checking the relevant diff, running the smallest relevant test, confirming command success, or validating the observed runtime state.
- **Update Records:** If the task changes behavior, configuration, architecture, commands, or operational knowledge, update the relevant workspace documentation to reflect the new reality.
- **Keep Documentation Accurate:** Do not leave stale assumptions in project notes, runbooks, or configuration references after completing changes.
