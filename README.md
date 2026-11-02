# yamlformat

Check YAML formatting with [Google's yamlfmt](https://github.com/google/yamlfmt). The action fails when
files need formatting and never changes them. It downloads a pinned yamlfmt release and verifies the
binary archive against the release checksum.

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
      - uses: tarasmatsyk/yamlfmt-action@v0.1.0
        with:
          directories: |
            charts
            deploy/helm
```

`directories` accepts newline-separated file or directory paths, resolved from the repository root.
Directories are searched recursively for `.yaml` and `.yml` files. It defaults to `.`.

To select a different yamlfmt release:

```yaml
- uses: tarasmatsyk/yamlfmt-action@v0.1.0
  with:
    directories: charts/my-chart
    yamlfmt-version: v0.20.0
```

## Configuration

Add a `.yamlfmt` file at your repository root to configure formatting and which files yamlfmt should
process. See [yamlfmt configuration](https://github.com/google/yamlfmt/blob/main/docs/config-file.md).

Helm chart files in `templates/` may contain Go template expressions and may not be valid YAML until
Helm renders them. Configure yamlfmt to skip those files or pass paths containing plain YAML, such as
`values.yaml` and `Chart.yaml`. Use `helm lint` separately to check the chart.

## Supported runners

Linux x64/ARM64 and macOS x64/ARM64.
