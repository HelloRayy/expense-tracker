/**
 * Hero section preview screen switcher.
 * Handles switching between Overview, Breakdown, Funnels, and Sessions screens.
 */
export function switchImage(imageClass: string): void {
  const images = document.querySelectorAll<HTMLElement>('.image-container .image');
  const clickAreas = document.querySelectorAll<HTMLElement>('.click-area');

  images.forEach(image => {
    if (image.classList.contains(imageClass)) {
      image.style.display = 'block';
    } else {
      image.style.display = 'none';
    }
  });

  clickAreas.forEach(area => {
    if (area.classList.contains(`area-${imageClass.slice(-1)}`)) {
      area.style.visibility = 'hidden';
      area.style.userSelect = 'none';
    } else {
      area.style.visibility = 'visible';
      area.style.userSelect = 'auto';
    }
  });
}

export function initHeroSwitcher(): void {
  // Expose on window for backward compatibility with existing markup
  (window as unknown as { switchImage: typeof switchImage }).switchImage = switchImage;

  // Modern event-delegation fallback
  document.querySelectorAll<HTMLElement>('.click-area').forEach(area => {
    area.addEventListener('click', () => {
      const match = area.className.match(/area-(\d+)/);
      if (match) {
        switchImage(`image-${match[1]}`);
      }
    });
  });
}
