#!/usr/bin/env bash

host=$(uname -s)
NAME=rules_html
TAG=${GITHUB_REF_NAME}
VERSION=${TAG:1}
PREFIX="${NAME}-${VERSION}"
RULES_ARCHIVE="${NAME}-${TAG}.tar.gz"

echo -n "build: Build Release Artifacts"
bazel \
  --bazelrc=${GITHUB_WORKSPACE}/.bazelrc \
  --bazelrc=${GITHUB_WORKSPACE}/.github/workflows/ci.bazelrc \
  build //bundler:release
echo " ... done"

echo -n "build: Generate artifacts.bzl"
(cat bazel-bin/bundler/artifacts.bzl; echo "VERSION = \"${VERSION}\"") > artifacts.bzl
echo " ... done (`cat artifacts.bzl`)"

echo -n "build: Create Rules Archive"
git archive --prefix=${PREFIX}/bundler/ --add-file=artifacts.bzl --format=tar --prefix=${PREFIX}/ ${TAG} | gzip >$RULES_ARCHIVE
RULES_SHA=$(shasum -a 256 $RULES_ARCHIVE | awk '{print $1}')
echo " ... done ($RULES_ARCHIVE: $RULES_SHA)"

echo -n "build: Copy artifacts"
for f in $(bazel cquery --output starlark --starlark:expr '"\n".join([f.path for f in target.files.to_list()])' //bundler:release | grep "bundler-"); do
  cp $f .
done
echo " ... done"

echo -n "build: Creaet Release Notes"
cat > release_notes.md <<EOF

## Installation

> [!IMPORTANT]  
> Installation is only supported via Bzlmod!

Choose from the options below and put as dependency in your `MODULE.bazel`.

### Install from BCR

\`\`\`starlark
bazel_dep(name = "bzlparty_rules_html", version = "${VERSION}")
\`\`\`


### Install from Git

\`\`\`starlark
bazel_dep(name = "bzlparty_rules_html")

git_override(
    module_name = "bzlparty_rules_html",
    remote = "git@github.com:bzlparty/rules_html.git",
    commit = "${GITHUB_SHA}",
)
\`\`\`

### Install from Archive

\`\`\`starlark
bazel_dep(name = "bzlparty_rules_html")

archive_override(
    module_name = "bzlparty_rules_html",
    urls = "https://github.com/bzlparty/rules_html/releases/download/${TAG}/${RULES_ARCHIVE}",
    strip_prefix = "${PREFIX}",
    integrity = "sha256-${RULES_SHA}",
)
\`\`\`

## Checksums

**${RULES_ARCHIVE}** ${RULES_SHA}

EOF

echo " ... done"
