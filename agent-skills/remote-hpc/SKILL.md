---
name: remote-hpc
description: Launch and monitor research experiments on a remote HPC cluster over ssh and rsync. Use when the user wants to run a job on a cluster (hpc, juwels), submit an sbatch job, sync code to a cluster, or pull results back. Covers SLURM submission, code sync, monitoring, and result retrieval.
---

# Remote HPC experiments

Run experiments on a remote SLURM cluster. Sync code up, submit a batch job,
monitor it, and pull results back.

## Prefer local first

Run on the local machine when it fits. Escalate to a cluster only for GPU work,
long runs, or jobs that exceed local memory. State why the cluster is needed.

## Before you start

1. Read the cluster sheet in `clusters/<name>.md`. It holds the login alias,
   partitions, GPU types, limits, account, and the scratch path. Never guess
   these values.
2. Confirm the ssh host alias works: `ssh <alias> true`. The alias lives in
   `~/.ssh/config`. Do not put hostnames, users, or keys in project files.
3. Read the project binding in the project's `CLAUDE.md`. It names the cluster,
   the remote project path, the environment, and the partition for this project.
   If the binding is missing, ask for it. Do not invent a remote path.

## The loop

### 1. Sync code up

Use rsync over the ssh alias. Send code only. Exclude data, environments, and git.

```bash
rsync -avz --delete \
  --exclude '.git/' --exclude '.venv/' --exclude '__pycache__/' \
  --exclude 'data/' --exclude 'figures/' --exclude 'logs/' \
  ./ <alias>:<remote_project_path>/
```

Rules:
- Confirm `<remote_project_path>` before the first push. A wrong path with
  `--delete` erases the wrong directory.
- Never sync secrets. Keep `.env`, tokens, and keys out of the transfer.
- Large input data goes to scratch by a separate, explicit transfer, not this sync.

### 2. Prepare the environment

Run setup on the login node. This is light work, so it is allowed there.

```bash
ssh <alias> 'cd <remote_project_path> && uv sync'
```

### 3. Submit the job

Write an sbatch script that requests the partition, GPUs, and walltime from the
cluster sheet. Submit it. Never run the experiment directly on the login node.

```bash
ssh <alias> 'cd <remote_project_path> && sbatch run.sbatch'
```

Capture the job id from the output. `sbatch` returns at once; the job then waits
in the queue.

### 4. Monitor

Watching a running job is a long job. Follow the global long-jobs rule: run the
watch in a herdr split, not the foreground, and print the log path.

```bash
ssh <alias> 'squeue --me'            # queue and run state
ssh <alias> 'sacct -j <jobid> --format=JobID,State,Elapsed,MaxRSS'
ssh <alias> 'tail -f <remote_project_path>/logs/<jobid>.out'
```

### 5. Pull results back

Sync results down when the job finishes. Pull outputs only, not the whole tree.

```bash
rsync -avz \
  <alias>:<remote_project_path>/figures/ ./figures/
rsync -avz \
  <alias>:<remote_project_path>/logs/ ./logs/
```

## Safety checklist

- Never run heavy compute on a login node. Always `sbatch` to a compute partition.
- Confirm the remote path before any `rsync --delete`.
- Respect the walltime, quota, and account in the cluster sheet.
- Print the job id and the log path when you submit.
- Read the cluster sheet again if a submission is rejected. The account or
  partition name is the usual cause.
