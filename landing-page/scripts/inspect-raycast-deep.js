import { chromium } from 'playwright';
import fs from 'fs';

async function main() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1546, height: 829 } });

  await page.goto('https://www.raycast.com/', { waitUntil: 'domcontentloaded', timeout: 20000 });
  await page.waitForTimeout(2000);

  // Scroll to section
  await page.evaluate(() => {
    const el = document.querySelector('[class*="GetYourTimeBack-module__o1EREW__container"]');
    if (el) el.scrollIntoView();
  });
  await page.waitForTimeout(1500);

  // Take screenshot of container
  const container = await page.$('[class*="GetYourTimeBack-module__o1EREW__container"]');
  if (container) {
    await container.screenshot({ path: 'raycast-live-section.png' });
  }

  const result = await page.evaluate(() => {
    const root = document.querySelector('[class*="GetYourTimeBack-module__o1EREW__container"]');
    if (!root) return null;

    const inner = root.querySelector('[class*="GetYourTimeBack-module__o1EREW__getYourTimeBack"]');
    const textCol = inner.children[0];
    const kbCol = inner.children[1];

    function getCss(el) {
      if (!el) return null;
      const s = window.getComputedStyle(el);
      return {
        tag: el.tagName,
        class: el.className,
        width: s.width,
        height: s.height,
        display: s.display,
        gap: s.gap,
        padding: s.padding,
        margin: s.margin,
        background: s.background,
        backgroundColor: s.backgroundColor,
        backgroundImage: s.backgroundImage,
        color: s.color,
        fontFamily: s.fontFamily,
        fontSize: s.fontSize,
        fontWeight: s.fontWeight,
        lineHeight: s.lineHeight,
        letterSpacing: s.letterSpacing,
        borderRadius: s.borderRadius,
        border: s.border,
        boxShadow: s.boxShadow,
        opacity: s.opacity,
        maskImage: s.maskImage,
        webkitMaskImage: s.webkitMaskImage,
        transform: s.transform,
      };
    }

    // Inspect heading and paragraph
    const h2 = textCol.querySelector('h2');
    const p = textCol.querySelector('p');
    const btn = textCol.querySelector('a');

    // Inspect a normal key and the 4 featured keys
    const allKeys = Array.from(kbCol.querySelectorAll('[class*="key"]'));
    const normalKey = allKeys.find(k => k.innerText.trim() === 'E');
    const fastKey = allKeys.find(k => k.innerText.includes('Fast'));
    const ergoKey = allKeys.find(k => k.innerText.includes('Ergonomic'));
    const personalKey = allKeys.find(k => k.innerText.includes('Personal'));
    const reliableKey = allKeys.find(k => k.innerText.includes('Reliable'));

    // Extract all SVGs in keys
    const svgs = allKeys.filter(k => k.querySelector('svg')).map(k => ({
      keyText: k.innerText.trim().replace(/\n/g, ' '),
      svg: k.querySelector('svg')?.outerHTML
    }));

    return {
      container: getCss(root),
      inner: getCss(inner),
      textCol: getCss(textCol),
      h2: getCss(h2),
      p: getCss(p),
      btn: getCss(btn),
      kbCol: getCss(kbCol),
      normalKey: {
        css: getCss(normalKey),
        html: normalKey?.outerHTML
      },
      fastKey: {
        css: getCss(fastKey),
        html: fastKey?.outerHTML
      },
      ergoKey: {
        css: getCss(ergoKey),
        html: ergoKey?.outerHTML
      },
      personalKey: {
        css: getCss(personalKey),
        html: personalKey?.outerHTML
      },
      reliableKey: {
        css: getCss(reliableKey),
        html: reliableKey?.outerHTML
      },
      svgsSample: svgs.slice(0, 10)
    };
  });

  fs.writeFileSync('raycast-deep.json', JSON.stringify(result, null, 2));
  console.log('Wrote raycast-deep.json and saved raycast-live-section.png');

  await browser.close();
}

main().catch(console.error);
