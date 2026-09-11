import keyboardHtml from './keyboard.html?raw';

/**
 * Injects the authentic 1:1 Raycast physical keycaps canvas background into the download card
 * and initializes tactile key interactions.
 * Decomposes 1,770+ lines of decorative keyboard SVG markup out of index.html for maximum maintainability.
 */
export function initKeyboardCanvas(): void {
  const container = document.getElementById('keyboardCanvas');
  if (!container) return;

  if (!container.hasChildNodes() || container.innerHTML.trim() === '') {
    container.innerHTML = keyboardHtml;
  }

  // Tactile keycap hover & press interactions
  const keys = container.querySelectorAll<HTMLElement>('[data-pencil-name="div"]');
  keys.forEach(key => {
    key.style.cursor = 'pointer';
    key.style.transition = 'transform 0.15s ease, opacity 0.2s ease, box-shadow 0.2s ease';

    key.addEventListener('mouseenter', () => {
      if (parseFloat(window.getComputedStyle(key).opacity) <= 0.3) {
        key.style.opacity = '0.5';
      }
      key.style.transform = 'translateY(-2px) scale(1.03)';
    });

    key.addEventListener('mouseleave', () => {
      if (parseFloat(key.style.opacity) === 0.5) {
        key.style.opacity = '';
      }
      key.style.transform = '';
    });

    key.addEventListener('mousedown', () => {
      key.style.transform = 'translateY(1px) scale(0.96)';
    });

    key.addEventListener('mouseup', () => {
      key.style.transform = 'translateY(-2px) scale(1.03)';
    });
  });
}
