import { chromium } from 'playwright';

async function main() {
  const browser = await chromium.launch({
    headless: true,
    args: ['--disable-blink-features=AutomationControlled', '--no-sandbox']
  });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  console.log('--- Analyzing Raycast ---');
  await page.goto('https://www.raycast.com/', { waitUntil: 'domcontentloaded', timeout: 25000 });
  await page.waitForTimeout(2000);

  const raycastData = await page.evaluate(async () => {
    const btn = document.querySelector('a[href*="download"], [class*="download"], [class*="primary"]');
    const beforeBtn = btn ? {
      transform: window.getComputedStyle(btn).transform,
      boxShadow: window.getComputedStyle(btn).boxShadow,
      background: window.getComputedStyle(btn).backgroundColor
    } : null;

    // Check keyboard container & cards
    const card = document.querySelector('[class*="card"], [class*="item"], [class*="key"]');
    const cardStyle = card ? {
      transition: window.getComputedStyle(card).transition,
      transform: window.getComputedStyle(card).transform
    } : null;

    // Check glow layers
    const glows = Array.from(document.querySelectorAll('*')).filter(el => {
      const bg = window.getComputedStyle(el).backgroundImage;
      return bg && (bg.includes('radial-gradient') || bg.includes('conic-gradient'));
    }).map(el => ({
      tag: el.tagName,
      className: el.className.toString().slice(0, 40),
      bg: window.getComputedStyle(el).backgroundImage.slice(0, 80)
    }));

    return { beforeBtn, cardStyle, glowsCount: glows.length, glowsSample: glows.slice(0, 3) };
  });

  console.log('Raycast Data:', JSON.stringify(raycastData, null, 2));

  console.log('\n--- Analyzing Linear ---');
  await page.goto('https://linear.app/', { waitUntil: 'domcontentloaded', timeout: 25000 });
  await page.waitForTimeout(2000);

  const linearData = await page.evaluate(() => {
    // Check spotlight or mouse tracking
    const spotlights = Array.from(document.querySelectorAll('[style*="radial-gradient"], [class*="glow"], [class*="spotlight"]')).map(el => ({
      className: el.className.toString().slice(0, 40),
      style: el.getAttribute('style')
    }));

    // Check hero reveal animations
    const heroElements = Array.from(document.querySelectorAll('h1, [class*="hero"] p, [class*="hero"] button')).map(el => ({
      tag: el.tagName,
      animation: window.getComputedStyle(el).animationName,
      transition: window.getComputedStyle(el).transition,
      transform: window.getComputedStyle(el).transform,
      opacity: window.getComputedStyle(el).opacity
    }));

    return { spotlightsCount: spotlights.length, spotlightsSample: spotlights.slice(0, 3), heroElements };
  });

  console.log('Linear Data:', JSON.stringify(linearData, null, 2));

  await browser.close();
}

main().catch(console.error);
