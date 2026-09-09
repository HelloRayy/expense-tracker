import { test, expect } from '@playwright/test';
import path from 'path';
import { fileURLToPath } from 'url';
import { runDiff } from '../scripts/analyze-diff.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const testsDir = __dirname;

test.describe('Pirsch 1:1 Pixel-Perfect Visual Regression', () => {
  test('Local clone visual diff should be <= 1%', async ({ page }) => {
    // Navigate to local clone
    await page.goto('/', { waitUntil: 'networkidle' });

    // Apply the exact animation freezing as captured on target
    await page.addStyleTag({
      content: `
        *, *::before, *::after {
          -moz-animation: none !important;
          -moz-transition: none !important;
          animation: none !important;
          transition: none !important;
          caret-color: transparent !important;
        }
        html {
          scroll-behavior: auto !important;
        }
      `
    });

    // Force eager loading on all images and scroll down to trigger layout
    await page.evaluate(async () => {
      document.querySelectorAll('img').forEach(img => {
        img.removeAttribute('loading');
        img.loading = 'eager';
      });
      window.scrollTo(0, document.body.scrollHeight);
      await new Promise(r => setTimeout(r, 600));
      window.scrollTo(0, 0);
    });

    // Wait for fonts to be ready
    await page.evaluate(async () => {
      await document.fonts.ready;
    });

    // Wait a brief tick for complete painting
    await page.waitForTimeout(1000);

    // Capture local screenshot
    const cloneScreenshotPath = path.join(testsDir, 'local-clone.png');
    await page.screenshot({ path: cloneScreenshotPath, fullPage: false });

    // Also save full-page screenshot
    const cloneFullScreenshotPath = path.join(testsDir, 'local-clone-full.png');
    await page.screenshot({ path: cloneFullScreenshotPath, fullPage: true });

    // Analyze viewport diff
    const viewportResult = await runDiff('baseline-target.png', 'local-clone.png', 'diff.png');
    console.log(`Viewport diff: ${viewportResult.diffPercent.toFixed(4)}%`);
    expect(viewportResult.diffPercent).toBeLessThanOrEqual(1.0);
    expect(viewportResult.pass).toBe(true);

    // Analyze full-page diff
    const fullResult = await runDiff('baseline-target-full.png', 'local-clone-full.png', 'diff-full.png');
    console.log(`Full page diff: ${fullResult.diffPercent.toFixed(4)}%`);
    expect(fullResult.diffPercent).toBeLessThanOrEqual(1.0);
    expect(fullResult.pass).toBe(true);
  });
});
