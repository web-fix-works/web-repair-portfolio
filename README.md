# Frontend Lab — Webサイト修正・改修ポートフォリオ

Webサイトの表示調整、JavaScriptのUI改善、XML/XSLTによるCMSテンプレート構築を扱うフロントエンド制作作品集です。

> 掲載作品は自主制作のコンセプトサイトです。受託案件の成果物ではありません。

## 作品一覧

| 作品 | テーマ | サイト | 設計・実装の解説 |
| --- | --- | --- | --- |
| 01 Fieldnotes | レスポンシブ設計・印刷CSS | [サイト](project-01-responsive/index.html) | [解説](project-01-responsive/docs/CASE_STUDY.md) |
| 02 HELIO | JavaScript・UI改善 | [サイト](project-02-ui/index.html) | [解説](project-02-ui/docs/CASE_STUDY.md) |
| 03 SAMPLE COMPANY | XML・XSLT / CMSテンプレート | [サイト](project-03-cms/site/index.html) | [解説](project-03-cms/docs/CASE_STUDY.md) |

[ポートフォリオのトップページ](index.html) / [技術概要](docs/index.html)

## 技術構成

- **HTML/CSS:** セマンティックな文書構造、レスポンシブ、印刷スタイル
- **JavaScript:** タブ操作、検索、URL状態管理、印刷前後のUI状態保持
- **XML/XSLT:** 記事データとテンプレートの分離、一覧・詳細ページ生成
- **アクセシビリティ:** キーボード操作、可視フォーカス、構造化されたナビゲーション
- **保守性:** CSSの役割分離、テンプレート化、入力値の検証

## CMS作品の生成フロー

`data/articles.xml` → `templates/*.xsl` → `scripts/build.py` → `site/`

XMLの記事情報をXSLTで変換し、HTMLとして出力する構成です。静的な公開ファイルは `project-03-cms/site/` に含まれています。

## 品質確認

各作品では画面幅に応じた表示・リンク構造・キーボード操作・印刷での情報保持を確認する設計としています。静的リンク・構造の検査コードは `tests/check_site.py` に収録しています。

### 参考資料

- [WAI-ARIA APG — Tabs](https://www.w3.org/WAI/ARIA/apg/patterns/tabs/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [MDN — Printing CSS](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Printing)
