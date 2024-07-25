# Copyright 2024 Canonical Ltd.
# See LICENSE file for licensing details.

"""Custom Sphinx configuration for Charmed HPC documentation site."""

import datetime

project = "Charmed HPC"
author = "Charmed HPC Authors"
html_title = project + " documentation"
copyright = "%s CC-BY-SA, %s" % (datetime.date.today().year, author)

ogp_site_url = "https://canonical-starter-pack.readthedocs-hosted.com/"
ogp_site_name = project
ogp_image = "https://assets.ubuntu.com/v1/253da317-image-document-ubuntudocs.svg"
html_favicon = '.sphinx/_static/favicon.png'
html_context = {
    # Product information
    "product_page": "ubuntu.com/hpc",
    "product_tag": "_static/tag.png",

    # Chat and updates
    "matrix": "https://matrix.to/#/#hpc:ubuntu.com",

    # GitHub
    "github_url": "https://github.com/charmed-hpc",
    "github_repository": "docs",
    "github_version": "main",
    "github_folder": "/",
    "github_issues": "enabled",
    "github_discussions": "https://github.com/orgs/charmed-hpc/discussions",
    "github_qa": "https://github.com/orgs/charmed-hpc/discussions/new?category=q-a",

    # Footer configuration
    "sequential_nav": "none",
    "display_contributors": True,
    "display_contributors_since": ""
}

slug = ""
redirects = {}
linkcheck_ignore = [
    "http://127.0.0.1:8000",
    "https://matrix.to/#/#hpc:ubuntu.com",
]
custom_linkcheck_anchors_ignore_for_url = []
custom_myst_extensions = []
custom_extensions = [
    "sphinx_remove_toctrees",
    "sphinx_tabs.tabs",
    "sphinx.ext.intersphinx",
    "canonical.youtube-links",
    "canonical.related-links",
    "canonical.config-options",
    "canonical.custom-rst-roles",
    "canonical.terminal-output",
    "canonical.filtered-toc",
    "notfound.extension",
]
custom_required_modules = [
    "sphinx-remove-toctrees",
]
custom_excludes = [
    "CONTRIBUTING.md",
    "README.md",
]
custom_html_css_files = []
custom_html_js_files = []
custom_tags = []
# custom_rst_epilog = ''
disable_feedback_button = False
# manpages_url = "https://manpages.ubuntu.com/manpages/noble/en/man{section}/{page}.{section}.html"

# Define a :center: role that can be used to center the content of table cells.
rst_prolog = '''
.. role:: center
   :class: align-center
'''
