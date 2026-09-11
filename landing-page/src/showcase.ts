/**
 * Raycast Extension Highlight Reel & Categories Capsule Pill Controller.
 * Manages category pills, sliding active backdrop physics, and track scroll synchronization.
 */

export function updateActiveBackdrop(pillEl?: HTMLElement | null): void {
  const backdrop = document.getElementById('activeBackdrop');
  if (!backdrop || !pillEl) return;
  backdrop.style.width = `${pillEl.offsetWidth}px`;
  backdrop.style.transform = `translate3d(${pillEl.offsetLeft}px, 0, 0)`;
}

export function selectShowcaseCategory(
  scrollPos: number,
  pillIndex: number,
  pillEl?: HTMLElement | null
): void {
  const track = document.getElementById('showcaseTrack');
  const cards = document.querySelectorAll<HTMLElement>('.raycast-card');
  if (track) {
    const targetPos =
      cards && cards[pillIndex]
        ? cards[pillIndex].offsetLeft - cards[0].offsetLeft
        : scrollPos;
    track.scrollTo({ left: targetPos, behavior: 'smooth' });
  }

  const pills = document.querySelectorAll<HTMLElement>('.raycast-category-pill');
  pills.forEach(p => p.classList.remove('active'));

  if (pillEl) {
    pillEl.classList.add('active');
    updateActiveBackdrop(pillEl);
  }
}

export function scrollShowcaseStep(direction: number): void {
  const track = document.getElementById('showcaseTrack');
  if (track) {
    const step = 372; // 360px card + 12px gap
    track.scrollBy({ left: direction * step, behavior: 'smooth' });
  }
}

export function initShowcaseReel(): void {
  // Expose on window for backward compatibility with onclick attributes
  const w = window as unknown as {
    selectShowcaseCategory: typeof selectShowcaseCategory;
    scrollShowcaseStep: typeof scrollShowcaseStep;
    updateActiveBackdrop: typeof updateActiveBackdrop;
  };
  w.selectShowcaseCategory = selectShowcaseCategory;
  w.scrollShowcaseStep = scrollShowcaseStep;
  w.updateActiveBackdrop = updateActiveBackdrop;

  // Initialize active backdrop
  const activePill = document.querySelector<HTMLElement>('.raycast-category-pill.active');
  if (activePill) {
    // Immediate and delayed measurement for font loading
    updateActiveBackdrop(activePill);
    setTimeout(() => updateActiveBackdrop(activePill), 100);
  }

  // Handle window resize
  window.addEventListener('resize', () => {
    const currentActive = document.querySelector<HTMLElement>('.raycast-category-pill.active');
    if (currentActive) {
      updateActiveBackdrop(currentActive);
    }
  });

  // Track scroll observer: sync active category pill when user drags/scrolls track
  const track = document.getElementById('showcaseTrack');
  if (track) {
    let scrollTimeout: number | undefined;
    track.addEventListener(
      'scroll',
      () => {
        if (scrollTimeout) clearTimeout(scrollTimeout);
        scrollTimeout = window.setTimeout(() => {
          const cards = document.querySelectorAll<HTMLElement>('.raycast-card');
          const pills = document.querySelectorAll<HTMLElement>('.raycast-category-pill');
          if (!cards.length || !pills.length) return;

          const scrollLeft = track.scrollLeft;
          let closestIndex = 0;
          let minDiff = Infinity;

          cards.forEach((card, idx) => {
            const cardOffset = card.offsetLeft - cards[0].offsetLeft;
            const diff = Math.abs(cardOffset - scrollLeft);
            if (diff < minDiff) {
              minDiff = diff;
              closestIndex = idx;
            }
          });

          if (pills[closestIndex] && !pills[closestIndex].classList.contains('active')) {
            pills.forEach(p => p.classList.remove('active'));
            pills[closestIndex].classList.add('active');
            updateActiveBackdrop(pills[closestIndex]);
          }
        }, 80);
      },
      { passive: true }
    );
  }
}
