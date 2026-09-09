import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

export function buildLocalClone() {
  const targetHtmlPath = path.resolve(rootDir, 'captured', 'target.html');
  if (!fs.existsSync(targetHtmlPath)) {
    console.error(`Target HTML not found at ${targetHtmlPath}`);
    process.exit(1);
  }

  let html = fs.readFileSync(targetHtmlPath, 'utf-8');

  // Clean up timestamp query parameters on static assets
  html = html.replace(/\/static\/css\/main\.css\?[^"']+/g, '/static/css/main.css');
  html = html.replace(/\/static\/css\/scroll\.css\?[^"']+/g, '/static/css/scroll.css');
  html = html.replace(/\/static\/js\/main\.js\?[^"']+/g, '/static/js/main.js');
  html = html.replace(/\/static\/js\/scroll\.js\?[^"']+/g, '/static/js/scroll.js');

  // Fix any relative static/img references to /static/img
  html = html.replace(/src="static\/img\//g, 'src="/static/img/');

  // Ensure style for freezing animations & deterministic rendering is cleanly formatted
  // Also include font smoothing and exact background
  const deterministicStyles = `
    <style id="visual-diff-freeze">
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
    </style>
  `;

  if (!html.includes('id="visual-diff-freeze"')) {
    html = html.replace('</head>', `${deterministicStyles}\n</head>`);
  }

  const destPath = path.resolve(rootDir, 'index.html');
  fs.writeFileSync(destPath, html, 'utf-8');
  console.log(`✅ Local clone generated at ${destPath}`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  buildLocalClone();
}
