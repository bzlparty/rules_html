"html_file test suite"

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//:defs.bzl", "HtmlInfo", "html_file")

def _output_test_impl(ctx):
    env = analysistest.begin(ctx)
    actions = analysistest.target_actions(env)
    file = actions[0].outputs.to_list()[0]
    asserts.equals(env, "html_test.html", file.basename)
    return analysistest.end(env)

output_test = analysistest.make(_output_test_impl)

def _provider_test_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)
    asserts.equals(env, True, HtmlInfo in target)
    return analysistest.end(env)

provider_test = analysistest.make(_provider_test_impl)

def html_file_test_suite(name = "html_file_test"):
    output_test(
        name = "output_test",
        target_under_test = ":%s" % name,
    )

    output_test(
        name = "provider_test",
        target_under_test = ":%s" % name,
    )

    html_file(
        name = name,
        out = "html_test.html",
        title = "Hello, World!",
        body = ["<p>Hello, World!</p>"],
    )
