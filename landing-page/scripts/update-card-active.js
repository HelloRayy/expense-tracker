import fs from 'fs';

const indexPath = 'index.html';
let html = fs.readFileSync(indexPath, 'utf-8');

// 1. Add CSS for featured and active keycard
const activeCardCss = `
      /* Featured Keycards & Brighter Active State */
      .index-module__h8MSgW__key.featured-key {
        cursor: pointer;
        opacity: 0.75;
        transition: opacity 0.25s cubic-bezier(0.23, 1, 0.32, 1), transform 0.2s cubic-bezier(0.23, 1, 0.32, 1), box-shadow 0.2s cubic-bezier(0.23, 1, 0.32, 1), --key-bg-start-color 0.25s cubic-bezier(0.23, 1, 0.32, 1);
      }

      .index-module__h8MSgW__key.featured-key:hover {
        opacity: 0.95 !important;
        --key-bg-start-color: #1a1a1a;
        --key-bg-end-color: #121212;
        transform: translateY(-1px);
      }

      .index-module__h8MSgW__key.featured-key.active,
      .index-module__h8MSgW__key.featured-key:active {
        opacity: 1 !important;
        --key-bg-start-color: #222222;
        --key-bg-end-color: #151515;
        background: radial-gradient(75% 75% at 50% 91.9%, #222222 0%, #151515 100%) !important;
        box-shadow: rgba(0, 0, 0, 0.4) 0px 1.5px 0.5px 2.5px, rgb(0, 0, 0) 0px 0px 0.5px 1px, rgba(0, 0, 0, 0.25) 0px 2px 1px 1px inset, rgba(255, 255, 255, 0.2) 0px 1px 1px 1px inset, rgba(0, 0, 0, 0) 0px 0px 0px 0px inset !important;
        transform: translateY(0px);
      }

      .index-module__h8MSgW__key.featured-key .index-module__h8MSgW__primary > span {
        color: #9c9c9d;
        line-height: 1.25;
        display: block;
      }

      .index-module__h8MSgW__key.featured-key .index-module__h8MSgW__primary strong {
        color: #ffffff;
        font-weight: 700;
      }

      .index-module__h8MSgW__key.featured-key.active .index-module__h8MSgW__alt svg,
      .index-module__h8MSgW__key.featured-key:hover .index-module__h8MSgW__alt svg {
        color: #ffffff;
      }
`;

// Insert the CSS before </style>
const styleEndTag = '</style>';
const styleEndIdx = html.indexOf(styleEndTag);
if (styleEndIdx !== -1) {
  html = html.slice(0, styleEndIdx) + '\n' + activeCardCss.trim() + '\n    ' + html.slice(styleEndIdx);
}

// 2. Update the 4 keys in HTML:
// Key 1: Fast
html = html.replace(
  '<div class="index-module__h8MSgW__key" style="width:178px;opacity:0.2;transition-delay:0s"><div class="index-module__h8MSgW__alt" style="font-size:23.75px"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 16 16" style="width:24px"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 4.75v2.836a1 1 0 0 0 .293.707l1.957 1.957m4-2.25a6.25 6.25 0 1 1-12.5 0 6.25 6.25 0 0 1 12.5 0Z"></path></svg></div><div class="index-module__h8MSgW__primary" style="font-size:16px"><span><strong>Fast.</strong> Think in milliseconds.</span></div></div>',
  '<div class="index-module__h8MSgW__key featured-key" onclick="setActiveKey(this)" style="width:178px;transition-delay:0s"><div class="index-module__h8MSgW__alt" style="font-size:23.75px"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 16 16" style="width:24px"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 4.75v2.836a1 1 0 0 0 .293.707l1.957 1.957m4-2.25a6.25 6.25 0 1 1-12.5 0 6.25 6.25 0 0 1 12.5 0Z"></path></svg></div><div class="index-module__h8MSgW__primary" style="font-size:16px"><span><strong>Fast.</strong> Think in milliseconds.</span></div></div>'
);

