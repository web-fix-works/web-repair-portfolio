<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:param name="root" select="'./'"/>
  <xsl:param name="category" select="'all'"/>
  <xsl:param name="page" select="1"/>
  <xsl:param name="pageSize" select="4"/>
  <xsl:param name="pageCount" select="1"/>
  <xsl:variable name="categoryLabel">
    <xsl:choose>
      <xsl:when test="$category='news'">お知らせ</xsl:when>
      <xsl:when test="$category='events'">イベント</xsl:when>
      <xsl:when test="$category='reports'">企業活動</xsl:when>
      <xsl:otherwise>すべての記事</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:template match="/site">
    <html lang="ja">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <meta name="robots" content="noindex,nofollow"/>
        <meta name="description" content="SAMPLE COMPANYのお知らせ、イベント、企業活動をご案内します。"/>
        <title><xsl:value-of select="$categoryLabel"/>｜SAMPLE COMPANY</title>
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
              <a href="#about">取り組みについて</a>
            </nav>
          </div>
        </header>
        <main id="main">
          <section class="hero">
            <div class="wrap hero-inner">
              <p class="eyebrow">CORPORATE NEWS &amp; UPDATES</p>
              <h1>企業の情報を、<br/><em>わかりやすく。</em></h1>
              <p>お知らせ、イベント、企業活動。<br/>必要な情報へ迷わずたどり着ける企業サイト。</p>
            </div>
            <div class="hero-shape" aria-hidden="true"/>
          </section>
          <div class="wrap">
            <nav aria-label="パンくずリスト" class="breadcrumbs">
              <ol>
                <li>
                  <a href="{$root}index.html">ホーム</a>
                </li>
                <xsl:if test="$category != 'all'">
                  <li aria-current="page">
                    <xsl:value-of select="$categoryLabel"/>
                  </li>
                </xsl:if>
                <xsl:if test="$category = 'all'">
                  <li aria-current="page">新着情報</li>
                </xsl:if>
              </ol>
            </nav>
            <section class="news-section" aria-labelledby="section-title">
              <div class="section-title">
                <div>
                  <p class="eyebrow dark">LATEST ARTICLES</p>
                  <h2 id="section-title">
                    <xsl:value-of select="$categoryLabel"/>
                  </h2>
                </div>
                <p>公開日の新しい記事から順にご覧いただけます。</p>
              </div>
              <nav aria-label="記事カテゴリ" class="categories">
                <a href="{$root}index.html"><xsl:if test="$category='all'"><xsl:attribute name="aria-current">page</xsl:attribute></xsl:if>すべて</a>
                <a href="{$root}categories/news/index.html"><xsl:if test="$category='news'"><xsl:attribute name="aria-current">page</xsl:attribute></xsl:if>お知らせ</a>
                <a href="{$root}categories/events/index.html"><xsl:if test="$category='events'"><xsl:attribute name="aria-current">page</xsl:attribute></xsl:if>イベント</a>
                <a href="{$root}categories/reports/index.html"><xsl:if test="$category='reports'"><xsl:attribute name="aria-current">page</xsl:attribute></xsl:if>企業活動</a>
              </nav>
              <div class="article-list">
                <xsl:for-each select="articles/article[$category = 'all' or @category = $category]">
                  <xsl:sort select="@published" data-type="text" order="descending"/>
                  <xsl:if test="position() &gt; ($page - 1) * $pageSize and position() &lt;= $page * $pageSize">
                    <article class="article-row">
                      <div class="article-meta">
                        <time datetime="{@published}">
                          <xsl:value-of select="translate(@published,'-','.')"/>
                        </time>
                        <span class="cat cat-{@category}">
                          <xsl:call-template name="cat-label">
                            <xsl:with-param name="key" select="@category"/>
                          </xsl:call-template>
                        </span>
                      </div>
                      <h3>
                        <a href="{$root}articles/{@slug}/index.html">
                          <xsl:value-of select="title"/>
                          <span aria-hidden="true"> ↗</span>
                        </a>
                      </h3>
                      <p>
                        <xsl:value-of select="summary"/>
                      </p>
                    </article>
                  </xsl:if>
                </xsl:for-each>
              </div>
              <xsl:if test="$pageCount &gt; 1">
                <nav class="pagination" aria-label="記事一覧のページ切り替え">
                  <xsl:for-each select="articles/article[position() &lt;= $pageCount]">
                    <xsl:variable name="n" select="position()"/>
                    <xsl:variable name="base">
                      <xsl:choose>
                        <xsl:when test="$category = 'all'">
                          <xsl:value-of select="concat($root,'index.html')"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="concat($root,'categories/',$category,'/index.html')"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <a>
                      <xsl:attribute name="href">
                        <xsl:choose>
                          <xsl:when test="$n = 1">
                            <xsl:value-of select="$base"/>
                          </xsl:when>
                          <xsl:when test="$category = 'all'">
                            <xsl:value-of select="concat($root,'page/',$n,'/index.html')"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="concat($root,'categories/',$category,'/page/',$n,'/index.html')"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:attribute>
                      <xsl:if test="$n = $page">
                        <xsl:attribute name="aria-current">page</xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="$n"/>
                    </a>
                  </xsl:for-each>
                </nav>
              </xsl:if>
            </section>
          </div>
          <aside class="about" id="about">
            <div class="wrap">
              <span>ABOUT THIS SITE</span>
              <h2>更新しやすく、探しやすく。</h2>
              <p>更新情報をカテゴリごとに整理し、公開日が新しい記事からご覧いただけます。記事詳細は印刷にも対応しています。</p>
            </div>
          </aside>
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
  <xsl:template name="cat-label">
    <xsl:param name="key"/>
    <xsl:choose>
      <xsl:when test="$key='news'">お知らせ</xsl:when>
      <xsl:when test="$key='events'">イベント</xsl:when>
      <xsl:otherwise>企業活動</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
