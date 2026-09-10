import { chromium } from 'playwright';
import fs from 'fs';
import { PNG } from 'pngjs';
import pixelmatch from 'pixelmatch';

async function verify() {
  console.log('Launching browser to test http://localhost:5173/ ...');
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1546, height: 829 } });

  await page.goto('http://localhost:5173/', { waitUntil: 'domcontentloaded' });

  // Hide sticky header and floating elements that might overlap when scrolled
  await page.addStyleTag({
    content: `
      header, .theme-switch {
        display: none !important;
      }
    `
  });

  const container = await page.$('.GetYourTimeBack-module__o1EREW__container');
  if (!container) {
    console.error('Container .GetYourTimeBack-module__o1EREW__container not found on page!');
    await browser.close();
    process.exit(1);
  }

  await container.scrollIntoViewIfNeeded();
  await page.waitForTimeout(500);

  const localScreenshotPath = 'local-landing-raycast-section.png';
  await container.screenshot({ path: localScreenshotPath });
  // Compare with tests/raycast-target-section.png
  const targetPath = fs.existsSync('tests/raycast-target-section.png') ? 'tests/raycast-target-section.png' : 'raycast-target-section.png';
  const imgTarget = PNG.sync.read(fs.readFileSync(targetPath));
  const imgLocal = PNG.sync.read(fs.readFileSync(localScreenshotPath));

  const w = Math.min(imgTarget.width, imgLocal.width);
  const h = Math.min(imgTarget.height, imgLocal.height);

  function cropPNG(img, width, height) {
    const cropped = new PNG({ width, height });
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const srcIdx = (y * img.width + x) * 4;
        const dstIdx = (y * width + x) * 4;
        cropped.data[dstIdx] = img.data[srcIdx];
        cropped.data[dstIdx + 1] = img.data[srcIdx + 1];
        cropped.data[dstIdx + 2] = img.data[srcIdx + 2];
        cropped.data[dstIdx + 3] = img.data[srcIdx + 3];
      }
    }
    return cropped;
  }

  const croppedTarget = cropPNG(imgTarget, w, h);
  const croppedLocal = cropPNG(imgLocal, w, h);

  const diff = new PNG({ width: w, height: h });
  const diffPixels = pixelmatch(croppedTarget.data, croppedLocal.data, diff.data, w, h, { threshold: 0.1 });
  const total = w * h;
  const ratio = (diffPixels / total) * 100;

  fs.writeFileSync('landing-diff.png', PNG.sync.write(diff));

  console.log('\n========================================');
  console.log('    RAYCAST SECTION VISUAL DIFF TEST   ');
  console.log('========================================');
  console.log(`Target Image : raycast-target-section.png (${imgTarget.width}x${imgTarget.height})`);
  console.log(`Local Image  : ${localScreenshotPath} (${imgLocal.width}x${imgLocal.height})`);
  console.log(`Diff Output  : landing-diff.png`);
  console.log(`Total Pixels : ${total.toLocaleString()}`);
  console.log(`Mismatched Px: ${diffPixels.toLocaleString()}`);
  console.log(`Diff Ratio   : ${ratio.toFixed(4)}%`);
  console.log(`Threshold    : < 1.0000%`);
  console.log('----------------------------------------');

  if (ratio <= 1.0) {
    console.log(`🎉 SUCCESS! Diff is ${ratio.toFixed(4)}% which is <= 1% !`);
  } else {
    console.log(`⚠️ Warning: Diff is ${ratio.toFixed(4)}%`);
  }
  console.log('========================================\n');

  await browser.close();
}

verify().catch(console.error);
