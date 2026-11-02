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
      - uses: actions/checkout@v7
      - uses: tarasmatsyk/yamlformat-action@v0.3.2
        with:
          paths: |
            charts
            deploy/helm
          config-file: .github/.yamlfmt
```

`paths` accepts newline-separated file paths, directory paths, or glob patterns and passes them
through to yamlfmt unchanged. Directories are searched recursively for `.yaml` and `.yml` files in
the default mode. The input defaults to `.`. Set `dstar: true` for doublestar patterns unless
`doublestar: true` is already set in the yamlfmt config.

`yamlfmt-version` defaults to `v0.21.0`; a leading `v` is optional. If the yamlfmt config has
`doublestar: true`, pass glob patterns in `paths` instead of directory paths; that config setting is
equivalent to `dstar: true`.

### Inputs

| Input | Description | Default |
| --- | --- | --- |
| `paths` | Newline-separated file, directory, or glob paths | `.` |
| `dstar` | Enable yamlfmt doublestar glob mode; provide patterns rather than directory paths | `false` |
| `config-file` | Config file path, passed to yamlfmt as `-conf` | Auto-discover config |
| `yamlfmt-version` | yamlfmt release version, with or without a leading `v` | `v0.21.0` |

For doublestar patterns, set `dstar: true` if it is not already enabled in the config:

```yaml
- uses: tarasmatsyk/yamlformat-action@v0.3.2
  with:
    paths: |
      charts/**/*.yaml
      charts/**/*.yml
    dstar: true
    config-file: .github/.yamlfmt
```

This action verifies signed yamlfmt release checksums, available upstream starting with v0.14.0.

## Helm charts

Helm files in `templates/` may contain Go template expressions and may not be valid YAML until Helm
renders them. Use a yamlfmt config to exclude those files or pass paths containing plain YAML, such as
`values.yaml` and `Chart.yaml`. Run `helm lint` separately to check the chart.

## Supported runners

Linux x64/ARM64 and macOS x64/ARM64.
