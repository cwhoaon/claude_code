---
name: dl-plan-implement
description: >
  Use this skill whenever the user asks to implement a deep learning experiment, research idea,
  or model modification — especially when they say things like "just implement this", "implement
  this experiment", "build this for me", "code this up", or describes a DL idea and wants working
  code without manually going through planning first. This skill runs the planner agent, shows the
  plan to the user for approval, then feeds the confirmed plan into the implementer agent. If the
  user requests changes to the plan, it re-plans with their feedback before implementing. Trigger
  this whenever the intent is to go from a research description or idea all the way to runnable
  PyTorch code in one shot.
---

# DL Plan + Implement

This skill orchestrates two specialized agents in sequence: first producing a structured
implementation plan, getting the user's explicit sign-off, then writing the code. The confirmation
gate is intentional — it ensures the user agrees with the approach before any files are changed.

## Workflow

### Step 1: Gather the experiment description«

Extract the full experiment description from the current conversation — the user's idea, notes,
pasted text, or open file context. If the description seems incomplete in a way that would block
planning, ask one focused clarifying question before proceeding. For minor ambiguities, proceed
and let the planner flag them as explicit assumptions.

### Step 2: Run the planner agent

Spawn the `dl-research-planner` agent with a prompt that includes:
- The full experiment description exactly as the user provided it
- The current working directory and any relevant file context (open files, codebase structure)
- Any prior feedback from the user if this is a re-plan (see Step 4)

Example prompt structure:
```
The user wants to implement the following deep learning experiment:

<experiment_description>
[paste the user's full description here]
</experiment_description>

Current working directory: [cwd]
[any relevant open file contents or codebase notes]

[If re-planning, add:]
<user_feedback>
[paste the user's requested changes or concerns here]
</user_feedback>

Produce a complete, unambiguous implementation plan following your standard format.
State all assumptions explicitly rather than asking — the user wants to move fast.
```

Wait for the planner to return a complete plan before continuing.

### Step 3: Present the plan and ask for confirmation

Show the plan to the user clearly. Then ask:

> "Does this plan look right? Reply **yes** to implement, or describe any changes you'd like."

Wait for the user's response before doing anything else.

### Step 4: Handle the user's response

**If the user confirms (yes / looks good / go ahead):**
→ Proceed to Step 5.

**If the user requests changes or raises concerns:**
→ Acknowledge their feedback briefly, then go back to Step 2 with the original description
  **plus** the user's feedback included as `<user_feedback>`. Re-run the planner and repeat
  from Step 3. Keep iterating until the user confirms.

**If the user says stop / cancel:**
→ Abort gracefully and let the user know they can restart anytime.

### Step 5: Run the implementer agent

Spawn the `dl-research-implementer` agent with the confirmed plan:

```
Implement the following deep learning experiment plan in the current codebase.

<implementation_plan>
[paste the full confirmed plan output from the planner here]
</implementation_plan>

Working directory: [cwd]
[any relevant open file contents]

Implement exactly what the plan specifies. Present all file modifications in full when done.
```

### Step 6: Summarize to the user

After the implementer finishes, give a brief summary:
- What files were created or modified
- Any assumptions the planner flagged that the user should verify
- Any next steps (e.g., run training, check a config)

Keep it concise — the implementer already shows the full code diffs.

## Notes

- The confirmation gate (Step 3) is the core value of this skill. Never skip it, even if the
  plan looks obviously correct — the user needs the chance to catch misalignments before
  files change.
- Pass the full codebase context (open files, working directory) to both agents so they share
  the same picture of the project.
- If the planner returns clarifying questions it truly cannot resolve, surface those to the
  user before presenting the plan for confirmation.
