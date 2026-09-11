import Lenis from 'lenis'
import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

// Modular stylesheets
import './styles/motion-interactive.css'
import './styles/raycast-download.css'
import './styles/raycast-showcase.css'
import './styles/pen-dev-utilities.css'

// Subsystem controllers
import { initKeyboardCanvas } from './components/keyboard-canvas'
import { initHeroSwitcher } from './hero'
import { initShowcaseReel } from './showcase'

gsap.registerPlugin(ScrollTrigger)

// Check for reduced motion preference
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

// ============================================================================
// 1. LENIS SMOOTH SCROLL ENGINE (MOMENTUM & INERTIA)
// ============================================================================
export let lenis: Lenis | null = null

export function initSmoothScroll() {
  if (prefersReducedMotion) return

  lenis = new Lenis({
    duration: 1.0,
    easing: (t: number) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
    orientation: 'vertical',
    gestureOrientation: 'vertical',
    smoothWheel: true,
    wheelMultiplier: 1.0,
    touchMultiplier: 1.5,
  })

  // Synchronize Lenis with GSAP ScrollTrigger
  lenis.on('scroll', ScrollTrigger.update)

  gsap.ticker.add((time: number) => {
    lenis?.raf(time * 1000)
  })
  gsap.ticker.lagSmoothing(0)

  // Smooth scroll for all internal anchor links (e.g. #fitur, #download, #faq)
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener('click', (e) => {
      const href = anchor.getAttribute('href')
      if (!href || href === '#' || href === '#!') return
      const target = document.querySelector(href)
      if (target && lenis) {
        e.preventDefault()
        lenis.scrollTo(target as HTMLElement, {
          offset: -80,
          duration: 0.9,
          easing: (t: number) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
        })
      }
    })
  })
}

