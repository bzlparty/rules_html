"Bundler module extensions"

load("@bzlparty_tools//lib:github.bzl", "github")
load("@bzlparty_tools//lib:platforms.bzl", "host_platform")
load(":artifacts.bzl", "ARTIFACTS", "VERSION")

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

def _setup_bundler_toolchain(ctx):
    if VERSION == "local":
        _bundler_source_toolchain_repo(
            name = "bundler_toolchain",
        )
        return

    platform = host_platform(ctx)
    (artifact, integrity) = ARTIFACTS[platform]
    _bundler_platform_toolchain_repo(
        name = "bundler_toolchain",
        version = VERSION,
        artifact = artifact,
        integrity = integrity,
    )

def _bundler_platform_toolchain_repo_impl(ctx):
    gh = github(ctx, "rules_html")
    artifact = ctx.attr.artifact
    gh.download_binary(VERSION, artifact, integrity = ctx.attr.integrity)
    _build_file(ctx, _BUILD_FILE.format(
        binary = artifact,
        toolchain_type = "@bzlparty_rules_html//bundler:toolchain_type",
    ))

_bundler_platform_toolchain_repo = repository_rule(
    _bundler_platform_toolchain_repo_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "artifact": attr.string(mandatory = True),
        "integrity": attr.string(mandatory = True),
    },
)

_bundler_source_toolchain_repo = repository_rule(
    implementation = lambda ctx: _build_file(ctx, _BUILD_FILE.format(
        binary = "@bzlparty_rules_html//bundler:bin",
        toolchain_type = "@bzlparty_rules_html//bundler:toolchain_type",
    )),
)

bundler_extension = module_extension(
    implementation = lambda ctx: _setup_bundler_toolchain(ctx),
)
