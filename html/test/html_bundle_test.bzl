"html_bundle test suite"

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//:defs.bzl", "html_bundle")

def _html_bundle_output_test_impl(ctx):
    env = analysistest.begin(ctx)
    actions = analysistest.target_actions(env)
    file = actions[0].outputs.to_list()[0]
    asserts.equals(env, "html_bundle_test.html", file.basename)
    return analysistest.end(env)

html_bundle_output_test = analysistest.make(_html_bundle_output_test_impl)

def html_bundle_test_suite(name):
    html_bundle_output_test(
        name = "html_bundle_output_test",
        target_under_test = ":html_bundle_test_html",
    )

    write_file(
        name = "entry_point",
        out = "entry_point.html",
        content = ["<html></html>"],
    )

    html_bundle(
        name = "html_bundle_test_html",
        out = "html_bundle_test.html",
        entry_point = ":entry_point",
    )

    native.test_suite(
        name = name,
        tests = [
            ":html_bundle_output_test",
        ],
    )
