#!/usr/bin/env python3
"""Build a portable HTML site from XML + XSLT 1.0.

Run: python scripts/build.py
Dependencies: lxml (build time only). Generated site has no framework dependency.
"""
from __future__ import annotations

import math
import re
import shutil
from datetime import date
from pathlib import Path
from lxml import etree

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / 'site'
PAGE_SIZE = 4
CATEGORIES = ('news', 'events', 'reports')


def validate_xml(xml_tree: etree._ElementTree) -> list[etree._Element]:
    articles = xml_tree.xpath('/site/articles/article')
    if not articles:
        raise ValueError('記事が見つかりません')
    slugs: set[str] = set()
    for article in articles:
        slug = article.get('slug', '')
        if not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', slug):
            raise ValueError(f'不正なslug: {slug!r}')
        if slug in slugs:
            raise ValueError(f'slugが重複しています: {slug}')
        slugs.add(slug)
        if article.get('category') not in CATEGORIES:
            raise ValueError(f'不正なカテゴリ: {slug}')
        date.fromisoformat(article.get('published', ''))
        for name in ('title', 'summary', 'body'):
            node = article.find(name)
            if node is None or not ''.join(node.itertext()).strip():
                raise ValueError(f'{slug} の {name} が空です')
    return articles


def build() -> None:
    # Do not resolve entities or retrieve external network resources.
    parser = etree.XMLParser(resolve_entities=False, no_network=True)
    xml_tree = etree.parse(str(ROOT / 'data/articles.xml'), parser)
    articles = validate_xml(xml_tree)
    list_xslt = etree.XSLT(etree.parse(str(ROOT / 'templates/list.xsl'), parser))
    detail_xslt = etree.XSLT(etree.parse(str(ROOT / 'templates/detail.xsl'), parser))

    def render(target: Path, transformer: etree.XSLT, **params: str) -> None:
        target.parent.mkdir(parents=True, exist_ok=True)
        result = transformer(xml_tree, **{key: etree.XSLT.strparam(value) for key, value in params.items()})
        target.write_text('<!doctype html>\n' + str(result), encoding='utf-8')
        print('generated:', target.relative_to(ROOT))

    # Remove stale generated pages (for example, articles deleted from XML).
    # OUTPUT is a fixed, project-local path, never derived from user input.
    if OUTPUT.exists():
        shutil.rmtree(OUTPUT)

    # Include runtime assets in the generated, deployable site.
    shutil.copytree(ROOT / 'assets', OUTPUT / 'assets')

    for category in ('all',) + CATEGORIES:
        count = sum(category == 'all' or article.get('category') == category for article in articles)
        pages = math.ceil(count / PAGE_SIZE)
        for page in range(1, pages + 1):
            parts = [] if category == 'all' else ['categories', category]
            if page > 1:
                parts.extend(['page', str(page)])
            output = OUTPUT.joinpath(*parts, 'index.html')
            relative_root = '../' * len(output.parent.relative_to(OUTPUT).parts)
            render(output, list_xslt, root=relative_root or './', category=category,
                   page=str(page), pageSize=str(PAGE_SIZE), pageCount=str(pages))

    for article in articles:
        output = OUTPUT / 'articles' / article.get('slug') / 'index.html'
        render(output, detail_xslt, root='../../', slug=article.get('slug'))


if __name__ == '__main__':
    build()
