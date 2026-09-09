import fs from 'fs';
import path from 'path';
import { PNG } from 'pngjs';
import pixelmatch from 'pixelmatch';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const testsDir = path.resolve(rootDir, 'tests');

export async function runDiff(baselineFile = 'baseline-target.png', cloneFile = 'local-clone.png', diffFile = 'diff.png') {
  const baselinePath = path.join(testsDir, baselineFile);
  const clonePath = path.join(testsDir, cloneFile);
  const diffPath = path.join(testsDir, diffFile);

  if (!fs.existsSync(baselinePath)) {
    console.error(`❌ Baseline image not found: ${baselinePath}`);
    process.exit(1);
  }

  if (!fs.existsSync(clonePath)) {
    console.error(`❌ Local clone image not found: ${clonePath}`);
    process.exit(1);
  }

  const baselineData = fs.readFileSync(baselinePath);
  const cloneData = fs.readFileSync(clonePath);

  const imgBaseline = PNG.sync.read(baselineData);
  const imgClone = PNG.sync.read(cloneData);

  const width = imgBaseline.width;
  const height = imgBaseline.height;

  if (imgClone.width !== width || imgClone.height !== height) {
    console.warn(`⚠️ Warning: Image dimensions mismatch! Baseline is ${width}x${height}, Clone is ${imgClone.width}x${imgClone.height}`);
  }

  const diff = new PNG({ width, height });

  // pixelmatch options: threshold 0.1, includeAA false
  const diffPixels = pixelmatch(
    imgBaseline.data,
    imgClone.data,
    diff.data,
    width,
    height,
    { threshold: 0.1, includeAA: false }
  );

  const totalPixels = width * height;
  const diffPercent = (diffPixels / totalPixels) * 100;

  fs.writeFileSync(diffPath, PNG.sync.write(diff));

  console.log('\n========================================');
  console.log('       VISUAL DIFF ANALYSIS RESULT      ');
  console.log('========================================');
  console.log(`Baseline Image : ${baselineFile} (${width}x${height})`);
  console.log(`Clone Image    : ${cloneFile} (${imgClone.width}x${imgClone.height})`);
  console.log(`Diff Output    : ${diffFile}`);
  console.log(`Total Pixels   : ${totalPixels.toLocaleString()}`);
  console.log(`Mismatched Px  : ${diffPixels.toLocaleString()}`);
  console.log(`Diff Ratio     : ${diffPercent.toFixed(4)}%`);
  console.log(`Threshold Goal : <= 1.0000%`);
  console.log('----------------------------------------');

  if (diffPercent <= 1.0) {
    console.log(`🎉 100% Pixel-Perfect PASS! Diff (${diffPercent.toFixed(4)}%) is <= 1%`);
    console.log('========================================\n');
    return { pass: true, diffPercent, diffPixels };
  } else {
    console.log(`❌ FAIL: Diff (${diffPercent.toFixed(4)}%) is > 1%`);
    console.log('========================================\n');
    return { pass: false, diffPercent, diffPixels };
  }
}

// If run directly from CLI
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runDiff().then(({ pass }) => {
    process.exit(pass ? 0 : 1);
  }).catch((err) => {
    console.error('Error during diff analysis:', err);
    process.exit(1);
  });
}
