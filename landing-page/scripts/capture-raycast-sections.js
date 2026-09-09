import { chromium } from 'playwright';
import path from 'path';

const ARTIFACT_DIR = '/home/rayhan/.gemini/antigravity/brain/458e6685-2615-47f8-9831-a97b1990f39e';

async function capture() {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 2,
  });

  await page.goto('http://localhost:5173/', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);

  // 1. Capture Section 1: Download Hub
  const downloadSection = await page.$('#download');
  if (downloadSection) {
    await downloadSection.screenshot({
      path: path.join(ARTIFACT_DIR, 'raycast-1-download-hub.png'),
    });
    console.log('Captured raycast-1-download-hub.png');
  }

  // 2. Capture Section 2: Feature Carousel
  const fiturSection = await page.$('#fitur');
  if (fiturSection) {
    await fiturSection.screenshot({
      path: path.join(ARTIFACT_DIR, 'raycast-2-carousel-track.png'),
    });
    console.log('Captured raycast-2-carousel-track.png');
  }

  // 3. Scroll carousel and capture
  await page.evaluate(() => {
    const track = document.getElementById('featureCarouselTrack');
    if (track) track.scrollTo({ left: 344, behavior: 'instant' });
  });
  await page.waitForTimeout(500);
  if (fiturSection) {
    await fiturSection.screenshot({
      path: path.join(ARTIFACT_DIR, 'raycast-2-carousel-scrolled.png'),
    });
    console.log('Captured raycast-2-carousel-scrolled.png');
  }

  // 4. Capture full page
  await page.screenshot({
    path: path.join(ARTIFACT_DIR, 'raycast-full-page.png'),
    fullPage: true,
  });
  console.log('Captured raycast-full-page.png');

  // 5. Capture Mobile Viewport (iPhone 14 / 390x844)
  const mobilePage = await browser.newPage({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    isMobile: true,
  });
  await mobilePage.goto('http://localhost:5173/', { waitUntil: 'networkidle' });
  await mobilePage.waitForTimeout(1000);

  const mobileDownload = await mobilePage.$('#download');
  if (mobileDownload) {
    await mobileDownload.screenshot({
      path: path.join(ARTIFACT_DIR, 'raycast-mobile-download.png'),
    });
    console.log('Captured raycast-mobile-download.png');
  }

  const mobileFitur = await mobilePage.$('#fitur');
  if (mobileFitur) {
    await mobileFitur.screenshot({
      path: path.join(ARTIFACT_DIR, 'raycast-mobile-fitur.png'),
    });
    console.log('Captured raycast-mobile-fitur.png');
  }

  await mobilePage.close();
  await browser.close();
}

capture().catch((err) => {
  console.error(err);
  process.exit(1);
});
