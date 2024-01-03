"html_bundle Rule"

def _html_bundle_impl(ctx):
    binary = ctx.toolchains["@bzlparty_rules_html//bundler:toolchain_type"].bundler_info.binary
    output = ctx.outputs.out
    args = ctx.actions.args()
    args.add("-entry_point", ctx.file.entry_point)
    args.add("-out", ctx.outputs.out)
    ctx.actions.run(
        outputs = [output],
        inputs = [ctx.file.entry_point] + ctx.files.data,
        executable = binary,
        arguments = [args],
        mnemonic = "HtmlBundle",
        progress_message = "Bundle: %s" % output.short_path,
    )

    runfiles = ctx.runfiles(files = ctx.files.data)

    return [
        DefaultInfo(
            files = depset([output]),
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
        ),
        "data": attr.label_list(
            default = [],
            allow_files = True,
        ),
    },
    toolchains = ["@bzlparty_rules_html//bundler:toolchain_type"],
)
