import Lenis from 'lenis'
import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

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
      width: 600px;
      height: 600px;
      margin-left: -300px;
      margin-top: -300px;
      border-radius: 50%;
      background: radial-gradient(circle, rgba(110, 206, 157, 0.08) 0%, rgba(129, 140, 248, 0.03) 40%, transparent 70%);
      pointer-events: none;
      z-index: 1;
      opacity: 0;
      transition: opacity 0.6s ease;
      will-change: transform;
    `
    document.body.appendChild(spotlight)
  }

  let mouseX = window.innerWidth / 2
  let mouseY = window.innerHeight / 2
  let curX = mouseX
  let curY = mouseY
  let active = false

  window.addEventListener('mousemove', (e) => {
    mouseX = e.clientX
    mouseY = e.clientY
    if (!active && spotlight) {
      active = true
      spotlight.style.opacity = '1'
    }
  }, { passive: true })

  window.addEventListener('mouseleave', () => {
    if (spotlight) spotlight.style.opacity = '0'
    active = false
  })

  // Smooth lerp loop for the cursor spotlight
  function loop() {
    curX += (mouseX - curX) * 0.08
    curY += (mouseY - curY) * 0.08
    if (spotlight) {
      spotlight.style.transform = `translate3d(${curX}px, ${curY}px, 0)`
    }
    requestAnimationFrame(loop)
  }
  requestAnimationFrame(loop)
}

// ============================================================================
// 4. MAGNETIC BUTTONS & LINKS (SPRING MICRO-INTERACTION)
// ============================================================================
export function initMagneticButtons() {
  if (prefersReducedMotion || window.innerWidth < 1024) return

  const magneticTargets = document.querySelectorAll<HTMLElement>(
    'button:not(.theme-switch), .button, .raycast-browse-link, a.card, .raycast-category-pill, [data-pencil-name="Download Button"]'
  )

  magneticTargets.forEach((el) => {
    el.style.willChange = 'transform'

    el.addEventListener('mousemove', (e) => {
      const rect = el.getBoundingClientRect()
      const centerX = rect.left + rect.width / 2
      const centerY = rect.top + rect.height / 2
      const deltaX = (e.clientX - centerX) * 0.22
      const deltaY = (e.clientY - centerY) * 0.22

      gsap.to(el, {
        x: deltaX,
        y: deltaY,
        duration: 0.35,
        ease: 'power3.out',
      })
    })

    el.addEventListener('mouseleave', () => {
      gsap.to(el, {
        x: 0,
        y: 0,
        duration: 0.7,
        ease: 'elastic.out(1, 0.4)',
      })
    })
  })
}

// ============================================================================
// 5. 3D PERSPECTIVE TILT & SPECULAR GLARE ON CARDS
// ============================================================================
export function init3DCardTilt() {
  if (prefersReducedMotion || window.innerWidth < 1024) return

  const cards = document.querySelectorAll<HTMLElement>(
    '.raycast-card, .card, .faq-item, [data-pencil-name="Download Section Content"]'
  )

  cards.forEach((card) => {
    card.style.transformStyle = 'preserve-3d'
    card.style.perspective = '1000px'
    card.style.willChange = 'transform, box-shadow'

    card.addEventListener('mousemove', (e) => {
      const rect = card.getBoundingClientRect()
      const x = e.clientX - rect.left
      const y = e.clientY - rect.top
      const centerX = rect.width / 2
      const centerY = rect.height / 2

      const rotateX = ((y - centerY) / centerY) * -5
      const rotateY = ((x - centerX) / centerX) * 5

      gsap.to(card, {
        rotateX: rotateX,
        rotateY: rotateY,
        scale: 1.015,
        duration: 0.35,
        ease: 'power2.out',
        transformPerspective: 1000,
      })

      // Pass coordinates for dynamic CSS specular border/glare
      card.style.setProperty('--card-mouse-x', `${x}px`)
      card.style.setProperty('--card-mouse-y', `${y}px`)
    })

    card.addEventListener('mouseleave', () => {
      gsap.to(card, {
        rotateX: 0,
        rotateY: 0,
        scale: 1,
        duration: 0.6,
        ease: 'power3.out',
      })
    })
  })
}

// ============================================================================
// 6. DRAGGABLE REEL TRACK WITH MOMENTUM (DESKTOP HORIZONTAL DRAG)
// ============================================================================
export function initReelDrag() {
  const track = document.getElementById('showcaseTrack') as HTMLElement | null
  if (!track) return

  let isDown = false
  let startX = 0
  let scrollLeft = 0
  let velocity = 0
  let lastX = 0
  let lastTime = 0

  track.style.cursor = 'grab'
  track.style.userSelect = 'none'

  track.addEventListener('mousedown', (e) => {
    // Only left click
    if (e.button !== 0) return
    isDown = true
    track.style.cursor = 'grabbing'
    track.style.scrollBehavior = 'auto' // Instant tracking while dragging
    startX = e.pageX - track.offsetLeft
    scrollLeft = track.scrollLeft
    lastX = e.pageX
    lastTime = performance.now()
    velocity = 0
  })

  window.addEventListener('mouseup', () => {
    if (!isDown) return
    isDown = false
    track.style.cursor = 'grab'
    track.style.scrollBehavior = 'smooth'

    // Apply momentum glide
    if (Math.abs(velocity) > 0.25) {
      const momentumTarget = track.scrollLeft - velocity * 180
      track.scrollTo({ left: momentumTarget, behavior: 'smooth' })
    }
  })

  track.addEventListener('mousemove', (e) => {
    if (!isDown) return
    e.preventDefault()
    const now = performance.now()
    const dt = Math.max(1, now - lastTime)
    const x = e.pageX - track.offsetLeft
    const walk = (x - startX) * 1.3
    const deltaX = e.pageX - lastX

    velocity = deltaX / dt
    lastX = e.pageX
    lastTime = now

    track.scrollLeft = scrollLeft - walk
  })
}

// ============================================================================
// 7. KEYBOARD CANVAS TACTILE PRESS & PARALLAX
// ============================================================================
export function initKeyboardCanvas() {
  const keys = document.querySelectorAll<HTMLElement>('.GetYourTimeBack-module__o1EREW__keyboard [data-pencil-name="div"]')
  keys.forEach((key) => {
    key.style.cursor = 'pointer'
    key.style.transition = 'transform 0.15s ease, opacity 0.2s ease, box-shadow 0.2s ease'

    key.addEventListener('mouseenter', () => {
      if (parseFloat(window.getComputedStyle(key).opacity) <= 0.3) {
        key.style.opacity = '0.5'
      }
      key.style.transform = 'translateY(-2px) scale(1.03)'
    })

    key.addEventListener('mouseleave', () => {
      if (parseFloat(key.style.opacity) === 0.5) {
        key.style.opacity = ''
      }
      key.style.transform = ''
    })

    key.addEventListener('mousedown', () => {
      key.style.transform = 'translateY(1px) scale(0.96)'
    })

    key.addEventListener('mouseup', () => {
      key.style.transform = 'translateY(-2px) scale(1.03)'
    })
  })
}

// ============================================================================
// 8. HERO MOCKUP AMBIENT FLOATING & PULSE
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
// 9. KINETIC SCROLLTRIGGER REVEALS & PARALLAX
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

  // Section titles masked slide-in
  const sectionHeaders = document.querySelectorAll('section:not(.hero) .nummeration, section:not(.hero) h2')
  sectionHeaders.forEach((el) => {
    gsap.from(el, {
      scrollTrigger: {
        trigger: el,
        start: 'top 88%',
        toggleActions: 'play none none none',
      },
      y: 35,
      opacity: 0,
      duration: 0.85,
      ease: 'power3.out',
    })
  })

  // Raycast Extension Highlight Section Cards Entrance
  const raycastCards = document.querySelectorAll('.raycast-card')
  if (raycastCards.length > 0) {
    gsap.from(raycastCards, {
      scrollTrigger: {
        trigger: '#fitur',
        start: 'top 75%',
        toggleActions: 'play none none none',
      },
      y: 50,
      opacity: 0,
      stagger: 0.08,
      duration: 0.9,
      ease: 'power3.out',
    })
  }

  // FAQ Details Accordion Smooth Open/Close Animation
  const faqDetails = document.querySelectorAll<HTMLDetailsElement>('.faq-item')
  faqDetails.forEach((detail) => {
    const summary = detail.querySelector('.faq-question') as HTMLElement | null
    const answer = detail.querySelector('.faq-answer') as HTMLElement | null
    const chevron = detail.querySelector('.faq-chevron') as HTMLElement | null

    if (summary && answer) {
      summary.addEventListener('click', (e) => {
        e.preventDefault()

        const isOpen = detail.hasAttribute('open')

        if (isOpen) {
          // Animate closing
          if (chevron) {
            gsap.to(chevron, { rotate: 0, duration: 0.35, ease: 'power2.out' })
          }
          gsap.to(answer, {
            height: 0,
            opacity: 0,
            duration: 0.35,
            ease: 'power3.inOut',
            onComplete: () => {
              detail.removeAttribute('open')
              answer.style.height = ''
              answer.style.opacity = ''
            },
          })
        } else {
          // Open
          detail.setAttribute('open', '')
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

// ============================================================================
// 10. MASTER INITIALIZER
// ============================================================================
export function initAwwwardsMotion() {
  initSmoothScroll()
  initScrollProgressBar()
  initAmbientSpotlight()
  initMagneticButtons()
  init3DCardTilt()
  initReelDrag()
  initKeyboardCanvas()
  initHeroFloating()
  initScrollTriggerAnimations()
}

// Auto-run on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initAwwwardsMotion)
} else {
  initAwwwardsMotion()
}
