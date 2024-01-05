"Public API"

load("//html:html_bundle.bzl", _html_bundle = "html_bundle")
load("//html:html_file.bzl", _html_file = "html_file")

html_bundle = _html_bundle

def html_file(name, out = None, title = None, **kwargs):
    """A macro for `html_file`

    Args:
      name: Name of the rule
      out: Name of the output file
      title: Title of the output document
      **kwargs: Other args from `html_file`
    """

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
