import fs from 'fs';
import path from 'path';
import https from 'https';
import http from 'http';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

async function downloadFile(url, dest) {
  const dir = path.dirname(dest);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

  return new Promise((resolve, reject) => {
    const client = url.startsWith('https') ? https : http;
    client.get(url, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        let redirectUrl = res.headers.location;
        if (redirectUrl.startsWith('/')) {
          redirectUrl = 'https://pirsch.io' + redirectUrl;
        }
        return downloadFile(redirectUrl, dest).then(resolve).catch(reject);
      }
      if (res.statusCode !== 200) {
        return reject(new Error(`Failed to download ${url}: status ${res.statusCode}`));
      }
      const fileStream = fs.createWriteStream(dest);
      res.pipe(fileStream);
      fileStream.on('finish', () => {
        fileStream.close();
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(dest, () => {});
      reject(err);
    });
  });
}

async function main() {
  const htmlPath = path.resolve(rootDir, 'captured', 'target.html');
  const html = fs.readFileSync(htmlPath, 'utf-8');
  
  // Find all /static/... references
  const matches = [...html.matchAll(/(?:href|src)=["'](\/static\/[^"']+)["']/g)].map(m => m[1]);
  const uniqueUrls = [...new Set(matches.map(u => u.split('?')[0]))];

  console.log(`Downloading ${uniqueUrls.length} assets from target...`);
  
  for (const relUrl of uniqueUrls) {
    const targetUrl = 'https://pirsch.io' + relUrl;
    const destPath = path.resolve(rootDir, 'public' + relUrl);
    try {
      await downloadFile(targetUrl, destPath);
      console.log(`✓ Downloaded ${relUrl}`);
    } catch (e) {
      console.warn(`⚠️ Failed ${relUrl}:`, e.message);
    }
  }

  // Also check main.css for url(...)
  const mainCssPath = path.resolve(rootDir, 'public', 'static', 'css', 'main.css');
  if (fs.existsSync(mainCssPath)) {
    const css = fs.readFileSync(mainCssPath, 'utf-8');
    const cssUrls = [...css.matchAll(/url\(["']?(\/static\/[^"')]+)["']?\)/g)].map(m => m[1].split('?')[0]);
    const uniqueCssUrls = [...new Set(cssUrls)];
    console.log(`Found ${uniqueCssUrls.length} assets inside main.css...`);
    for (const relUrl of uniqueCssUrls) {
      const targetUrl = 'https://pirsch.io' + relUrl;
      const destPath = path.resolve(rootDir, 'public' + relUrl);
      if (!fs.existsSync(destPath)) {
        try {
          await downloadFile(targetUrl, destPath);
          console.log(`✓ (from CSS) Downloaded ${relUrl}`);
        } catch (e) {
          console.warn(`⚠️ (from CSS) Failed ${relUrl}:`, e.message);
        }
      }
    }
  }

  console.log('🎉 All static assets downloaded!');
}

main().catch(console.error);
