import { chromium } from 'playwright';
import fs from 'fs';

async function capture() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1718, height: 921 },
    userAgent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36',
  });
  const page = await context.newPage();
  console.log('Navigating to raycast.com...');
  await page.goto('https://www.raycast.com/', { waitUntil: 'domcontentloaded', timeout: 30000 });
  await page.waitForSelector('[class*="ExtensionHighlight-module"][class*="container"]', { timeout: 15000 });

  // Remove ALL fixed / sticky elements (navbars, banners, dialogs, etc.)
  await page.evaluate(() => {
    document.querySelectorAll('*').forEach(el => {
      const pos = window.getComputedStyle(el).position;
      if (pos === 'fixed' || (pos === 'sticky' && !el.className.includes('ExtensionHighlight'))) {
        el.style.setProperty('display', 'none', 'important');
      }
    });
  });

  const section = await page.$('[class*="ExtensionHighlight-module"][class*="container"]');
  if (!section) throw new Error('ExtensionHighlight container not found');
  await section.scrollIntoViewIfNeeded();
  await page.waitForTimeout(1000);

  // Take clean baseline screenshot of the section
  await section.screenshot({ path: 'tests/baseline-raycast-extension.png' });
  console.log('Saved pristine tests/baseline-raycast-extension.png!');

  // Take screenshot of categories container (Comment #2: .ExtensionHighlight-module__3Yq4tG__categories)
  const cat = await page.$('.ExtensionHighlight-module__3Yq4tG__categories');
  if (cat) {
    await cat.screenshot({ path: 'tests/baseline-categories.png' });
    console.log('Saved pristine tests/baseline-categories.png!');
  }

  // Take screenshot of reel container (Comment #1: .ExtensionHighlight-module__3Yq4tG__reelContainer)
  const reel = await page.$('.ExtensionHighlight-module__3Yq4tG__reelContainer');
  if (reel) {
    await reel.screenshot({ path: 'tests/baseline-reel.png' });
    console.log('Saved pristine tests/baseline-reel.png!');
  }

  await browser.close();
}

capture().catch(err => {
  console.error('Error during capture:', err);
  process.exit(1);
});
