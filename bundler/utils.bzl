"Cross platform Go binaries"

load("@aspect_bazel_lib//lib:lists.bzl", "filter", "map")
load("@rules_go//go:def.bzl", "go_binary")

_SUPPORTED_PLATFORMS = ["linux", "freebsd", "darwin", "windows"]
_SUPPORTED_ARCHS = ["amd64"]

def _generate_artifacts_bzl_impl(ctx):
    generator_script = ctx.actions.declare_file("generate_artifacts_bzl.sh")
    target = ctx.actions.declare_file("artifacts.bzl")
    checksum_files = filter(lambda file: file.path.endswith(".sha384"), ctx.files.data)
    for_artifacts = map(lambda file: ("-".join(file.basename.split(".")[0].split("-")[1:]), file.path), checksum_files)
    ctx.actions.expand_template(
        output = generator_script,
        template = ctx.file._template,
        substitutions = {
            "prefix": "bundler",
            "{out}": target.path,
            "{artifacts}": "\t" + ",\n\t".join(["\"{platform_arch}\": (\"bundler-{platform_arch}\", \"`cat {file}`\")".format(platform_arch = platform_arch, file = file) for (platform_arch, file) in for_artifacts]),
        },
        is_executable = True,
    )

    ctx.actions.run(
        outputs = [target],
        inputs = ctx.files.data,
        executable = generator_script,
    )

    runfiles = ctx.runfiles(files = [generator_script] + ctx.files.data)

    return [
        DefaultInfo(
            files = depset([target]),
            runfiles = runfiles,
        ),
    ]

generate_artifacts_bzl = rule(
    _generate_artifacts_bzl_impl,
    attrs = {
        "data": attr.label_list(allow_files = True),
        "_template": attr.label(
            default = Label("//bundler:generate_artifacts_bzl.sh.tpl"),
            allow_single_file = True,
        ),
    },
)

def _hash_file_impl(ctx):
    ctx.actions.run_shell(
        outputs = [ctx.outputs.out],
        inputs = [ctx.file.src],
        command = """shasum -b -a %s %s | awk "{print $1}" | xxd -r -p | base64 > %s""" % (
            ctx.attr.algo,
            ctx.file.src.path,
            ctx.outputs.out.path,
        ),
    )

hash_file = rule(
    _hash_file_impl,
    attrs = {
        "algo": attr.string(default = "384", values = ["1", "224", "256", "384", "512", "512224", "512256"]),
        "out": attr.output(),
        "src": attr.label(allow_single_file = True),
    },
)

def go_binaries(name, prefix, embed, platforms = _SUPPORTED_PLATFORMS, archs = _SUPPORTED_ARCHS):
    """Macro to generate go binaries for multiple platforms/archs

    Args:
      name: A unique name
      prefix: prefix to use for all files
      embed: List of labels to embed in the binary
      platforms: Platforms to generate a binary for
      archs: Archs to generate a binary for
    """
    binaries = []
    checksums = []
    for platform in platforms:
        ext = ""
        if platform == "windows":
            ext = ".exe"

        for arch in archs:
            binary_name = "%s-%s-%s" % (prefix, platform, arch)

            go_binary(
                name = binary_name,
                out = "%s%s" % (binary_name, ext),
                embed = embed,
                goarch = arch,
                goos = platform,
            )

            checksum_name = "%s_sha384" % binary_name
            hash_file(
                name = checksum_name,
                src = ":%s" % binary_name,
                out = "%s.sha384" % binary_name,
            )
            binaries.append(binary_name)
            checksums.append(checksum_name)

    native.filegroup(
        name = name,
        srcs = binaries,
    )

    native.filegroup(
        name = "%s_sha384" % name,
        srcs = checksums,
    )
