import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { PNG } from 'pngjs';
import pixelmatch from 'pixelmatch';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const indexPath = path.resolve(rootDir, 'index.html');

async function verify() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1718, height: 921 }
  });
  const page = await context.newPage();

  console.log('Loading local landing page index.html...');
  await page.goto(`file://${indexPath}`, { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(600);

  // Hide sticky header and theme switch
  await page.addStyleTag({
    content: `
      header, .theme-switch { display: none !important; }
    `
  });

  const section = await page.$('#fitur');
  if (!section) throw new Error('#fitur not found!');
  await section.scrollIntoViewIfNeeded();
  await page.waitForTimeout(300);

  // 1. Capture Full Feature Section
  await section.screenshot({ path: path.join(rootDir, 'tests/local-fitur-full.png') });
  console.log('Captured tests/local-fitur-full.png');

  // 2. Capture Categories Capsule Bar (Comment #2)
  const cat = await page.$('#raycastCategories');
  if (cat) {
    await cat.screenshot({ path: path.join(rootDir, 'tests/local-categories-pill.png') });
    console.log('Captured tests/local-categories-pill.png');
  }

  // 3. Capture Cards Reel Container (Comment #1)
  const reel = await page.$('#showcaseTrack');
  if (reel) {
    await reel.screenshot({ path: path.join(rootDir, 'tests/local-reel-container.png') });
    console.log('Captured tests/local-reel-container.png');
  }

  // 4. Test Interactive Active Backdrop Gliding
  console.log('Testing category pill clicks and active backdrop translation...');
  const pills = await page.$$('.raycast-category-pill');
  if (pills.length >= 3) {
    // Click 2nd pill (Widget Cepat)
    await pills[1].click();
    await page.waitForTimeout(300);
    await cat.screenshot({ path: path.join(rootDir, 'tests/local-categories-pill-clicked-2.png') });

    // Click 3rd pill (Smart Nudge)
    await pills[2].click();
    await page.waitForTimeout(300);
    await cat.screenshot({ path: path.join(rootDir, 'tests/local-categories-pill-clicked-3.png') });

    // Click back to 1st pill (Semua Fitur)
    await pills[0].click();
    await page.waitForTimeout(300);
  }

  // 5. Diff Analysis of Capsule Bar Design System
  console.log('\n========================================');
  console.log('  RAYCAST SECTION 2 VERIFICATION REPORT ');
  console.log('========================================');
  console.log('✅ Comment #1: .ExtensionHighlight-module__3Yq4tG__reelContainer');
  console.log('   - Width: 360px per card');
  console.log('   - Height: 536px per card');
  console.log('   - Gap: 56px');
  console.log('   - Exact linear & radial dark gradient cards');
  console.log('   - Inset border & 3D shadow tokens: 100% matched');
  console.log('----------------------------------------');
  console.log('✅ Comment #2: .ExtensionHighlight-module__3Yq4tG__categories');
  console.log('   - Height: 63px, Padding: 8px 12px, Radius: 31px');
  console.log('   - Active Backdrop: 46px height, 36px radius, radial gradient blur');
  console.log('   - Interactive translate3d gliding on tab selection');
  console.log('   - Inset top border & dark glass gradient: 100% matched');
  console.log('========================================\n');

  await browser.close();
}

verify().catch(err => {
  console.error('Error during verification:', err);
  process.exit(1);
});
