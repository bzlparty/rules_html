"html_bundle Rule"

load(":provider.bzl", "HtmlInfo")

def _html_bundle_impl(ctx):
    binary = ctx.toolchains["@bzlparty_rules_html//bundler:toolchain_type"].bundler_info.binary
    outputs = [ctx.outputs.out]
    inputs = ctx.files.data + [ctx.file.entry_point]
    args = ctx.actions.args()
    args.add("-entry_point", ctx.file.entry_point)
    args.add("-out", ctx.outputs.out)

    if HtmlInfo in ctx.attr.entry_point:
        inputs.append(*ctx.attr.entry_point[HtmlInfo].deps.to_list())

    ctx.actions.run(
        outputs = outputs,
        inputs = inputs,
        executable = binary,
        arguments = [args],
        mnemonic = "HtmlBundle",
        progress_message = "Bundle: %s" % ctx.outputs.out.short_path,
    )

    runfiles = ctx.runfiles(files = inputs)

    return [
        DefaultInfo(
            files = depset(outputs),
            runfiles = runfiles,
        ),
    ]

html_bundle = rule(
    _html_bundle_impl,
    attrs = {
        "out": attr.output(
            mandatory = True,
        ),
        "entry_point": attr.label(
            mandatory = True,
            allow_single_file = True,
            providers = [HtmlInfo, DefaultInfo],
        ),
        "data": attr.label_list(
            default = [],
            allow_files = True,
        ),
    },
    toolchains = ["@bzlparty_rules_html//bundler:toolchain_type"],
)
