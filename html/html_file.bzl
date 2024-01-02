load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "COPY_FILE_TO_BIN_TOOLCHAINS", "copy_files_to_bin_actions")
load("@aspect_bazel_lib//lib:expand_make_vars.bzl", "expand_locations")
load("@aspect_bazel_lib//lib:lists.bzl", "map")

def _create_location_expander(ctx, targets):
    return lambda i: expand_locations(ctx, i, targets)

def _html_file_impl(ctx):
    output = ctx.outputs.out
    outputs = [output]
    files = ctx.files.data

    if ctx.attr.copy_files_to_bin:
        outputs.extend(copy_files_to_bin_actions(ctx, files = files))

    location_expander = _create_location_expander(ctx, ctx.attr.data)
    ctx.actions.expand_template(
        template = ctx.file._html_template,
        output = output,
        substitutions = {
            "{{base}}": ctx.attr.base,
            "{{body}}": "\n".join(map(location_expander, ctx.attr.body)),
            "{{head}}": "\n".join(map(location_expander, ctx.attr.head)),
            "{{title}}": ctx.attr.title,
        },
        is_executable = False,
    )

    return [
        DefaultInfo(
            files = depset(outputs),
            runfiles = ctx.runfiles(files = files),
        ),
    ]

html_file = rule(
    _html_file_impl,
    attrs = {
        "out": attr.output(
            doc = "Name of the output file",
            mandatory = True,
        ),
        "base": attr.string(
            doc = "base URL of the document",
            default = "/",
        ),
        "body": attr.string_list(
            doc = "Content of `<body></body>`",
            default = [""],
        ),
        "head": attr.string_list(
            doc = "Content appended to `<head></head>`",
            default = [""],
        ),
        "data": attr.label_list(
            doc = "Files",
            allow_files = True,
        ),
        "copy_files_to_bin": attr.bool(
            default = False,
        ),
        "title": attr.string(
            doc = "Title of the document",
            mandatory = True,
        ),
        "_html_template": attr.label(
            default = "//html:html.tpl",
            allow_single_file = True,
        ),
    },
    toolchains = COPY_FILE_TO_BIN_TOOLCHAINS,
)
