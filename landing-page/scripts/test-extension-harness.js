import { chromium } from 'playwright';
import fs from 'fs';
import { PNG } from 'pngjs';
import pixelmatch from 'pixelmatch';

async function testHarness() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1718, height: 921 } });

  const targetHtml = fs.readFileSync('raycast-target-extension.html', 'utf-8');
  const rulesCss = fs.readFileSync('raycast-extension-rules.css', 'utf-8');

  const fullHtml = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap">
  <style>
    :root {
      --font-inter: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
      --container-width: 1204px;
      --spacing-none: 0px;
      --spacing-1: 8px;
      --spacing-1-5: 12px;
      --spacing-2: 16px;
      --spacing-2-5: 20px;
      --spacing-3: 24px;
      --spacing-4: 32px;
      --spacing-5: 40px;
      --spacing-6: 48px;
      --spacing-7: 56px;
      --spacing-8: 64px;
      --spacing-12: 96px;
      --spacing-13: 112px;
      --rounding-normal: 8px;
      --rounding-md: 12px;
      --rounding-xl: 20px;
      --Card-BG: linear-gradient(137deg, #111214 4.87%, #0c0d0f 75.88%);
      --Card-Border: #ffffff0f;
      --Text-Loud: #ffffff;
      --Text-Default: #e6e6e6;
      --Text-Muted: #6a6b6c;
      --Base-White: #ffffff;
      --grey-50: #f5f5f5;
      --grey-200: #e6e6e6;
      --grey-300: #6a6b6c;
      --grey-700: #141517;
      --grey-900: #07080a;
    }
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      background-color: #07080a;
      color: #ffffff;
      font-family: var(--font-inter);
      overflow-x: hidden;
    }

    ${rulesCss}

    /* Clean baseline reset for animations so screenshot is 100% frozen */
    .ExtensionHighlight-module__3Yq4tG__extensionCardWrapper {
      opacity: 1 !important;
      animation: none !important;
      transform: none !important;
    }
  </style>
</head>
<body>
  ${targetHtml}
</body>
</html>
  `;

  await page.setContent(fullHtml, { waitUntil: 'load' });
  await page.waitForTimeout(500);

  // Take screenshot of entire container
  const container = await page.$('.ExtensionHighlight-module__3Yq4tG__container');
  await container.screenshot({ path: 'tests/local-extension.png' });

  // Take screenshot of categories container
  const cat = await page.$('.ExtensionHighlight-module__3Yq4tG__categories');
  await cat.screenshot({ path: 'tests/local-categories.png' });

  // Take screenshot of reel container
  const reel = await page.$('.ExtensionHighlight-module__3Yq4tG__reelContainer');
  await reel.screenshot({ path: 'tests/local-reel.png' });

  // Function to diff two PNGs
  function diffImages(baselineFile, localFile, diffOutFile, name) {
    const imgBaseline = PNG.sync.read(fs.readFileSync(baselineFile));
    const imgLocal = PNG.sync.read(fs.readFileSync(localFile));

    const w = Math.min(imgBaseline.width, imgLocal.width);
    const h = Math.min(imgBaseline.height, imgLocal.height);

    function crop(img, width, height) {
      const c = new PNG({ width, height });
      for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
          const s = (y * img.width + x) * 4;
          const d = (y * width + x) * 4;
          c.data[d] = img.data[s];
          c.data[d+1] = img.data[s+1];
          c.data[d+2] = img.data[s+2];
          c.data[d+3] = img.data[s+3];
        }
      }
      return c;
    }

    const cropB = crop(imgBaseline, w, h);
    const cropL = crop(imgLocal, w, h);
    const diff = new PNG({ width: w, height: h });

    const diffPixels = pixelmatch(cropB.data, cropL.data, diff.data, w, h, { threshold: 0.1 });
    const total = w * h;
    const ratio = (diffPixels / total) * 100;

    fs.writeFileSync(diffOutFile, PNG.sync.write(diff));

    console.log(`\n--- [${name}] ---`);
    console.log(`Dimensions : ${w}x${h}`);
    console.log(`Diff Pixels: ${diffPixels} / ${total} (${ratio.toFixed(4)}%)`);
    console.log(`Result     : ${ratio <= 1.0 ? '✅ PASS (<= 1%)' : '⚠️ FAIL (> 1%)'}`);
    return { ratio, diffPixels };
  }

  diffImages('tests/baseline-categories.png', 'tests/local-categories.png', 'tests/diff-categories.png', 'Category Capsule Bar (Comment #2)');
  diffImages('tests/baseline-reel.png', 'tests/local-reel.png', 'tests/diff-reel.png', 'Cards Reel Carousel (Comment #1)');
  diffImages('tests/baseline-raycast-extension.png', 'tests/local-extension.png', 'tests/diff-extension-full.png', 'Full ExtensionHighlight Section');

  await browser.close();
}

testHarness().catch(err => {
  console.error('Error in testHarness:', err);
  process.exit(1);
});
