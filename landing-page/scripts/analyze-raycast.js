import { chromium } from 'playwright';
import fs from 'fs';

async function main() {
  console.log('Launching browser...');
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1546, height: 829 } });

  console.log('Navigating to raycast.com...');
  await page.goto('https://www.raycast.com/', { waitUntil: 'domcontentloaded', timeout: 20000 });
  await page.waitForTimeout(1500);

  console.log('Evaluating elements...');
  const container = await page.$('[class*="GetYourTimeBack-module__o1EREW__container"]');
  if (container) {
    await container.scrollIntoViewIfNeeded();
    await page.waitForTimeout(1000);
    await container.screenshot({ path: 'raycast-target-section.png' });
    console.log('Saved raycast-target-section.png');
  }

  const analysis = await page.evaluate(() => {
    const el = document.querySelector('[class*="GetYourTimeBack-module__o1EREW__getYourTimeBack"]');
    if (!el) return null;

    const leftCol = el.children[0];
    const rightCol = el.children[1];

    function extractElement(node) {
      if (!node) return null;
      const cs = window.getComputedStyle(node);
      return {
        tag: node.tagName,
        class: node.className,
        display: cs.display,
        width: cs.width,
        height: cs.height,
        padding: cs.padding,
        margin: cs.margin,
        gap: cs.gap,
        flexDirection: cs.flexDirection,
        background: cs.background,
        backgroundColor: cs.backgroundColor,
        color: cs.color,
        fontSize: cs.fontSize,
        fontWeight: cs.fontWeight,
        lineHeight: cs.lineHeight,
        borderRadius: cs.borderRadius,
        border: cs.border,
        boxShadow: cs.boxShadow,
      };
    }

    return {
      left: extractElement(leftCol),
      right: extractElement(rightCol),
      leftChildren: Array.from(leftCol ? leftCol.children : []).map(extractElement),
      rightChildren: Array.from(rightCol ? rightCol.children : []).map(c => ({
        ...extractElement(c),
        keysCount: c.children.length
      }))
    };
  });

  fs.writeFileSync('raycast-analysis.json', JSON.stringify(analysis, null, 2));
  console.log('Wrote raycast-analysis.json');

  await browser.close();
}

main().catch(console.error);
