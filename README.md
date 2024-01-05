# Bazel Rules for HTML

[![Test](https://github.com/bzlparty/rules_html/actions/workflows/test.yaml/badge.svg?branch=main&event=push)](https://github.com/bzlparty/rules_html/actions/workflows/test.yaml)

## Installation

See install instructions on the [release page](https://github.com/bzlparty/rules_html/releases).

## Usage

Generate an HTML file:

```starlark
load("@bzlparty_rules_html//:defs.bzl", "html_file")

html_file(
    name = "index",
    out = "index.html",
    body = [
        "<p>Hello, World!</p>",
        "<script src=\"$(location :hello_world.js)\"></script>":
    ],
    title = "Hello, World!",
    data = [
        ":hello_world.js",
    ],
)
```

Bundle an HTML file:

```starlark
load("@bzlparty_rules_html//:defs.bzl", "html_bundle")

html_bundle(
    name = "bundle",
    out = "bundle.html",
    endtry_point = ":index.html",
)
```

## Development

Install git hooks:

```bash
pre-commit install
```

## License

[GNU GPL 3.0](/LICENSE)
