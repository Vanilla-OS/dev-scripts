# Vanilla OS Dev Scripts

- `extract_project_translations.sh PROJECT_ROOT`: Lists all the translation strings inside a Go project by passing the project's root as argument.
- `pkg_check_modules_size.sh MODULES_DIR_PATH`: Checks the size of a list of packages defined in one or more yaml files.
- `pkg_check_size.sh PACKAGE_1 [PACKAGE_2 ...]`: Checks the size of a list of packages.

## Use of Generative AI

Maintainers may use generative AI tools as assistants while working on dev-scripts. Non-trivial assisted commits disclose the tool, model, and scope of the work.

AI tools may assist with code comments, documentation, repetitive code, and issue triage. Maintainers make project decisions and review every assisted change before it is merged.

Use these trailers for non-trivial assisted commits:

```plain
Assisted-by: <tool>:<model-version>
AI-Scope: <what the tool generated and the prompt or a short prompt summary>
```

Single-line completions, renames, and formatting changes do not need trailers.

Coding agents must also follow [AGENTS.md](AGENTS.md) before changing files,
creating commits, or opening pull requests.
