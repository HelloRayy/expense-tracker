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
    duration: 1.25,
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
          duration: 1.2,
          easing: (t: number) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
        })
      }
    })
  })
}

// ============================================================================
// 2. SCROLL PROGRESS INDICATOR (AWWWARDS TOP GRADIENT BAR)
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
      box-shadow: 0 0 10px rgba(110, 206, 157, 0.5);
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
// 3. AMBIENT CURSOR SPOTLIGHT (HIGH-END DARK THEME GLOW)
// ============================================================================
export function initAmbientSpotlight() {
  if (prefersReducedMotion || window.innerWidth < 768) return

  let spotlight = document.getElementById('awwwards-ambient-spotlight')
  if (!spotlight) {
    spotlight = document.createElement('div')
    spotlight.id = 'awwwards-ambient-spotlight'
    spotlight.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 500px;
      height: 500px;
      border-radius: 50%;
      background: radial-gradient(circle, rgba(110, 206, 157, 0.07) 0%, rgba(129, 140, 248, 0.04) 40%, transparent 70%);
      pointer-events: none;
      z-index: 1;
      transform: translate(-50%, -50%);
      opacity: 0;
      transition: opacity 0.5s ease;
    `
    document.body.appendChild(spotlight)
  }

  let mouseX = -500
  let mouseY = -500
  let currentX = -500
  let currentY = -500

  window.addEventListener('mousemove', (e) => {
    mouseX = e.clientX
    mouseY = e.clientY
    if (spotlight && spotlight.style.opacity === '0') {
      spotlight.style.opacity = '1'
    }
  }, { passive: true })

  document.addEventListener('mouseleave', () => {
    if (spotlight) spotlight.style.opacity = '0'
  })

  // Smooth trailing physics
  function animateSpotlight() {
    currentX += (mouseX - currentX) * 0.12
    currentY += (mouseY - currentY) * 0.12
    if (spotlight) {
      spotlight.style.transform = `translate3d(${currentX - 250}px, ${currentY - 250}px, 0)`
    }
    requestAnimationFrame(animateSpotlight)
  }
  requestAnimationFrame(animateSpotlight)
}

// ============================================================================
// 4. MAGNETIC SPRING BUTTONS (SPRING PHYSICS ON HOVER)
// ============================================================================
export function initMagneticButtons() {
  if (prefersReducedMotion || window.innerWidth < 768) return

  const magneticElements = document.querySelectorAll<HTMLElement>('.button, .raycast-nav-btn, .theme-switch')

  magneticElements.forEach((el) => {
    let boundRect: DOMRect | null = null

    el.addEventListener('mouseenter', () => {
      boundRect = el.getBoundingClientRect()
    })

    el.addEventListener('mousemove', (e) => {
      if (!boundRect) boundRect = el.getBoundingClientRect()
      const x = e.clientX - boundRect.left - boundRect.width / 2
      const y = e.clientY - boundRect.top - boundRect.height / 2

      gsap.to(el, {
        x: x * 0.28,
        y: y * 0.28,
        duration: 0.35,
        ease: 'power3.out',
      })
    })

    el.addEventListener('mouseleave', () => {
      gsap.to(el, {
        x: 0,
        y: 0,
        duration: 0.7,
        ease: 'elastic.out(1.2, 0.4)',
      })
      boundRect = null
    })
  })
}

// ============================================================================
// 5. 3D CARD PERSPECTIVE TILT WITH SPECULAR GLARE
// ============================================================================
export function init3DCardTilt() {
  if (prefersReducedMotion || window.innerWidth < 768) return

  const cards = document.querySelectorAll<HTMLElement>('.raycast-card, .card')

  cards.forEach((card) => {
    let cardRect: DOMRect | null = null

    card.addEventListener('mouseenter', () => {
      cardRect = card.getBoundingClientRect()
    })

    card.addEventListener('mousemove', (e) => {
      if (!cardRect) cardRect = card.getBoundingClientRect()
      const x = e.clientX - cardRect.left
      const y = e.clientY - cardRect.top

      // Calculate percentage for specular gradient
      const percentX = (x / cardRect.width) * 100
      const percentY = (y / cardRect.height) * 100
      card.style.setProperty('--card-mouse-x', `${percentX}%`)
      card.style.setProperty('--card-mouse-y', `${percentY}%`)

      // Perspective tilt rotation (-5 to +5 deg)
      const rotX = ((y / cardRect.height) - 0.5) * -8
      const rotY = ((x / cardRect.width) - 0.5) * 8

      gsap.to(card, {
        rotateX: rotX,
        rotateY: rotY,
        transformPerspective: 1000,
        duration: 0.25,
        ease: 'power2.out',
      })
    })

    card.addEventListener('mouseleave', () => {
      gsap.to(card, {
        rotateX: 0,
        rotateY: 0,
        duration: 0.6,
        ease: 'power3.out',
      })
      cardRect = null
    })
  })
}

// ============================================================================
// 6. DRAGGABLE MOMENTUM CAROUSEL REEL TRACK
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
    const walk = (x - startX) * 1.5 // Drag sensitivity
    track.scrollLeft = scrollLeft - walk
  })
}

// ============================================================================
// 7. HERO MOCKUP AMBIENT FLOATING & PULSE
// ============================================================================
export function initHeroFloating() {
  if (prefersReducedMotion) return

  const heroFigure = document.querySelector('section.hero figure')
  if (heroFigure) {
    gsap.to(heroFigure, {
      y: -8,
      duration: 3,
      repeat: -1,
      yoyo: true,
      ease: 'sine.inOut',
    })
  }

  // Ambient gradient glow breathing
  const gradients = document.querySelectorAll('.theme-dark .gradient-container .gradient')
  gradients.forEach((grad) => {
    gsap.to(grad, {
      scale: 1.05,
      opacity: 0.18,
      duration: 4,
      repeat: -1,
      yoyo: true,
      ease: 'sine.inOut',
    })
  })
}

// ============================================================================
// 8. SECTION VIEWPORT ENTRANCE MOTION (STAGGERED KINETIC CASCADE PER SECTION)
// ============================================================================
export function initSectionViewportMotion() {
  if (prefersReducedMotion) return

  // --------------------------------------------------------------------------
  // SECTION: HERO
  // --------------------------------------------------------------------------
  const heroSection = document.querySelector<HTMLElement>('section#hero')
  if (heroSection) {
    const heroH1 = heroSection.querySelector('h1')
    const heroSubtitle = heroSection.querySelector('p')
    const heroActions = heroSection.querySelector('.actions')
    const heroCustomers = heroSection.querySelector('.customers')
    const heroMockup = heroSection.querySelector('figure.image-container')

    const heroTl = gsap.timeline({ defaults: { ease: 'power4.out' } })
    if (heroH1) heroTl.from(heroH1, { y: 45, opacity: 0, duration: 1.0 }, 0.1)
    if (heroSubtitle) heroTl.from(heroSubtitle, { y: 30, opacity: 0, duration: 0.95 }, 0.22)
    if (heroActions) heroTl.from(heroActions, { y: 25, opacity: 0, scale: 0.95, duration: 0.85, ease: 'back.out(1.4)' }, 0.35)
    if (heroCustomers) heroTl.from(heroCustomers, { y: 20, opacity: 0, duration: 0.8 }, 0.48)
    if (heroMockup) heroTl.from(heroMockup, { y: 65, opacity: 0, scale: 0.93, duration: 1.15, ease: 'power3.out' }, 0.38)
  }

  // --------------------------------------------------------------------------
  // SECTION: COMPATIBILITY / FEATURE BADGES
  // --------------------------------------------------------------------------
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
        y: 35,
        opacity: 0,
        scale: 0.88,
        stagger: 0.12,
        duration: 0.85,
        ease: 'back.out(1.6)',
      })
    }
  }

  // --------------------------------------------------------------------------
  // SECTION: RAYCAST DOWNLOAD HUB & KEYBOARD CANVAS (#download)
  // --------------------------------------------------------------------------
  const downloadSection = document.querySelector<HTMLElement>('section#download')
  if (downloadSection) {
    const downloadCard = downloadSection.querySelector<HTMLElement>('[data-pencil-name="div"]')
    const titleLine1 = downloadSection.querySelector<HTMLElement>('[data-pencil-name="Title Line 1"]')
    const titleLine2 = downloadSection.querySelector<HTMLElement>('[data-pencil-name="Title Line 2"]')
    const downloadButtons = downloadSection.querySelectorAll<HTMLElement>('[data-pencil-name="CTA Buttons Row"] a')
    const keyboardKeys = downloadSection.querySelectorAll<HTMLElement>('#keyboardCanvas [data-pencil-name="div"]')

    const downloadTl = gsap.timeline({
      scrollTrigger: {
        trigger: downloadSection,
        start: 'top 82%',
        toggleActions: 'play none none none',
        once: true,
      },
    })

    if (downloadCard) {
      downloadTl.from(downloadCard, {
        y: 50,
        opacity: 0,
        scale: 0.96,
        duration: 1.0,
        ease: 'power4.out',
      }, 0)
    }

    if (titleLine1) {
      downloadTl.from(titleLine1, {
        y: 30,
        opacity: 0,
        duration: 0.8,
        ease: 'power3.out',
      }, 0.2)
    }

    if (titleLine2) {
      downloadTl.from(titleLine2, {
        y: 30,
        opacity: 0,
        duration: 0.8,
        ease: 'power3.out',
      }, 0.32)
    }

    if (downloadButtons.length > 0) {
      downloadTl.from(downloadButtons, {
        y: 20,
        opacity: 0,
        scale: 0.9,
        stagger: 0.12,
        duration: 0.75,
        ease: 'back.out(1.5)',
      }, 0.44)
    }

    // Aesthetic wave light-up effect on physical keycaps
    if (keyboardKeys.length > 0) {
      downloadTl.from(keyboardKeys, {
        y: 20,
        opacity: 0,
        stagger: {
          amount: 0.6,
          from: 'start',
        },
        duration: 0.75,
        ease: 'power3.out',
      }, 0.25)
    }
  }

  // --------------------------------------------------------------------------
  // SECTION: RAYCAST EXTENSION HIGHLIGHT REEL & CATEGORIES (#fitur)
  // --------------------------------------------------------------------------
  const fiturSection = document.querySelector<HTMLElement>('section#fitur')
  if (fiturSection) {
    const sectionCard = fiturSection.querySelector<HTMLElement>('.raycast-section-card')
    const titleH2 = fiturSection.querySelector<HTMLElement>('.raycast-title-group h2')
    const titleP = fiturSection.querySelector<HTMLElement>('.raycast-title-group p')
    const categoriesBar = fiturSection.querySelector<HTMLElement>('.raycast-categories')
    const categoryPills = fiturSection.querySelectorAll<HTMLElement>('.raycast-category-pill')
    const reelCards = fiturSection.querySelectorAll<HTMLElement>('.raycast-card')
    const bottomBar = fiturSection.querySelector<HTMLElement>('.raycast-bottom-bar')

    const fiturTl = gsap.timeline({
      scrollTrigger: {
        trigger: fiturSection,
        start: 'top 80%',
        toggleActions: 'play none none none',
        once: true,
      },
    })

    if (sectionCard) {
      fiturTl.from(sectionCard, {
        y: 50,
        opacity: 0,
        duration: 0.95,
        ease: 'power4.out',
      }, 0)
    }

    if (titleH2) {
      fiturTl.from(titleH2, {
        y: 35,
        opacity: 0,
        duration: 0.85,
        ease: 'power3.out',
      }, 0.15)
    }

    if (titleP) {
      fiturTl.from(titleP, {
        y: 25,
        opacity: 0,
        duration: 0.85,
        ease: 'power3.out',
      }, 0.25)
    }

    if (categoriesBar) {
      fiturTl.from(categoriesBar, {
        scale: 0.92,
        opacity: 0,
        y: 20,
        duration: 0.75,
        ease: 'back.out(1.5)',
      }, 0.25)
    }

    if (categoryPills.length > 0) {
      fiturTl.from(categoryPills, {
        opacity: 0,
        y: 10,
        stagger: 0.06,
        duration: 0.5,
        ease: 'power2.out',
      }, 0.35)
    }

    if (reelCards.length > 0) {
      fiturTl.from(reelCards, {
        y: 60,
        opacity: 0,
        scale: 0.93,
        stagger: 0.14,
        duration: 1.0,
        ease: 'power4.out',
      }, 0.42)
    }

    if (bottomBar) {
      fiturTl.from(bottomBar, {
        y: 25,
        opacity: 0,
        duration: 0.8,
        ease: 'power3.out',
      }, 0.68)
    }
  }

  // --------------------------------------------------------------------------
  // SECTION: FAQ ACCORDION SECTION (#faq)
  // --------------------------------------------------------------------------
  const faqSection = document.querySelector<HTMLElement>('section#faq')
  if (faqSection) {
    const nummeration = faqSection.querySelector<HTMLElement>('.nummeration')
    const faqTitle = faqSection.querySelector<HTMLElement>('h2')
    const faqDesc = faqSection.querySelector<HTMLElement>('p')
    const faqItems = faqSection.querySelectorAll<HTMLDetailsElement>('details.faq-item')

    const faqTl = gsap.timeline({
      scrollTrigger: {
        trigger: faqSection,
        start: 'top 82%',
        toggleActions: 'play none none none',
        once: true,
      },
    })

    if (nummeration) {
      faqTl.from(nummeration, {
        scale: 0.85,
        opacity: 0,
        y: 20,
        duration: 0.65,
        ease: 'back.out(1.7)',
      }, 0)
    }

    if (faqTitle) {
      faqTl.from(faqTitle, {
        y: 30,
        opacity: 0,
        duration: 0.8,
        ease: 'power3.out',
      }, 0.15)
    }

    if (faqDesc) {
      faqTl.from(faqDesc, {
        y: 25,
        opacity: 0,
        duration: 0.8,
        ease: 'power3.out',
      }, 0.25)
    }

    if (faqItems.length > 0) {
      faqTl.from(faqItems, {
        y: 35,
        opacity: 0,
        stagger: 0.1,
        duration: 0.8,
        ease: 'power3.out',
      }, 0.35)
    }

    // Fluid height transition for details accordion
    faqItems.forEach((detail) => {
      const summary = detail.querySelector('summary')
      const answer = detail.querySelector<HTMLElement>('.faq-answer')
      const chevron = detail.querySelector('.faq-chevron')

      if (summary && answer) {
        summary.addEventListener('click', (e) => {
          if (detail.open) {
            // Animating close
            e.preventDefault()
            if (chevron) {
              gsap.to(chevron, { rotate: 0, duration: 0.3, ease: 'power2.out' })
            }
            gsap.to(answer, {
              height: 0,
              opacity: 0,
              duration: 0.3,
              ease: 'power2.inOut',
              onComplete: () => {
                detail.open = false
                answer.style.height = ''
                answer.style.opacity = ''
              },
            })
          } else {
            // Animating open
            if (chevron) {
              gsap.to(chevron, { rotate: 180, duration: 0.35, ease: 'back.out(1.7)' })
            }
            const naturalHeight = answer.scrollHeight
            gsap.fromTo(
              answer,
              { height: 0, opacity: 0 },
              {
                height: naturalHeight,
                opacity: 1,
                duration: 0.4,
                ease: 'power3.out',
                onComplete: () => {
                  answer.style.height = ''
                },
              }
            )
          }
        })
      }
    })
  }

  // --------------------------------------------------------------------------
  // SECTION: CALL TO ACTION BANNER (#cta)
  // --------------------------------------------------------------------------
  const ctaSection = document.querySelector<HTMLElement>('section#cta')
  if (ctaSection) {
    const ctaContent = ctaSection.querySelector<HTMLElement>('.section-content')
    const ctaH2 = ctaSection.querySelector<HTMLElement>('h2')
    const ctaP = ctaSection.querySelector<HTMLElement>('p')
    const ctaActions = ctaSection.querySelectorAll<HTMLElement>('.actions a')
    const ctaImgs = ctaSection.querySelectorAll<HTMLElement>('.cta-background')

    const ctaTl = gsap.timeline({
      scrollTrigger: {
        trigger: ctaSection,
        start: 'top 82%',
        toggleActions: 'play none none none',
        once: true,
      },
    })

    if (ctaContent) {
      ctaTl.from(ctaContent, {
        scale: 0.95,
        y: 45,
        opacity: 0,
        duration: 0.95,
        ease: 'power4.out',
      }, 0)
    }

    if (ctaImgs.length > 0) {
      ctaTl.from(ctaImgs, {
        scale: 1.15,
        opacity: 0,
        duration: 1.2,
        ease: 'power2.out',
      }, 0)
    }

    if (ctaH2) {
      ctaTl.from(ctaH2, {
        y: 30,
        opacity: 0,
        duration: 0.8,
        ease: 'power3.out',
      }, 0.2)
    }

    if (ctaP) {
      ctaTl.from(ctaP, {
        y: 25,
        opacity: 0,
        duration: 0.8,
        ease: 'power3.out',
      }, 0.32)
    }

    if (ctaActions.length > 0) {
      ctaTl.from(ctaActions, {
        scale: 0.88,
        y: 20,
        opacity: 0,
        stagger: 0.12,
        duration: 0.75,
        ease: 'back.out(1.5)',
      }, 0.44)
    }
  }

  // --------------------------------------------------------------------------
  // SECTION: FOOTER VIEWPORT ENTRANCE (footer)
  // --------------------------------------------------------------------------
  const footerEl = document.querySelector<HTMLElement>('footer')
  if (footerEl) {
    const footerCols = footerEl.querySelectorAll<HTMLElement>('.footer-content li')
    if (footerCols.length > 0) {
      gsap.from(footerCols, {
        scrollTrigger: {
          trigger: footerEl,
          start: 'top 92%',
          toggleActions: 'play none none none',
          once: true,
        },
        y: 30,
        opacity: 0,
        stagger: 0.1,
        duration: 0.8,
        ease: 'power3.out',
      })
    }
  }

  // Recalculate trigger coordinates
  ScrollTrigger.refresh()
}

// ============================================================================
// 9. MASTER INITIALIZER
// ============================================================================
export function initAwwwardsMotion() {
  initKeyboardCanvas()
  initHeroSwitcher()
  initShowcaseReel()
  initSmoothScroll()
  initScrollProgressBar()
  initAmbientSpotlight()
  initMagneticButtons()
  init3DCardTilt()
  initReelDrag()
  initHeroFloating()
  initSectionViewportMotion()

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
