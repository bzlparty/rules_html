load("//html:html_file.bzl", _html_file = "html_file")

def html_file(name, out = None, title = None, **kwargs):
    if not out:
        out = "%s.html" % name
    if not title:
        title = name.title()

    _html_file(
        name = name,
        title = title,
        out = out,
        **kwargs
    )
