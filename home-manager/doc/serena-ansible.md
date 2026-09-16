# Serena With Ansible

Serena gives OpenCode symbol-aware retrieval and editing backed by the Ansible
language server. It complements OpenCode's ordinary file tools; it does not
replace `ansible-lint`, syntax checks, or Molecule tests.

## First Use

1. Rebuild Home Manager, then fully quit and restart OpenCode so it loads the
   new `serena` MCP server.
2. Change to the root of an Ansible repository. An `ansible.cfg` or
   `.ansible-lint` file helps both Neovim and the language server identify the
   project.
3. Create the Serena project explicitly:

   ```bash
   serena project create --language ansible .
   ```

4. Review `.serena/project.yml`. A typical starting point is:

   ```yaml
   language_servers:
     - ansible
   ignore_all_files_in_gitignore: true
   ignored_paths:
     - .cache/**
     - .molecule/**
   read_only: false
   ```

5. Optionally pre-cache symbols in a large repository:

   ```bash
   serena project index
   ```

   This is not required. Serena updates its cache as files change.

## OpenCode Prompts

Ask for Serena explicitly when symbol relationships matter:

```text
Use Serena to get a symbol overview of roles/web/tasks/main.yml, then trace the
handler and variable references involved in restarting nginx. Do not edit yet.
```

```text
Use Serena's symbol and reference tools to find every role affected by renaming
web_service_port. Make the smallest safe edit, then run ansible-lint.
```

```text
Use Serena to inspect this collection's role structure and identify duplicated
task blocks. Propose a refactor before editing.
```

For a small one-file change, OpenCode's normal read, grep, and patch tools are
usually faster. Serena is most useful for repository exploration, reference
lookup, and changes spanning roles, handlers, defaults, vars, and plugins.

## Verification

Run checks from the repository root after edits:

```bash
ansible-lint
ansible-playbook --syntax-check playbook.yml
molecule test
```

Use `ansible-navigator run playbook.yml` when you want an interactive TUI and
`ansible-builder build` when the project defines an execution environment.
