![Maintainer](https://img.shields.io/badge/Maintained%20By-cloudfy9-brightgreen) [![GitHub Workflow To Create Release](https://github.com/cfy9/shellcheck-action/actions/workflows/release.yaml/badge.svg)](https://github.com/cfy9/shellcheck-action/actions/workflows/release.yaml)

# Introduction

This GitHub action is used to perform the linting of shell scripts for best practices.

## Example

```yaml
name: GitHub Workflow
on:
  push:
    branches:
      - main
jobs:
  shellcheck:
    name: Shellcheck
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Run ShellCheck
      uses: cfy9/shellcheck-action@main
```

## ShellCheck options

Additionally you can pass supported ShellCheck option or flags with the `SHELLCHECK_OPTS` env key in the job definition.

For Example:

* To disable specific checks: `-e SC2059 -e SC2034`

example:

```yaml
    ...
    - name: Run ShellCheck
      uses: cfy9/shellcheck-action@main
      with:
        SHELLCHECK_OPTS: -e SC2059 -e SC2034
```

## Ignore paths and names

You can use the `ignore_paths` and `ignore_names` input to disable specific directories and files.

For Example:

```yaml
    ...
    - name: Run ShellCheck
      uses: cfy9/shellcheck-action@main
      with:
        ignore_paths: ignore_xxxxx
        ignore_names: ignore_xxxxx.sh
```

## Minimum severity of errors to consider (error, warning, info, style)

You can use the `severity` input to define the severity. Default value is 'error'.

example:

```yaml
    ...
    - name: Run ShellCheck
      uses: cfy9/shellcheck-action@main
      with:
        severity: error
```

## Run shellcheck only in a single directory

If you have multiple directories with scripts, but only want to scan one of them, you can use the following configuration:

```yaml
   ...
   - name: Run ShellCheck
     uses: cfy9/shellcheck-action@main
     with:
       scandir: './scripts'
```

## Change output format

Shellcheck can print output in these formats: `checkstyle`, `diff`, `gcc`, `json`, `json1`, `quiet`, `tty`. Dfault is `checkstyle`.

- `tty` has multi-line log messages, but all annotations are reported as errors
- `gcc` has single-line log messages, so it's easier to parse with a problem matcher (including correct severity annotation)

```yaml
   ...
   - name: Run ShellCheck
     uses: cfy9/shellcheck-action@main
     with:
       format: json
```

## Run a specific version of Shellcheck

If running the latest stable version of Shellcheck is not to your liking, you can specify a concrete version of Shellcheck to be used.

```yaml
   ...
   - name: Run ShellCheck
     uses: cfy9/shellcheck-action@main
     with:
       version: v0.7.0
```

