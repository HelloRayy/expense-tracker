import { chromium } from 'playwright';
import fs from 'fs';

async function extractRules() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1718, height: 921 },
  });
  const page = await context.newPage();
  console.log('Navigating to raycast.com...');
  await page.goto('https://www.raycast.com/', { waitUntil: 'domcontentloaded', timeout: 30000 });
  await page.waitForSelector('[class*="ExtensionHighlight-module"]', { timeout: 15000 });

  const cssRules = await page.evaluate(() => {
    let result = '';
    for (const sheet of document.styleSheets) {
      try {
        for (const rule of sheet.cssRules) {
          const text = rule.cssText;
          if (
            text.includes('ExtensionHighlight') ||
            text.includes('pFn2Lq') ||
            text.includes('SectionTitle')
          ) {
            result += text + '\n\n';
          }
        }
      } catch (e) {
        // Cross-origin stylesheet
      }
    }
    return result;
  });

  fs.writeFileSync('raycast-extension-rules.css', cssRules);
  console.log(`Saved raycast-extension-rules.css (${cssRules.length} bytes)!`);
  await browser.close();
}

extractRules().catch(err => {
  console.error('Error extracting rules:', err);
  process.exit(1);
});