// ============================================================================
// 2. SCROLL PROGRESS INDICATOR (MINIMAL TOP GRADIENT BAR)
// ============================================================================
export function initScrollProgressBar() {
  let bar = document.getElementById('awwwards-scroll-progress')
  if (!bar) {
    bar = document.createElement('div')
    bar.id = 'awwwards-scroll-progress'
    bar.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 2.5px;
      background: linear-gradient(90deg, #6ece9d 0%, #ffda6e 50%, #818cf8 100%);
      transform-origin: 0% 50%;
      transform: scaleX(0);
      z-index: 99999;
      pointer-events: none;
      box-shadow: 0 0 8px rgba(110, 206, 157, 0.4);
    `
    document.body.appendChild(bar)
  }

  window.addEventListener('scroll', () => {
    const totalHeight = document.documentElement.scrollHeight - window.innerHeight
    if (totalHeight <= 0) return
    const progress = Math.min(1, Math.max(0, window.scrollY / totalHeight))
    if (bar) {
      bar.style.transform = `scaleX(${progress})`
    }
  }, { passive: true })
}

// ============================================================================
// 3. DRAGGABLE MOMENTUM CAROUSEL REEL TRACK
// ============================================================================
export function initReelDrag() {
  const track = document.getElementById('showcaseTrack')
  if (!track) return

  let isDown = false
  let startX = 0
  let scrollLeft = 0

  track.style.cursor = 'grab'

  track.addEventListener('mousedown', (e) => {
    isDown = true
    track.style.cursor = 'grabbing'
    track.style.scrollBehavior = 'auto'
    startX = e.pageX - track.offsetLeft
    scrollLeft = track.scrollLeft
  })

  window.addEventListener('mouseup', () => {
    if (isDown) {
      isDown = false
      track.style.cursor = 'grab'
      track.style.scrollBehavior = 'smooth'
    }
  })

  track.addEventListener('mousemove', (e) => {
    if (!isDown) return
    e.preventDefault()
    const x = e.pageX - track.offsetLeft
    const walk = (x - startX) * 1.5
    track.scrollLeft = scrollLeft - walk
  })
}

// ============================================================================
// 4. FAQ ACCORDION INTERACTION (FLUID OPEN / CLOSE ON USER CLICK)
// ============================================================================
export function initFaqAccordion() {
  const faqItems = document.querySelectorAll<HTMLDetailsElement>('details.faq-item')
  faqItems.forEach((detail) => {
    const summary = detail.querySelector('summary')
    const answer = detail.querySelector<HTMLElement>('.faq-answer')
    const chevron = detail.querySelector<HTMLElement>('.faq-chevron')

    if (!summary || !answer) return

    summary.addEventListener('click', (e) => {
      e.preventDefault()

      if (detail.open) {
        if (chevron) {
          gsap.to(chevron, { rotate: 0, duration: 0.2, ease: 'power2.out' })
        }
        gsap.to(answer, {
          height: 0,
          opacity: 0,
          duration: 0.2,
          ease: 'power2.inOut',
          onComplete: () => {
            detail.open = false
            answer.style.height = ''
            answer.style.opacity = ''
          },
        })
      } else {
        detail.open = true
        if (chevron) {
          gsap.to(chevron, { rotate: 180, duration: 0.2, ease: 'power2.out' })
        }
        const naturalHeight = answer.scrollHeight
        gsap.fromTo(
          answer,
          { height: 0, opacity: 0 },
          {
            height: naturalHeight,
            opacity: 1,
            duration: 0.2,
            ease: 'power2.out',
            onComplete: () => {
              answer.style.height = ''
            },
          }
        )
      }
    })
  })
}

// ============================================================================
// 5. FAST & SNAPPY PER-COMPONENT SECTION VIEWPORT ENTRANCE
// When a section enters viewport, each component cascades in with a crisp,
// snappy 0.35s fade-and-rise (stagger: 0.05s).
// clearProps: 'all' immediately cleans inline styles upon completion.
// ============================================================================
export function initFastSectionMotion() {
  if (prefersReducedMotion) return

  // 1. HERO SECTION (Above fold: cascades in immediately on load)
  const heroSection = document.querySelector<HTMLElement>('section#hero')
  if (heroSection) {
    const heroElements = [
      heroSection.querySelector('h1'),
      heroSection.querySelector('p'),
      heroSection.querySelector('.actions'),
      heroSection.querySelector('.customers'),
      heroSection.querySelector('figure.image-container'),
    ].filter(Boolean) as HTMLElement[]

    gsap.from(heroElements, {
      y: 18,
      opacity: 0,
      duration: 0.35,
      stagger: 0.06,
      ease: 'power2.out',
      clearProps: 'all',
    })
  }

  // 2. COMPATIBILITY CHIPS BAR
  const compatSection = document.querySelector<HTMLElement>('section.customers')
  if (compatSection) {
    const compatItems = compatSection.querySelectorAll<HTMLElement>('.compat-item')
    if (compatItems.length > 0) {
      gsap.from(compatItems, {
        scrollTrigger: {
          trigger: compatSection,
          start: 'top 88%',
          toggleActions: 'play none none none',
          once: true,
        },
        y: 16,
        opacity: 0,
        duration: 0.32,
        stagger: 0.04,
        ease: 'power2.out',
        clearProps: 'all',
      })
    }
  }

  // 3. RAYCAST DOWNLOAD HUB
  const downloadSection = document.querySelector<HTMLElement>('section#download')
  if (downloadSection) {
    const downloadElements = [
      downloadSection.querySelector('[data-pencil-name="Title Line 1"]'),
      downloadSection.querySelector('[data-pencil-name="Title Line 2"]'),
      downloadSection.querySelector('[data-pencil-name="CTA Buttons Row"]'),
      downloadSection.querySelector('#keyboardCanvas'),
    ].filter(Boolean) as HTMLElement[]

    if (downloadElements.length > 0) {
      gsap.from(downloadElements, {
        scrollTrigger: {
          trigger: downloadSection,
          start: 'top 88%',
          toggleActions: 'play none none none',
          once: true,
        },
        y: 18,
        opacity: 0,
        duration: 0.35,
        stagger: 0.06,
        ease: 'power2.out',
        clearProps: 'all',
      })
    }
  }

  // 4. RAYCAST EXTENSION SHOWCASE REEL (#fitur)
  const fiturSection = document.querySelector<HTMLElement>('section#fitur')
  if (fiturSection) {
    const fiturElements = [
      fiturSection.querySelector('.raycast-title-group'),
      fiturSection.querySelector('.raycast-categories'),
      ...Array.from(fiturSection.querySelectorAll('.raycast-card')),
      fiturSection.querySelector('.raycast-bottom-bar'),
    ].filter(Boolean) as HTMLElement[]

    if (fiturElements.length > 0) {
      gsap.from(fiturElements, {
        scrollTrigger: {
          trigger: fiturSection,
          start: 'top 88%',
          toggleActions: 'play none none none',
          once: true,
        },
        y: 20,
        opacity: 0,
        duration: 0.35,
        stagger: 0.05,
        ease: 'power2.out',
        clearProps: 'all',
      })
    }
  }

  // 5. FAQ ACCORDION SECTION (#faq)
  const faqSection = document.querySelector<HTMLElement>('section#faq')
  if (faqSection) {
    const faqHeader = [
      faqSection.querySelector('.nummeration'),
      faqSection.querySelector('h2'),
      faqSection.querySelector('p'),
    ].filter(Boolean) as HTMLElement[]
    const faqItems = Array.from(faqSection.querySelectorAll<HTMLElement>('details.faq-item'))

    const allFaqElements = [...faqHeader, ...faqItems]
    if (allFaqElements.length > 0) {
      gsap.from(allFaqElements, {
        scrollTrigger: {
          trigger: faqSection,
          start: 'top 88%',
          toggleActions: 'play none none none',
          once: true,
        },
        y: 18,
        opacity: 0,
        duration: 0.35,
        stagger: 0.05,
        ease: 'power2.out',
        clearProps: 'all',
      })
    }
  }

  // 6. CALL TO ACTION BANNER (#cta)
  const ctaSection = document.querySelector<HTMLElement>('section#cta')
  if (ctaSection) {
    const ctaElements = [
      ctaSection.querySelector('h2'),
      ctaSection.querySelector('p'),
      ctaSection.querySelector('.actions'),
    ].filter(Boolean) as HTMLElement[]

    if (ctaElements.length > 0) {
      gsap.from(ctaElements, {
        scrollTrigger: {
          trigger: ctaSection,
          start: 'top 88%',
          toggleActions: 'play none none none',
          once: true,
        },
        y: 18,
        opacity: 0,
        duration: 0.35,
        stagger: 0.06,
        ease: 'power2.out',
        clearProps: 'all',
      })
    }
  }

  // 7. FOOTER SECTION (footer)
  const footerEl = document.querySelector<HTMLElement>('footer')
  if (footerEl) {
    const footerCols = footerEl.querySelectorAll<HTMLElement>('.footer-content ul > li')
    if (footerCols.length > 0) {
      gsap.from(footerCols, {
        scrollTrigger: {
          trigger: footerEl,
          start: 'top 92%',
          toggleActions: 'play none none none',
          once: true,
        },
        y: 16,
        opacity: 0,
        duration: 0.35,
        stagger: 0.05,
        ease: 'power2.out',
        clearProps: 'all',
      })
    }
  }

  // Recalculate trigger coordinates
  ScrollTrigger.refresh()
}

// Backward-compatible alias
export const initSectionViewportMotion = initFastSectionMotion

// ============================================================================
// 6. MASTER INITIALIZER
// ============================================================================
export function initAwwwardsMotion() {
  initKeyboardCanvas()
  initHeroSwitcher()
  initShowcaseReel()
  initSmoothScroll()
  initScrollProgressBar()
  initReelDrag()
  initFaqAccordion()
  initFastSectionMotion()

  // Recalculate triggers after full page load and font hydration
  window.addEventListener('load', () => {
    ScrollTrigger.refresh()
  })
  if (document.fonts?.ready) {
    document.fonts.ready.then(() => {
      ScrollTrigger.refresh()
    })
  }
}

// Auto-run on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initAwwwardsMotion)
} else {
  initAwwwardsMotion()
}
