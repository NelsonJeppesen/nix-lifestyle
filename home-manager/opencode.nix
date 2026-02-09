# opencode.nix - OpenCode AI coding assistant configuration
#
# OpenCode is a terminal-based AI coding assistant (similar to Cursor/Aider).
# This module configures:
# - Default model: Claude Opus 4.6 via GitHub Copilot
# - MCP server integration (GitHub, Terraform, Kubernetes)
# - Web UI for browser-based interaction
# - Shell aliases for quick access (o, oc, or, etc.)
# - Custom slash commands for shell history analysis and Terraform workflows
# - Specialized agents for Terraform/DevOps and code review
{ pkgs, ... }:
{
  # Shell aliases for quick OpenCode invocation
  programs.zsh.shellAliases = {
    o = "opencode"; # Launch OpenCode
    oc = "opencode --continue"; # Continue previous conversation
    or = "opencode run"; # Run a command through OpenCode

    # Pre-built workflows
    osd = "opencode run '/summary daily'"; # Daily shell history summary
    osw = "opencode run '/summary weekly'"; # Weekly shell history summary
    ocm = "opencode run 'create commit and push'"; # AI-assisted commit and push
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true; # Connect to MCP servers defined in mcp.nix
    web.enable = true; # Enable browser-based web UI

    settings = {
      # Use Claude Opus 4.6 via GitHub Copilot as the default model
      model = "github-copilot/claude-opus-4.6";
    };

    # ── Custom slash commands ─────────────────────────────────────
    # These are invoked as /command-name in the OpenCode chat
    commands = {
      # /changelog: update CHANGELOG.md with new entries
      changelog = ''
        # Update Changelog Command
        Update CHANGELOG.md with new entries.
      '';

      # /summary: analyze shell history from Atuin and generate activity summary
      # Supports daily/weekly/monthly/custom time ranges
      summary = ''
        # Shell History Summary Command
        Analyze the user's Atuin shell history and generate a summary of activities.

        ## Usage:
        - `/summary` or `/summary day` - Last 24 hours (daily summary)
        - `/summary week` - Last 7 days (weekly summary)
        - `/summary month` - Last 30 days (monthly summary)
        - `/summary <N>d` - Last N days (e.g., `/summary 3d` for last 3 days)

        ## Instructions:
        1. Parse the argument to determine the time period:
           - No argument or "day"  24 hours (limit 2000)
           - "week"  7 days (limit 5000)
           - "month"  30 days (limit 10000)
           - "<N>d"  N days (adjust limit appropriately: ~300*N commands)

        2. Query Atuin history using: `atuin search --limit <LIMIT> --format "{time}\t{command}" --filter-mode global --after "<PERIOD>"`

        3. Parse and analyze the command history to identify meaningful work (filter out noise like cd, ls, clear, history)

        4. Generate a **concise summary limited to 30 lines maximum** organized by:
           - Projects/repositories worked on
           - Infrastructure/DevOps activities (Terraform, AWS, K8s, etc.)
           - Development tasks
           - System administration tasks

        ## Output Format:
        Provide a markdown summary with:
        - Date range covered
        - Main projects/activities (bullet points)
        - Key accomplishments or infrastructure changes
        - **Maximum 30 lines total**

        Adjust detail level based on time period:
        - Daily: Very concise, focused on today's work
        - Weekly: Summarized patterns and major accomplishments
        - Monthly: High-level overview with key themes
      '';

      # /tf-scope: analyze current directory as a Terraform scope and describe it
      tf-scope = ''
        # Terraform Scope Helper
        Analyze the current working directory as part of a Terraform monorepo and describe the Terraform "scope" for the user.

        ## Goals
        - Infer whether this directory is a root stack, environment folder, or shared module.
        - Identify likely environment / workspace names (for example: dev, stage, prod).
        - List key Terraform entrypoint files and any .tfvars or backend configs.
        - Suggest the Terraform commands typically run from this directory.

        ## Instructions
        1. Inspect the current directory path (for example: envs/prod, live/stage/app, modules/networking).
        2. Look for Terraform entrypoints such as: main.tf, backend.tf, provider.tf, variables.tf, outputs.tf, and *.tfvars.
        3. Based on naming and layout, classify the scope as one of:
           - environment stack (per-environment root)
           - shared module
           - global/root stack
        4. Output a short, human-readable summary including:
           - Scope classification and any inferred environment / workspace.
           - Important files and directories discovered.
           - Recommended Terraform commands to run from here (init, plan, apply), without actually executing anything.
        5. Keep the output concise and focused on the next actions for the user.
      '';

      # /tf-plan-helper: construct the correct terraform plan command for this directory
      tf-plan-helper = ''
        # Terraform Plan Helper
        Help the user construct the correct Terraform plan command for this directory in a Terraform monorepo.

        ## Goals
        - Infer reasonable defaults for backend, workspace, and var-files based on the current directory.
        - Accept optional arguments such as environment name or extra plan flags.
        - Output a single, copy-pasteable terraform plan command.

        ## Instructions
        1. Interpret the command arguments, if any, as hints for environment or workspace (for example: prod, staging, dev) and extra flags.
        2. Analyze the current directory for conventions such as:
           - envs/<env>/, live/<env>/, or similar environment folders.
           - presence of *.tfvars files that match the environment name.
           - Makefiles, taskfiles, or scripts that show how terraform is usually invoked.
        3. Propose a terraform plan command, including when appropriate:
           - `terraform init` if it appears the directory has not been initialized.
           - `terraform workspace select` or TF_WORKSPACE if multiple workspaces are implied.
           - `-var-file` and `-backend-config` options for the environment, if discoverable.
        4. Do not actually run terraform. Only print commands and brief explanations of each step.
        5. Always keep safety in mind and explicitly prefer plan over apply, especially for production-like environments.
      '';

      # /tf-impact-summary: summarize a terraform plan JSON for change review
      tf-impact-summary = ''
        # Terraform Plan Impact Summary
        Summarize the impact of a Terraform plan, focusing on resource changes and risk.

        ## Input
        - Either a path to a file containing `terraform show -json` output, or
        - Raw JSON from `terraform show -json` provided via stdin.

        ## Goals
        - Group changes by provider, service, and action (create, update, replace, destroy).
        - Highlight destructive or high-risk changes such as deletes, replaces, and IAM/policy modifications.
        - Provide a short, human-readable summary suitable for change review.

        ## Instructions
        1. Detect whether the argument looks like a file path; if so, read JSON from that file. Otherwise, expect JSON on stdin.
        2. Parse the plan JSON and aggregate changes by:
           - action (create, update, replace, destroy)
           - resource type (for example: aws_instance, aws_db_instance, aws_security_group_rule, kubernetes_*).
        3. Highlight high-risk changes, including:
           - replacements or destroys of stateful resources (for example: databases, load balancers, storage buckets).
           - changes to IAM policies, security groups, or firewall rules.
        4. Produce a concise markdown summary that includes:
           - total counts of create / update / replace / destroy operations.
           - bullet points grouped by provider/service with resource examples.
           - any noteworthy risks or things to double-check before apply.
        5. Do not claim that resources have already been changed; this command is strictly about plan impact, not apply status.
      '';
    };

    # ── Specialized agents ────────────────────────────────────────
    # Agents are persona-based modes that OpenCode can switch between
    agents = {
      # Terraform/DevOps agent: infrastructure-focused analysis and guidance
      terraform-devops = ''
        # Terraform DevOps Agent
        Specialized assistant for Terraform monorepos and DevOps workflows.

        ## Focus
        - Understands common Terraform monorepo layouts: envs/<env>/, live/<env>/, modules/*, and shared/global stacks.
        - Helps design and refactor modules, inputs/outputs, and state layout.
        - Suggests safe CI/CD patterns for terraform plan and apply.

        ## Safety and Behavior
        - Prefer read-only analysis: planning, impact summaries, refactors, and documentation.
        - Never automatically run terraform commands; only propose them for the user to execute.
        - Treat production-like environments as high risk: always recommend plan + review + approval before any apply.
        - Avoid suggestions that involve editing or manipulating remote state directly; instead, use drift detection and standard plan/apply flows.

        ## Typical Tasks
        - Explain or map the current Terraform directory structure and state layout.
        - Propose improvements to module boundaries and variable/outputs design.
        - Draft CI workflows or runbooks for terraform plan/apply and drift detection.
        - Recommend tagging and naming standards across resources.
      '';

      # Code review agent: general-purpose code review assistant
      code-reviewer = ''
        # Code Reviewer Agent
        Specialized code review assistant.
      '';
    };
  };
}
