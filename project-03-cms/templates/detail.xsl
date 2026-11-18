<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:param name="root" select="'../../'"/>
  <xsl:param name="slug"/>
  <xsl:template match="/site">
    <xsl:apply-templates select="articles/article[@slug=$slug]"/>
  </xsl:template>
  <xsl:template match="article">
    <xsl:variable name="catLabel">
      <xsl:choose>
        <xsl:when test="@category='news'">お知らせ</xsl:when>
        <xsl:when test="@category='events'">イベント</xsl:when>
        <xsl:otherwise>企業活動</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <html lang="ja">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <meta name="robots" content="noindex,nofollow"/>
        <meta name="description" content="{summary}"/>
        <title><xsl:value-of select="title"/>｜SAMPLE COMPANY</title>
        <link rel="stylesheet" href="{$root}assets/site.css"/>
        <link rel="stylesheet" media="print" href="{$root}assets/print.css"/>
        <script defer="defer" src="{$root}assets/site.js"/>
      </head>
      <body>
        <a class="skip" href="#main">本文に移動</a>
        <div class="demo">CONCEPT SITE / 自主制作 <a href="{$root}../../index.html">制作一覧に戻る ↗</a></div>
        <header class="header">
          <div class="wrap header-inner">
            <a class="logo" href="{$root}index.html">
              <span class="logo-symbol" aria-hidden="true">▤</span>
              <span>SAMPLE COMPANY<span class="logo-sub"> CORPORATE NEWSROOM</span></span>
            </a>
            <nav aria-label="メインナビゲーション" class="mainnav">
              <a href="{$root}index.html">新着情報</a>
            </nav>
          </div>
        </header>
        <main id="main">
          <div class="wrap">
            <nav aria-label="パンくずリスト" class="breadcrumbs">
              <ol>
                <li>
                  <a href="{$root}index.html">ホーム</a>
                </li>
                <li>
                  <a href="{$root}categories/{@category}/index.html">
                    <xsl:value-of select="$catLabel"/>
                  </a>
                </li>
                <li aria-current="page">
                  <xsl:value-of select="title"/>
                </li>
              </ol>
            </nav>
            <article class="article-detail">
              <!-- 印刷時に記事の出典を表示する。 -->
              <p class="print-source">SAMPLE COMPANY｜Corporate Newsroom</p>
              <div class="detail-meta">
                <time datetime="{@published}">
                  <xsl:value-of select="translate(@published,'-','.')"/>
                </time>
                <span class="cat cat-{@category}">
                  <xsl:value-of select="$catLabel"/>
                </span>
              </div>
              <h1>
                <xsl:value-of select="title"/>
              </h1>
              <p class="detail-summary">
                <xsl:value-of select="summary"/>
              </p>
              <div class="article-body">
                <xsl:copy-of select="body/*"/>
              </div>
              <div class="print-tools">
                <button type="button" id="print-btn" hidden="hidden">この記事を印刷する ↗</button>
                <a href="{$root}index.html">新着情報一覧に戻る →</a>
              </div>
            </article>
            <section class="related" aria-labelledby="related-heading">
              <h2 id="related-heading">ほかの記事を読む</h2>
              <ul>
                <xsl:for-each select="../article[@slug != $slug and @category = current()/@category]">
                  <xsl:sort select="@published" order="descending"/>
                  <xsl:if test="position() &lt;= 3">
                    <li>
                      <a href="{$root}articles/{@slug}/index.html">
                        <xsl:value-of select="title"/>
                        <span aria-hidden="true"> ↗</span>
                      </a>
                    </li>
                  </xsl:if>
                </xsl:for-each>
              </ul>
            </section>
          </div>
        </main>
        <footer class="footer">
          <div class="wrap">
            <span>SAMPLE COMPANY CORPORATE NEWSROOM / Corporate Newsroom — Concept Site</span>
            <a href="{$root}../../index.html">制作一覧へ ↗</a>
          </div>
        </footer>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
