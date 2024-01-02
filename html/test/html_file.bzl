"html_file test suite"

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//:defs.bzl", "html_file")

def _simple_html_file_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.equals(env, True, True)
    return analysistest.end(env)

simple_html_file_test = analysistest.make(_simple_html_file_test_impl)

def html_file_test_suite(name = "html_file_test"):
    simple_html_file_test(
        name = "simple_html_file_test",
        target_under_test = ":%s" % name,
    )

    html_file(
        name = name,
        out = "html_test.html",
        title = "Hello, World!",
        body = ["<p>Hello, World!</p>"],
    )