// Key 2: Ergonomic
html = html.replace(
  'style="width:208px;opacity:0.2;transition-delay:0s"><div class="index-module__h8MSgW__alt" style="font-size:23.75px"><svg xmlns="http://www.w3.org/2000/svg" width="21" height="21" fill="none"><path fill="#D8D8D8" d="M6.593 8.447v4.626H4.611q-1.065 0-1.942.505a3.84 3.84 0 0 0-1.396 1.37 3.7 3.7 0 0 0-.52 1.941q0 1.066.52 1.942a4 4 0 0 0 1.396 1.403q.876.526 1.942.526t1.942-.526a4 4 0 0 0 1.395-1.403 3.74 3.74 0 0 0 .52-1.942V14.92h4.558v1.97q0 1.065.526 1.941.525.877 1.396 1.403t1.935.526q1.066 0 1.942-.526a4 4 0 0 0 1.396-1.403q.52-.876.52-1.942 0-1.078-.52-1.942a3.84 3.84 0 0 0-3.338-1.874h-1.969V8.447h1.97q1.065 0 1.941-.506a3.84 3.84 0 0 0 1.396-1.369q.52-.862.52-1.942 0-1.065-.52-1.941a3.84 3.84 0 0 0-1.396-1.37 3.7 3.7 0 0 0-1.941-.52q-1.066 0-1.936.52a4 4 0 0 0-1.395 1.37q-.526.876-.526 1.941v1.97H6.593zm-1.982 4.626h1.982V8.447H4.611q-.684 0-1.168-.31-.482-.312-.66-.807a2.2 2.2 0 0 1-.177-.882q0-.685.457-1.142.457-.457 1.142-.457.698 0 1.155.457.47.457.47 1.142v1.97h4.558V6.448q0-.685.457-1.142.47-.457 1.155-.457.685 0 1.142.457.457.457.457 1.142 0 .343-.083.635-.082.28-.27.526-.174.242-.47.413a2.4 2.4 0 0 1-.736.235v4.626h1.97q.684 0 1.168.31.482.312.66.807.09.24.133.476.044.228.044.406 0 .685-.457 1.142-.457.457-1.142.457-.698 0-1.155-.457-.47-.457-.47-1.142v-1.97H8.575v1.97q0 .685-.457 1.142-.47.457-1.155.457-.685 0-1.142-.457-.457-.457-.457-1.142 0-.343.082-.635.083-.28.27-.526.175-.242.47-.413a2.4 2.4 0 0 1 .736-.235z\"></path></svg></div><div class="index-module__h8MSgW__primary" style="font-size:16px"><span><strong>Ergonomic.</strong> Keyboard First.</span></div></div>',
  'class="index-module__h8MSgW__key featured-key" onclick="setActiveKey(this)" style="width:208px;transition-delay:0s"><div class="index-module__h8MSgW__alt" style="font-size:23.75px"><svg xmlns="http://www.w3.org/2000/svg" width="21" height="21" fill="none"><path fill="#D8D8D8" d="M6.593 8.447v4.626H4.611q-1.065 0-1.942.505a3.84 3.84 0 0 0-1.396 1.37 3.7 3.7 0 0 0-.52 1.941q0 1.066.52 1.942a4 4 0 0 0 1.396 1.403q.876.526 1.942.526t1.942-.526a4 4 0 0 0 1.395-1.403 3.74 3.74 0 0 0 .52-1.942V14.92h4.558v1.97q0 1.065.526 1.941.525.877 1.396 1.403t1.935.526q1.066 0 1.942-.526a4 4 0 0 0 1.396-1.403q.52-.876.52-1.942 0-1.078-.52-1.942a3.84 3.84 0 0 0-3.338-1.874h-1.969V8.447h1.97q1.065 0 1.941-.506a3.84 3.84 0 0 0 1.396-1.369q.52-.862.52-1.942 0-1.065-.52-1.941a3.84 3.84 0 0 0-1.396-1.37 3.7 3.7 0 0 0-1.941-.52q-1.066 0-1.936.52a4 4 0 0 0-1.395 1.37q-.526.876-.526 1.941v1.97H6.593zm-1.982 4.626h1.982V8.447H4.611q-.684 0-1.168-.31-.482-.312-.66-.807a2.2 2.2 0 0 1-.177-.882q0-.685.457-1.142.457-.457 1.142-.457.698 0 1.155.457.47.457.47 1.142v1.97h4.558V6.448q0-.685.457-1.142.47-.457 1.155-.457.685 0 1.142.457.457.457.457 1.142 0 .343-.083.635-.082.28-.27.526-.174.242-.47.413a2.4 2.4 0 0 1-.736.235v4.626h1.97q.684 0 1.168.31.482.312.66.807.09.24.133.476.044.228.044.406 0 .685-.457 1.142-.457.457-1.142.457-.698 0-1.155-.457-.47-.457-.47-1.142v-1.97H8.575v1.97q0 .685-.457 1.142-.47.457-1.155.457-.685 0-1.142-.457-.457-.457-.457-1.142 0-.343.082-.635.083-.28.27-.526.175-.242.47-.413a2.4 2.4 0 0 1 .736-.235z\"></path></svg></div><div class="index-module__h8MSgW__primary" style="font-size:16px"><span><strong>Ergonomic.</strong> Keyboard First.</span></div></div>'
);

