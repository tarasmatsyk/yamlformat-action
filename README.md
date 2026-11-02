# yamlformat-action

Check YAML formatting with [Google's yamlfmt](https://github.com/google/yamlfmt). The action fails when
files need formatting and never changes them. It verifies Google's signed checksum manifest, then
checks the downloaded binary archive against that manifest.

## Usage

```yaml
name: YAML formatting

on:
  pull_request:

jobs:
  yamlfmt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: tarasmatsyk/yamlformat-action@v0.1.0
        with:
          directories: |
            charts
            deploy/helm
          config-file: .github/.yamlfmt
          exclude: |
            charts/generated
```

`directories` accepts newline-separated file or directory paths, resolved from the repository root.
Directories are searched recursively for `.yaml` and `.yml` files. It defaults to `.`. The action's
`yamlfmt-version` defaults to `v0.21.0`.

### Inputs

| Input | Description | Default |
| --- | --- | --- |
| `directories` | Newline-separated files or directories to check | `.` |
| `config-file` | Config file path, passed to yamlfmt as `-conf` | Auto-discover config |
| `exclude` | Newline-separated patterns to exclude | None |
| `yamlfmt-version` | yamlfmt release tag to install | `v0.21.0` |

Use `exclude` for patterns that should be skipped:

```yaml
- uses: tarasmatsyk/yamlformat-action@v0.1.0
  with:
    directories: charts
    exclude: |
      charts/generated
      charts/my-chart/templates
```

## Helm charts

Helm files in `templates/` may contain Go template expressions and may not be valid YAML until Helm
renders them. Use a yamlfmt config to exclude those files or pass paths containing plain YAML, such as
`values.yaml` and `Chart.yaml`. Run `helm lint` separately to check the chart.

## Supported runners

Linux x64/ARM64 and macOS x64/ARM64.
