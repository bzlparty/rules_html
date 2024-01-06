"html_file test suite"

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//:defs.bzl", "HtmlInfo", "html_file")

def _html_file_output_test_impl(ctx):
    env = analysistest.begin(ctx)
    actions = analysistest.target_actions(env)
    file = actions[0].outputs.to_list()[0]
    asserts.equals(env, "html_file_test.html", file.basename)
    return analysistest.end(env)

html_file_output_test = analysistest.make(_html_file_output_test_impl)

def _html_file_provider_test_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)
    asserts.equals(env, True, HtmlInfo in target)
    return analysistest.end(env)

html_file_provider_test = analysistest.make(_html_file_provider_test_impl)

def html_file_test_suite(name):
    html_file_output_test(
        name = "html_file_output_test",
        target_under_test = ":html_file_test_html",
    )

    html_file_provider_test(
        name = "html_file_provider_test",
        target_under_test = ":html_file_test_html",
    )

    html_file(
        name = "html_file_test_html",
        out = "html_file_test.html",
        title = "Hello, World!",
        body = ["<p>Hello, World!</p>"],
    )

    native.test_suite(
        name = name,
        tests = [
            ":html_file_output_test",
            ":html_file_provider_test",
        ],
    )
