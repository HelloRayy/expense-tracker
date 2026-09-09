import { chromium } from '@playwright/test';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const testsDir = path.resolve(rootDir, 'tests');
const capturedDir = path.resolve(rootDir, 'captured');

if (!fs.existsSync(testsDir)) fs.mkdirSync(testsDir, { recursive: true });
if (!fs.existsSync(capturedDir)) fs.mkdirSync(capturedDir, { recursive: true });


async function captureTarget() {
  console.log('🚀 Launching browser to capture https://pirsch.io/...');
  const browser = await chromium.launch({
    headless: true,
  });

  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 1,
    locale: 'en-US',
  });

  const page = await context.newPage();

  // Navigate to target
  await page.goto('https://pirsch.io/', { waitUntil: 'networkidle', timeout: 45000 });

  // Freeze animations and transitions for deterministic screenshot
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

  // Wait for fonts
  await page.evaluate(async () => {
    await document.fonts.ready;
  });

  // Wait a moment for any final render
  await page.waitForTimeout(1000);

  // Take baseline screenshot (1440x900 viewport capture for benchmark)
  const baselineViewportPath = path.join(testsDir, 'baseline-target.png');
  await page.screenshot({ path: baselineViewportPath, fullPage: false });
  console.log(`✅ Baseline viewport screenshot saved to ${baselineViewportPath}`);

  // Also take fullPage baseline
  const baselineFullPath = path.join(testsDir, 'baseline-target-full.png');
  await page.screenshot({ path: baselineFullPath, fullPage: true });
  console.log(`✅ Baseline full-page screenshot saved to ${baselineFullPath}`);

  // Save full HTML
  const html = await page.content();
  const htmlPath = path.join(capturedDir, 'target.html');
  fs.writeFileSync(htmlPath, html, 'utf-8');
  console.log(`✅ Target HTML saved to ${htmlPath}`);

  // Extract all stylesheet URLs, images, and fonts
  const assets = await page.evaluate(() => {
    const stylesheets = Array.from(document.querySelectorAll('link[rel="stylesheet"]')).map(el => el.href);
    const inlineStyles = Array.from(document.querySelectorAll('style')).map(el => el.innerHTML);
    const images = Array.from(document.querySelectorAll('img')).map(el => ({ src: el.src, alt: el.alt, class: el.className }));
    const svgs = Array.from(document.querySelectorAll('svg')).map(el => el.outerHTML);
    return { stylesheets, inlineStyles, images, svgs };
  });

  fs.writeFileSync(path.join(capturedDir, 'assets.json'), JSON.stringify(assets, null, 2), 'utf-8');
  console.log(`✅ Assets metadata saved to ${path.join(capturedDir, 'assets.json')}`);

  await browser.close();
  console.log('🎉 Target capture completed successfully!');
}

captureTarget().catch((err) => {
  console.error('❌ Error capturing target:', err);
  process.exit(1);
});
