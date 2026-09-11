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
// 8. KINETIC SCROLLTRIGGER REVEALS & PARALLAX
// ============================================================================
export function initScrollTriggerAnimations() {
  if (prefersReducedMotion) return

  // Hero section reveal
  const heroH1 = document.querySelector('section.hero h1, section.hero .h1, section.hero h2')
  if (heroH1) {
    gsap.from(heroH1, {
      y: 45,
      opacity: 0,
      duration: 1.1,
      ease: 'power4.out',
      delay: 0.1,
    })
  }

  const heroSubtitle = document.querySelector('section.hero p')
  if (heroSubtitle) {
    gsap.from(heroSubtitle, {
      y: 30,
      opacity: 0,
      duration: 1.0,
      ease: 'power3.out',
      delay: 0.25,
    })
  }

  const heroActions = document.querySelector('section.hero .actions')
  if (heroActions) {
    gsap.from(heroActions, {
      y: 25,
      opacity: 0,
      scale: 0.96,
      duration: 0.9,
      ease: 'power3.out',
      delay: 0.4,
    })
  }

  // Section Headers Reveal
  const sectionHeaders = document.querySelectorAll('section:not(.hero) h2, .raycast-title-group h2')
  sectionHeaders.forEach((header) => {
    gsap.from(header, {
      scrollTrigger: {
        trigger: header,
        start: 'top 88%',
        toggleActions: 'play none none none',
      },
      y: 35,
      opacity: 0,
      duration: 0.9,
      ease: 'power3.out',
    })
  })

  // Raycast Cards Stagger Kinetic Entrance
  const raycastCards = document.querySelectorAll('.raycast-card')
  if (raycastCards.length > 0) {
    gsap.from(raycastCards, {
      scrollTrigger: {
        trigger: '#showcaseTrack',
        start: 'top 82%',
        toggleActions: 'play none none none',
      },
      y: 60,
      opacity: 0,
      scale: 0.94,
      stagger: 0.12,
      duration: 1.0,
      ease: 'power4.out',
    })
  }

  // FAQ Accordions Smooth Stagger & Fluid Spring Open
  const faqItems = document.querySelectorAll<HTMLDetailsElement>('details.faq-item')
  if (faqItems.length > 0) {
    gsap.from(faqItems, {
      scrollTrigger: {
        trigger: '.faq-accordion-container',
        start: 'top 85%',
        toggleActions: 'play none none none',
      },
      y: 25,
      opacity: 0,
      stagger: 0.08,
      duration: 0.75,
      ease: 'power3.out',
    })

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
  initScrollTriggerAnimations()
}

// Auto-run on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initAwwwardsMotion)
} else {
  initAwwwardsMotion()
}
