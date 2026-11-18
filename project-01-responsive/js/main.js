(() => {
  'use strict';
  // 印刷ボタンは JavaScript が有効なときだけ表示する。
  const printButton = document.querySelector('#print-page');
  if (!printButton || typeof window.print !== 'function') return;

  printButton.hidden = false;
  printButton.addEventListener('click', () => window.print());

  // <details> が閉じたまま印刷されないように一時的に展開する。
  const details = [...document.querySelectorAll('.faq details')];
  let previousStates = [];
  window.addEventListener('beforeprint', () => {
    previousStates = details.map((element) => element.open);
    details.forEach((element) => { element.open = true; });
  });
  window.addEventListener('afterprint', () => {
    details.forEach((element, index) => { element.open = previousStates[index] ?? false; });
  });
})();
