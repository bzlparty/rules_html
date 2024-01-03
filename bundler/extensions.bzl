"Bundler module extensions"

load(":artifacts.bzl", "ARTIFACTS", "VERSION")

_ORGA = "https://github.com/bzlparty"

def _github_release_url(project, version, artifact):
    return "{orga}/{project}/relases/v{version}/download/{artifact}".format(
        orga = _ORGA,
        project = project,
        version = version,
        artifact = artifact,
    )

def _find_artifact_and_integrity(ctx, artifacts):
    return artifacts["%s-%s" % (ctx.os.name, ctx.os.arch)]

def _github(ctx, project):
    def _download(version, artifact, integrity):
        ctx.download(
            output = artifact,
            url = _github_release_url(project, version, artifact),
            integrity = integrity,
            executable = True,
        )

    return struct(
        download_from_release = _download,
    )

BundlerInfo = provider(
    doc = "Bundler infor provider",
    fields = {
        "binary": "Path to bundler binary",
    },
)

def _bundler_toolchain_impl(ctx):
    binary = ctx.file.binary
    default_info = DefaultInfo(
        files = depset([binary]),
        runfiles = ctx.runfiles(files = [binary]),
    )
    bundler_info = BundlerInfo(binary = binary)
    toolchain_info = platform_common.ToolchainInfo(
        bundler_info = bundler_info,
        default = default_info,
    )

    return [default_info, toolchain_info]

bundler_toolchain = rule(
    _bundler_toolchain_impl,
    attrs = {
        "binary": attr.label(
            allow_single_file = True,
        ),
    },
)

_BUILD_FILE = """# generated from //bundler:extensions.bzl
load("@bzlparty_rules_html//bundler:extensions.bzl", "bundler_toolchain")
load("@local_config_platform//:constraints.bzl", "HOST_CONSTRAINTS")
bundler_toolchain(
    name = "bundler_toolchain",
    binary = "{binary}",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "toolchain",
    exec_compatible_with = HOST_CONSTRAINTS,
    toolchain = ":bundler_toolchain",
    toolchain_type = "{toolchain_type}",
)
"""

def _build_file(ctx, content):
    ctx.file("BUILD.bazel", content)

def _bundler_repo_impl(ctx):
    if VERSION == "local":
        _build_file(ctx, _BUILD_FILE.format(
            binary = "@bzlparty_rules_html//bundler:bin",
            toolchain_type = "@bzlparty_rules_html//bundler:toolchain_type",
        ))
        return

    (artifact, integrity) = _find_artifact_and_integrity(ctx, ARTIFACTS)
    github = _github(ctx, "rules_html")
    github.download_from_release(VERSION, artifact, integrity)
    _build_file(ctx, _BUILD_FILE.format(binary = artifact, toolchain_type = "@bzlparty_rules_html//bundler:toolchain_type"))

_bundler_repo = repository_rule(
    _bundler_repo_impl,
)

bundler_extension = module_extension(
    implementation = lambda _: _bundler_repo(name = "bundler_toolchain"),
)
