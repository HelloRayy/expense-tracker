import { chromium } from 'playwright';
import fs from 'fs';
import { PNG } from 'pngjs';
import pixelmatch from 'pixelmatch';

async function testClone() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1546, height: 829 } });

  const kbHtml = fs.readFileSync('extracted-keyboard.html', 'utf-8');
  const rulesCss = fs.readFileSync('raycast-rules.css', 'utf-8');

  const testHtml = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap">
  <style>
    :root {
      --font-inter: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
      --container-width: 1204px;
      --spacing-3: 24px;
      --spacing-6: 48px;
      --grey-200: #e6e6e6;
      --grey-300: #b5b5b5;
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

    .SectionTitle-module__U5mb2W__container {
      height: 72.5px;
    }
    .SectionTitle-module__U5mb2W__container h2 {
      font-size: 20px;
      font-weight: 500;
      line-height: normal;
      letter-spacing: 0.2px;
      color: #ffffff;
    }
    .SectionTitle-module__U5mb2W__container p {
      font-size: 20px;
      font-weight: 500;
      line-height: normal;
      letter-spacing: 0.2px;
      color: #6a6b6c;
    }
    .GetYourTimeBack-module__o1EREW__downloadButton {
      display: inline-flex !important;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 8px 12px;
      background-color: #e6e6e6;
      color: #2f3031;
      font-size: 14px;
      font-weight: 500;
      border-radius: 8px;
      text-decoration: none;
      box-shadow: rgba(0, 0, 0, 0.5) 0px 0px 0px 2px, rgba(255, 255, 255, 0.19) 0px 0px 14px 0px, rgba(0, 0, 0, 0.2) 0px -1px 0.4px 0px inset, rgb(255, 255, 255) 0px 1px 0.4px 0px inset;
      height: 36px;
      cursor: pointer;
    }
    .GetYourTimeBack-module__o1EREW__downloadButton svg {
      width: 16px;
      height: 16px;
    }
  </style>
</head>
<body>
  <div class="GetYourTimeBack-module__o1EREW__container" style="height: 720px;">
    <div class="GetYourTimeBack-module__o1EREW__getYourTimeBack">
      <div class="GetYourTimeBack-module__o1EREW__text">
        <div class="SectionTitle-module__U5mb2W__container">
          <h2>It’s not about saving time.</h2>
          <p>It’s about feeling like you’re never wasting it.</p>
        </div>
        <a class="Button-module__3dJGfa__button Button-module__3dJGfa__light GetYourTimeBack-module__o1EREW__downloadButton" href="#">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 16 16">
            <path fill="currentColor" d="M12.665 15.358c-.905.844-1.893.711-2.843.311-1.006-.409-1.93-.427-2.991 0-1.33.551-2.03.391-2.825-.31C-.498 10.886.166 4.078 5.28 3.83c1.246.062 2.114.657 2.843.71 1.09-.213 2.133-.826 3.296-.746 1.393.107 2.446.64 3.138 1.6-2.88 1.662-2.197 5.315.443 6.337-.526 1.333-1.21 2.657-2.345 3.635zM8.03 2.923c.531-.692.934-1.638.796-2.61-.885.06-1.916.634-2.502 1.326-.499.58-.934 1.547-.783 2.474.968.08 1.958-.498 2.489-1.19z"></path>
          </svg>
          Download
        </a>
      </div>
      <div class="GetYourTimeBack-module__o1EREW__keyboard">
        ${kbHtml}
      </div>
    </div>
  </div>
</body>
</html>
  `;

  await page.setContent(testHtml, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);

  const container = await page.$('.GetYourTimeBack-module__o1EREW__container');
  await container.screenshot({ path: 'test-clone.png' });

  // Now compare with raycast-target-section.png
  const imgTarget = PNG.sync.read(fs.readFileSync('raycast-target-section.png'));
  const imgClone = PNG.sync.read(fs.readFileSync('test-clone.png'));

  const commonWidth = Math.min(imgTarget.width, imgClone.width);
  const commonHeight = Math.min(imgTarget.height, imgClone.height);

  console.log(`Target: ${imgTarget.width}x${imgTarget.height}, Clone: ${imgClone.width}x${imgClone.height}, Common: ${commonWidth}x${commonHeight}`);

  // Create cropped buffers for pixelmatch
  function cropPNG(img, w, h) {
    const cropped = new PNG({ width: w, height: h });
    for (let y = 0; y < h; y++) {
      for (let x = 0; x < w; x++) {
        const srcIdx = (y * img.width + x) * 4;
        const dstIdx = (y * w + x) * 4;
        cropped.data[dstIdx] = img.data[srcIdx];
        cropped.data[dstIdx + 1] = img.data[srcIdx + 1];
        cropped.data[dstIdx + 2] = img.data[srcIdx + 2];
        cropped.data[dstIdx + 3] = img.data[srcIdx + 3];
      }
    }
    return cropped;
  }

  const croppedTarget = cropPNG(imgTarget, commonWidth, commonHeight);
  const croppedClone = cropPNG(imgClone, commonWidth, commonHeight);

  const diff = new PNG({ width: commonWidth, height: commonHeight });
  const diffPixels = pixelmatch(croppedTarget.data, croppedClone.data, diff.data, commonWidth, commonHeight, { threshold: 0.1 });
  const total = commonWidth * commonHeight;
  const ratio = (diffPixels / total) * 100;

  fs.writeFileSync('test-diff.png', PNG.sync.write(diff));

  console.log(`Diff pixels: ${diffPixels} / ${total} (${ratio.toFixed(4)}%)`);
  await browser.close();
}

testClone().catch(console.error);
