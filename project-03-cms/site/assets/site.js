(() => {
  'use strict';
  const button = document.querySelector('#print-btn');
  if (button && typeof window.print === 'function') {
    button.hidden = false;
    button.addEventListener('click', () => window.print());
  }
})();
