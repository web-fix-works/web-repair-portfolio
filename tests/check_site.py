#!/usr/bin/env python3
"""Dependency-free smoke check for generated static pages and local links.

Run from any directory: python tests/check_site.py
This does not replace real browser accessibility, print, or functional testing.
"""
from __future__ import annotations

from collections import Counter
from functools import lru_cache
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
from xml.etree import ElementTree

ROOT = Path(__file__).resolve().parents[1]


class PageParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: list[str] = []
        self.links: list[str] = []
        self.has_main = False
        self.has_lang = False
        self.has_viewport = False
        self.has_description = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        properties = dict(attrs)
        if tag == 'html' and properties.get('lang') == 'ja':
            self.has_lang = True
        if tag == 'main':
            self.has_main = True
        if tag == 'meta' and properties.get('name') == 'viewport':
            self.has_viewport = True
        if tag == 'meta' and properties.get('name') == 'description':
            self.has_description = True
        if 'id' in properties:
            self.ids.append(properties['id'] or '')
        for field in ('href', 'src'):
            if properties.get(field):
                self.links.append(properties[field])


@lru_cache(maxsize=None)
def inspect(path: Path) -> PageParser:
    parser = PageParser()
    parser.feed(path.read_text(encoding='utf-8'))
    return parser


def main() -> None:
    issues: list[str] = []
    pages = sorted(ROOT.rglob('*.html'))
    for path in pages:
        page = inspect(path)
        label = str(path.relative_to(ROOT))
        for key in ('has_lang', 'has_viewport'):
            if not getattr(page, key):
                issues.append(f'{label}: {key} がありません')
        if path.name != 'before.html':
            for key in ('has_main', 'has_description'):
                if not getattr(page, key):
                    issues.append(f'{label}: {key} がありません')
        for id_, count in Counter(page.ids).items():
            if count > 1:
                issues.append(f'{label}: id={id_!r} が重複')
        for url in page.links:
            parsed = urlsplit(url)
            if parsed.scheme or url.startswith('//'):
                continue
            target = (path.parent / unquote(parsed.path)).resolve() if parsed.path else path
            if not target.is_file():
                issues.append(f'{label}: リンク先またはアセットが存在しません: {url}')
            elif parsed.fragment and target.suffix == '.html':
                if unquote(parsed.fragment) not in inspect(target).ids:
                    issues.append(f'{label}: ページ内リンクが存在しません: {url}')

    xml_path = ROOT / 'project-03-cms/data/articles.xml'
    articles = ElementTree.parse(xml_path).findall('./articles/article')
    if len(articles) != 10:
        issues.append(f'XML記事数が想定と異なります: {len(articles)}')
    for page_index, expected in [(1, 4), (2, 4), (3, 2)]:
        page_path = ROOT / ('project-03-cms/site/index.html' if page_index == 1
                           else f'project-03-cms/site/page/{page_index}/index.html')
        actual = page_path.read_text(encoding='utf-8').count('class="article-row"')
        if actual != expected:
            issues.append(f'ページ{page_index}: {actual}件（想定{expected}件）')

    print(f'検査対象: HTML {len(pages)}ファイル / CMS記事 {len(articles)}件')
    if issues:
        print('NG:')
        for issue in issues:
            print(' -', issue)
        raise SystemExit(1)
    print('OK: 重複ID、必要要素、ローカルリンク、アンカー、CMSページネーション')


if __name__ == '__main__':
    main()
