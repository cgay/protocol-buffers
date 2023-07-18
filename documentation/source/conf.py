# Reference: https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import sys
# Two possibilities, to account for multi- and single-package workspaces.
sys.path.insert(0, os.path.abspath('../../../_packages/sphinx-extensions/current/src/sphinxcontrib'))
sys.path.insert(0, os.path.abspath('../../_packages/sphinx-extensions/current/src/sphinxcontrib'))

project = 'Protocol Buffers'
copyright = '2023, Carl Gay'
author = 'Carl Gay'

extensions = [
    'dylan.domain'
]

primary_domain = 'dylan'

templates_path = ['_templates']
exclude_patterns = []

html_theme = 'furo'
html_static_path = ['_static']
