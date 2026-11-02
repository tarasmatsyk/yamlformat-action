# yamlfmt GitHub Action

Check YAML formatting with [Google's yamlfmt](https://github.com/google/yamlfmt). The action searches
directories recursively for `.yaml` and `.yml` files, and fails if formatting changes are needed.
It never modifies files. The selected yamlfmt release binary is checksum-verified before use.

## Usage

```yaml
name: YAML format

on:
  pull_request:

jobs:
  yamlfmt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: personal/tarasmatsyk/yamlfmt-action@v1
        with:
          directories: |
            charts
            deploy/helm
```

`directories` defaults to `.` and accepts newline-separated paths, including individual YAML files.
Paths are resolved from the repository working directory. Select a yamlfmt version explicitly if
you want to control upgrades:

```yaml
- uses: personal/tarasmatsyk/yamlfmt-action@v1
  with:
    directories: charts/my-chart
    yamlfmt-version: v0.20.0
```

## Configuration and Helm templates

Put a `.yamlfmt` config file in your repository to control formatting. The action runs yamlfmt from
the repository root, where yamlfmt can discover the config.

Helm files in `templates/` contain Go template expressions and often are not valid standalone YAML.
Use yamlfmt configuration to limit matching files or pass narrower directories/files. Run `helm lint`
separately to validate rendered chart templates.

## Supported runners

Linux x64/ARM64 and macOS x64/ARM64. Windows runners are not currently supported.

## Releasing

Create a release such as `v1.0.0` and a matching git tag. Maintain a `v1` tag for compatible updates,
so users can reference `personal/tarasmatsyk/yamlfmt-action@v1`. The action version and yamlfmt
version are separate; the latter is set with `yamlfmt-version`.
