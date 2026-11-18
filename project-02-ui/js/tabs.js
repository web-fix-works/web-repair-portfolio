/**
 * Accessible FAQ tabs — dependency-free, progressive enhancement.
 *  - Without JS all categories remain visible as native anchor targets.
 *  - With JS: WAI-ARIA roving tabindex / arrow / Home / End.
 *  - replaceState updates the shareable hash without browser jump.
 *  - beforeprint prints every panel and the full FAQ without mutating UI afterward.
 */
(() => {
  'use strict';

  const tabContainer = document.querySelector('#faq-categories');
  const searchTools = document.querySelector('#search-tools');
  const searchInput = document.querySelector('#faq-search');
  const clearButton = document.querySelector('#clear-btn');
  const status = document.querySelector('#search-status');
  const noResults = document.querySelector('#no-results');
  const printButton = document.querySelector('#print-btn');
  if (!tabContainer || !searchTools || !searchInput || !clearButton || !status || !noResults) return;

  const tabs = [...tabContainer.querySelectorAll('a[href^="#"]')];
  const entries = tabs.map((tab) => {
    const id = tab.getAttribute('href').slice(1);
    return { tab, panel: document.getElementById(id), id };
  }).filter(({ panel }) => panel);
  if (entries.length !== tabs.length || entries.length === 0) return;

  // Set ARIA semantics only after interactivity is confirmed.
  tabContainer.setAttribute('role', 'tablist');
  entries.forEach(({ tab, panel }) => {
    tab.setAttribute('role', 'tab');
    tab.setAttribute('aria-controls', panel.id);
    panel.setAttribute('role', 'tabpanel');
    panel.setAttribute('tabindex', '0');
  });

  let active = 0;
  const lookupIndex = (hash) => entries.findIndex(({ id }) => `#${id}` === hash);

  function updateFilter() {
    const query = searchInput.value.normalize('NFKC').trim().toLocaleLowerCase('ja-JP');
    const questions = [...entries[active].panel.querySelectorAll('.faq')];
    let visible = 0;

    questions.forEach((item) => {
      const content = `${item.querySelector('summary')?.textContent ?? ''} ${item.dataset.search ?? ''} ${item.textContent ?? ''}`
        .normalize('NFKC').toLocaleLowerCase('ja-JP');
      const matches = !query || content.includes(query);
      item.hidden = !matches;
      if (matches) visible += 1;
    });
    noResults.hidden = visible !== 0;
    status.textContent = `${visible}件の質問を表示しています。`;
  }

  function activate(index, { focus = false, syncHash = true } = {}) {
    active = index;
    entries.forEach(({ tab, panel }, i) => {
      const selected = i === index;
      tab.setAttribute('aria-selected', String(selected));
      tab.tabIndex = selected ? 0 : -1;
      panel.hidden = !selected;
    });
    updateFilter();
    if (syncHash) {
      const url = `${location.pathname}${location.search}#${entries[index].id}`;
      try {
        history.replaceState(null, '', url);
      } catch (error) {
        // file:// / sandboxed preview may disallow History API updates.
        // The tab itself must remain functional when URL updates are blocked.
        if (!(error instanceof DOMException && error.name === 'SecurityError')) throw error;
      }
    }
    if (focus) entries[index].tab.focus();
  }

  tabContainer.addEventListener('click', (event) => {
    const anchor = event.target.closest('a[href^="#"]');
    if (!anchor || !tabContainer.contains(anchor)) return;
    const index = entries.findIndex(({ tab }) => tab === anchor);
    if (index < 0) return;
    event.preventDefault(); // never jump below the sticky header
    activate(index);
  });

  tabContainer.addEventListener('keydown', (event) => {
    if (!entries.some(({ tab }) => tab === event.target)) return;
    let next = null;
    if (event.key === 'ArrowRight') next = (active + 1) % entries.length;
    if (event.key === 'ArrowLeft') next = (active - 1 + entries.length) % entries.length;
    if (event.key === 'Home') next = 0;
    if (event.key === 'End') next = entries.length - 1;
    if (next === null) return;
    event.preventDefault();
    activate(next, { focus: true });
  });

  searchInput.addEventListener('input', updateFilter);
  clearButton.addEventListener('click', () => {
    searchInput.value = '';
    updateFilter();
    searchInput.focus();
  });

  const onHashChanged = () => {
    const index = lookupIndex(location.hash);
    if (index !== -1) activate(index, { syncHash: false });
  };
  window.addEventListener('hashchange', onHashChanged);
  window.addEventListener('popstate', onHashChanged);

  // Preserve initial hash, including direct access to a non-default category.
  const initial = lookupIndex(location.hash);
  activate(initial === -1 ? 0 : initial, { syncHash: false });
  searchTools.hidden = false;
  if (printButton && typeof window.print === 'function') {
    printButton.hidden = false;
    printButton.addEventListener('click', () => window.print());
  }

  let printSnapshot = null;
  window.addEventListener('beforeprint', () => {
    printSnapshot = {
      active,
      open: [...document.querySelectorAll('.faq')].map((element) => element.open),
      hidden: [...document.querySelectorAll('.faq')].map((element) => element.hidden),
    };
    entries.forEach(({ panel }) => { panel.hidden = false; });
    document.querySelectorAll('.faq').forEach((element) => {
      element.hidden = false;
      element.open = true;
    });
    noResults.hidden = true;
  });
  window.addEventListener('afterprint', () => {
    if (!printSnapshot) return;
    const questions = [...document.querySelectorAll('.faq')];
    questions.forEach((element, index) => {
      element.open = printSnapshot.open[index];
      element.hidden = printSnapshot.hidden[index];
    });
    activate(printSnapshot.active, { syncHash: false });
    printSnapshot = null;
  });
})();