// Key 3: Personal (Set ACTIVE by default)
html = html.replace(
  '<div class="index-module__h8MSgW__key" style="width:208px;opacity:0.2;transition-delay:0s"><div class="index-module__h8MSgW__alt" style="font-size:23.75px"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 16 16" style="width:24px"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.5 4.25a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0ZM8 9.25c-2.245 0-4.318 1.055-5.134 3.046-.419 1.022.529 1.954 1.633 1.954h7.002c1.104 0 2.052-.932 1.633-1.954C12.318 10.305 10.245 9.25 8 9.25Z"></path></svg></div><div class="index-module__h8MSgW__primary" style="font-size:16px"><span><strong>Personal.</strong> Your tools, your way.</span></div></div>',
  '<div class="index-module__h8MSgW__key featured-key active" onclick="setActiveKey(this)" style="width:208px;transition-delay:0s"><div class="index-module__h8MSgW__alt" style="font-size:23.75px"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 16 16" style="width:24px"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.5 4.25a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0ZM8 9.25c-2.245 0-4.318 1.055-5.134 3.046-.419 1.022.529 1.954 1.633 1.954h7.002c1.104 0 2.052-.932 1.633-1.954C12.318 10.305 10.245 9.25 8 9.25Z"></path></svg></div><div class="index-module__h8MSgW__primary" style="font-size:16px"><span><strong>Personal.</strong> Your tools, your way.</span></div></div>'
);

// Key 4: Reliable
html = html.replace(
  'style="width:178px;opacity:0.2;transition-delay:0s"><div class="index-module__h8MSgW__alt" style="font-size:23.75px"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 16 16" style="width:24px"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12.5 7.25v0a1.75 1.75 0 0 0 1.75-1.75V3.75m-12.5 0V5.5c0 .966.784 1.75 1.75 1.75m10.75 6V11.5a1.75 1.75 0 0 0-1.75-1.75m-10.75 3.5V11.5c0-.966.784-1.75 1.75-1.75m7.883 2.034C10.826 10.829 9.668 9.75 8 9.75s-2.826 1.079-3.383 2.034m6.766 0c.544-1.05.867-2.362.867-3.784 0-3.452-1.903-6.25-4.25-6.25S3.75 4.548 3.75 8c0 1.422.323 2.733.867 3.784m6.766 0C10.607 13.283 9.38 14.25 8 14.25s-2.607-.967-3.65-2.216"></path></svg></div><div class="index-module__h8MSgW__primary" style="font-size:16px"><span><strong>Reliable.</strong> 99.8% crash-free rate.</span></div></div>',
  'class="index-module__h8MSgW__key featured-key" onclick="setActiveKey(this)" style="width:178px;transition-delay:0s"><div class="index-module__h8MSgW__alt" style="font-size:23.75px"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 16 16" style="width:24px"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12.5 7.25v0a1.75 1.75 0 0 0 1.75-1.75V3.75m-12.5 0V5.5c0 .966.784 1.75 1.75 1.75m10.75 6V11.5a1.75 1.75 0 0 0-1.75-1.75m-10.75 3.5V11.5c0-.966.784-1.75 1.75-1.75m7.883 2.034C10.826 10.829 9.668 9.75 8 9.75s-2.826 1.079-3.383 2.034m6.766 0c.544-1.05.867-2.362.867-3.784 0-3.452-1.903-6.25-4.25-6.25S3.75 4.548 3.75 8c0 1.422.323 2.733.867 3.784m6.766 0C10.607 13.283 9.38 14.25 8 14.25s-2.607-.967-3.65-2.216"></path></svg></div><div class="index-module__h8MSgW__primary" style="font-size:16px"><span><strong>Reliable.</strong> 99.8% crash-free rate.</span></div></div>'
);

// 3. Add setActiveKey helper function in script
const scriptHelper = `
                function setActiveKey(el) {
                    document.querySelectorAll('.featured-key').forEach(k => k.classList.remove('active'));
                    el.classList.add('active');
                }
`;

if (!html.includes('function setActiveKey')) {
  html = html.replace('function copyChecksum() {', scriptHelper.trim() + '\n\n                function copyChecksum() {');
}

fs.writeFileSync(indexPath, html, 'utf-8');
console.log('Successfully updated active card styling and interaction in index.html!');
