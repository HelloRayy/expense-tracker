import fs from 'fs';

const indexPath = 'index.html';
let html = fs.readFileSync(indexPath, 'utf-8');

const kbHtml = fs.readFileSync('extracted-keyboard.html', 'utf-8');

// 1. Prepare CSS replacement
const raycastSectionCss = `
      /* Raycast Section 1: 1:1 Authentic Keyboard & Download Hub */
      :root {
        --key-bg-start-color: #121212;
        --key-bg-end-color: #0d0d0d;
        --container-width: 1204px;
        --spacing-3: 24px;
        --spacing-6: 48px;
        --grey-200: #e6e6e6;
        --grey-300: #b5b5b5;
        --grey-900: #07080a;
      }

      .GetYourTimeBack-module__o1EREW__container {
        position: relative;
        overflow: hidden;
        background: #07080a;
        border-radius: var(--border-radius-large, 24px);
        border: 1px solid rgba(255, 255, 255, 0.08);
        box-shadow: 0 20px 60px -15px rgba(0, 0, 0, 0.6);
        min-height: 720px;
        width: 100%;
      }

      .GetYourTimeBack-module__o1EREW__getYourTimeBack {
        width: 100%;
        max-width: var(--container-width);
        gap: 85px;
        margin: 0px auto;
        display: grid;
        overflow: hidden;
      }

      @media (min-width: 720px) {
        .GetYourTimeBack-module__o1EREW__getYourTimeBack {
          grid-template-rows: auto;
          grid-template-columns: 440px auto;
        }
      }

      .GetYourTimeBack-module__o1EREW__keyboard {
        max-width: 100%;
        height: 490px;
        padding-left: var(--spacing-3);
        overflow: hidden;
      }

      .GetYourTimeBack-module__o1EREW__keyboard > * {
        z-index: 1;
        position: absolute;
        mask-image: linear-gradient(rgba(0, 0, 0, 0), rgb(255, 255, 255), rgba(0, 0, 0, 0));
        -webkit-mask-image: linear-gradient(rgba(0, 0, 0, 0), rgb(255, 255, 255), rgba(0, 0, 0, 0));
      }

      .GetYourTimeBack-module__o1EREW__keyboard > * > :nth-child(3) > :first-child {
        display: none;
      }

      @media (min-width: 720px) {
        .GetYourTimeBack-module__o1EREW__keyboard {
          height: 100%;
          mask-image: radial-gradient(95% 70% at 17.02% 47.84%, rgb(217, 217, 217) 16.79%, rgba(217, 217, 217, 0) 83.76%);
          -webkit-mask-image: radial-gradient(95% 70% at 17.02% 47.84%, rgb(217, 217, 217) 16.79%, rgba(217, 217, 217, 0) 83.76%);
        }
        .GetYourTimeBack-module__o1EREW__keyboard > * {
          position: static;
        }
        .GetYourTimeBack-module__o1EREW__keyboard > * > :nth-child(3) > :first-child {
          display: grid;
        }
      }

      .GetYourTimeBack-module__o1EREW__text {
        gap: var(--spacing-6);
        max-width: 320px;
        padding: var(--spacing-3);
        text-align: center;
        background: linear-gradient(to bottom, transparent, var(--grey-900) 50%);
        flex-direction: column;
        grid-row: 2;
        justify-content: center;
        align-items: flex-start;
        margin: 0px auto;
        display: flex;
        z-index: 2;
      }

      .GetYourTimeBack-module__o1EREW__downloadButton {
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 8px 14px;
        background-color: #e6e6e6;
        color: #2f3031 !important;
        font-size: 14px;
        font-weight: 500;
        border-radius: 8px;
        text-decoration: none;
        box-shadow: rgba(0, 0, 0, 0.5) 0px 0px 0px 2px, rgba(255, 255, 255, 0.19) 0px 0px 14px 0px, rgba(0, 0, 0, 0.2) 0px -1px 0.4px 0px inset, rgb(255, 255, 255) 0px 1px 0.4px 0px inset;
        height: 36px;
        cursor: pointer;
        transition: background-color 0.15s ease, transform 0.15s ease;
      }

      .GetYourTimeBack-module__o1EREW__downloadButton:hover {
        background-color: #d6d6d6;
      }

      .GetYourTimeBack-module__o1EREW__downloadButton:active {
        transform: scale(0.98);
      }

      .GetYourTimeBack-module__o1EREW__downloadButton svg {
        width: 16px;
        height: 16px;
      }

      @media (min-width: 720px) {
        .GetYourTimeBack-module__o1EREW__text {
          text-align: left;
          grid-row: 1;
          margin: 0px;
        }
      }

      .SectionTitle-module__U5mb2W__container {
        height: 72.5px;
      }

      .SectionTitle-module__U5mb2W__container h2 {
        font-size: 20px;
        font-weight: 500;
        line-height: normal;
        letter-spacing: 0.2px;
        color: #ffffff;
        margin: 0 0 4px 0;
      }

      .SectionTitle-module__U5mb2W__container p {
        font-size: 20px;
        font-weight: 500;
        line-height: normal;
        letter-spacing: 0.2px;
        color: #6a6b6c;
        margin: 0;
      }

      .index-module__h8MSgW__keyboard {
        flex-direction: column;
        gap: 12px;
        max-width: 100%;
        display: flex;
      }

      .index-module__h8MSgW__keyboardRow {
        flex-wrap: nowrap;
        gap: 12px;
        height: 110px;
        display: flex;
      }

      .index-module__h8MSgW__key {
        --key-bg-start-color: #121212;
        --key-bg-end-color: #0d0d0d;
        width: 110px;
        height: 100%;
        font-family: "SF Pro Text", "SF Pro Icons", Inter, -apple-system, BlinkMacSystemFont, sans-serif;
        text-shadow: rgba(0, 0, 0, 0.1) 0px 0.5px 0.5px;
        user-select: none;
        background: radial-gradient(75% 75% at 50% 91.9%, var(--key-bg-start-color) 0%, var(--key-bg-end-color) 100%);
        border-radius: 11px;
        flex-shrink: 0;
        grid-template-rows: 1fr 1fr;
        padding: 14.5px 15px;
        font-size: 23.75px;
        font-weight: 500;
        transition: opacity 0.4s cubic-bezier(0.23, 1, 0.32, 1), box-shadow 0.2s cubic-bezier(0.23, 1, 0.32, 1), transform 0.2s cubic-bezier(0.23, 1, 0.32, 1), color 0.2s cubic-bezier(0.23, 1, 0.32, 1), --key-bg-start-color 0.4s cubic-bezier(0.23, 1, 0.32, 1), --key-bg-end-color 0.4s cubic-bezier(0.23, 1, 0.32, 1);
        display: grid;
        box-shadow: rgba(0, 0, 0, 0.4) 0px 1.5px 0.5px 2.5px, rgb(0, 0, 0) 0px 0px 0.5px 1px, rgba(0, 0, 0, 0.25) 0px 2px 1px 1px inset, rgba(255, 255, 255, 0.2) 0px 1px 1px 1px inset, rgba(0, 0, 0, 0) 0px 0px inset;
        color: #ffffff;
      }

      .index-module__h8MSgW__key:hover {
        --key-bg-start-color: #151515;
        --key-bg-end-color: #0d0d0d;
        transform: translateY(1px);
        box-shadow: rgba(0, 0, 0, 0) 0px 0px, rgb(0, 0, 0) 0px 0px 0.5px 1px, rgba(0, 0, 0, 0.25) 0px 2px 1px 1px inset, rgba(255, 255, 255, 0.15) 0px 1px 1px inset, rgba(0, 0, 0, 0) 0px 0px inset;
      }

      .index-module__h8MSgW__key path {
        transition: fill 0.4s cubic-bezier(0.23, 1, 0.32, 1);
      }

      .index-module__h8MSgW__key strong {
        color: rgb(255, 255, 255);
      }

      .index-module__h8MSgW__key.index-module__h8MSgW__noMobile {
        display: none;
      }

      .index-module__h8MSgW__key > .index-module__h8MSgW__alt {
        grid-row: 1;
      }

      .index-module__h8MSgW__key > .index-module__h8MSgW__primary {
        grid-row: 2;
      }

      @media (min-width: 720px) {
        .index-module__h8MSgW__key.index-module__h8MSgW__noMobile {
          display: grid;
        }
      }

      .index-module__h8MSgW__alt {
        align-items: flex-start;
        display: flex;
      }

      .index-module__h8MSgW__alt.index-module__h8MSgW__alignRight {
        justify-content: flex-end;
      }

      .index-module__h8MSgW__alt.index-module__h8MSgW__alignCenter {
        justify-content: center;
      }

      .index-module__h8MSgW__alt > svg {
        color: var(--grey-300);
      }

      .index-module__h8MSgW__primary {
        align-items: flex-end;
        display: flex;
      }

      .index-module__h8MSgW__primary > span {
        color: var(--grey-200);
      }

      .index-module__h8MSgW__primary.index-module__h8MSgW__alignRight {
        justify-content: flex-end;
      }

      .index-module__h8MSgW__primary.index-module__h8MSgW__alignCenter {
        justify-content: center;
      }

      .index-module__h8MSgW__primary.index-module__h8MSgW__stretch {
        grid-row: 1 / span 2;
        justify-content: center;
        align-items: center;
      }

      .raycast-meta-row {
        margin-top: 6px;
        display: flex;
        flex-direction: column;
        gap: 6px;
        font-size: 0.82rem;
        color: rgba(255, 255, 255, 0.5);
      }

      .raycast-sha-pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 8px;
        padding: 5px 10px;
        font-family: 'DM Mono', monospace;
        font-size: 0.78rem;
        color: rgba(255, 255, 255, 0.7);
        width: fit-content;
      }

      .raycast-sha-btn {
        background: transparent;
        border: none;
        color: #6ECE9D;
        cursor: pointer;
        font-size: 0.75rem;
        font-weight: 600;
        padding: 0;
      }
`;

// Replace CSS section in index.html
const startMarkerCss = '/* Raycast Section 1: Download Hub (Gambar 1) */';
const endMarkerCss = '/* Raycast Section 2: Carousel Track (Gambar 2) */';

const startIndexCss = html.indexOf(startMarkerCss);
const endIndexCss = html.indexOf(endMarkerCss);

if (startIndexCss === -1 || endIndexCss === -1) {
  console.error('Could not find CSS markers in index.html');
  process.exit(1);
}

html = html.slice(0, startIndexCss) + raycastSectionCss.trim() + '\n\n      ' + html.slice(endIndexCss);

// 2. Prepare HTML markup replacement
const section1Markup = `
        <!-- Raycast Section 1: 1:1 Authentic Keyboard Hub -->
        <div class="GetYourTimeBack-module__o1EREW__container sal-animate" data-sal="slide-up">
            <div class="GetYourTimeBack-module__o1EREW__getYourTimeBack">
                <!-- Left Column: Copy & Download Button -->
                <div class="GetYourTimeBack-module__o1EREW__text">
                    <div class="SectionTitle-module__U5mb2W__container">
                        <h2>It’s not about saving time.</h2>
                        <p>It’s about feeling like you’re never wasting it.</p>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 14px; align-items: flex-start;">
                        <a class="Button-module__3dJGfa__button Button-module__3dJGfa__light GetYourTimeBack-module__o1EREW__downloadButton" href="https://github.com/HelloRayy/expense-tracker/releases/download/v1.0.0/app-release.apk" aria-disabled="false">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 16 16">
                                <path fill="currentColor" d="M12.665 15.358c-.905.844-1.893.711-2.843.311-1.006-.409-1.93-.427-2.991 0-1.33.551-2.03.391-2.825-.31C-.498 10.886.166 4.078 5.28 3.83c1.246.062 2.114.657 2.843.71 1.09-.213 2.133-.826 3.296-.746 1.393.107 2.446.64 3.138 1.6-2.88 1.662-2.197 5.315.443 6.337-.526 1.333-1.21 2.657-2.345 3.635zM8.03 2.923c.531-.692.934-1.638.796-2.61-.885.06-1.916.634-2.502 1.326-.499.58-.934 1.547-.783 2.474.968.08 1.958-.498 2.489-1.19z"></path>
                            </svg>
                            <span>Download APK</span>
                        </a>

                        <div class="raycast-meta-row">
                            <div class="raycast-sha-pill">
                                <span style="color: rgba(255,255,255,0.45); font-size: 0.72rem;">SHA-256:</span>
                                <span id="shaCode" style="letter-spacing: 0.02em;">a8b9e17c...a02931bc</span>
                                <button class="raycast-sha-btn" onclick="copyChecksum()" id="copyBtnText" title="Salin Full Hash">
                                    Salin
                                </button>
                            </div>
                            <div style="display: flex; align-items: center; gap: 10px; font-size: 0.78rem; color: rgba(255, 255, 255, 0.45); margin-top: 4px;">
                                <span>v1.0.0 Stable • Android 10+</span>
                                <span>•</span>
                                <a href="https://github.com/HelloRayy/expense-tracker/releases" target="_blank" rel="noreferrer" style="color: rgba(255, 255, 255, 0.75); text-decoration: underline;">GitHub Releases &rarr;</a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column: 1:1 Authentic Raycast Keyboard Layout -->
                <div class="GetYourTimeBack-module__o1EREW__keyboard">
                    ${kbHtml.trim()}
                </div>
            </div>

            <script>
                function copyChecksum() {
                    const fullHash = "a8b9e17c8d234a9f12089cfa65b219e48b4c09d57a3e2189fb409581a02931bc";
                    navigator.clipboard.writeText(fullHash).then(() => {
                        const btn = document.getElementById('copyBtnText');
                        btn.innerText = 'Tersalin!';
                        setTimeout(() => { btn.innerText = 'Salin'; }, 2000);
                    });
                }
            </script>
        </div>
`;

// Replace HTML section in index.html
const startMarkerHtml = '<!-- Raycast Section 1: Split Download Hub Hero (Gambar 1) -->';
const endMarkerHtml = '<!-- Raycast Section 2: Extensions Carousel Track (Gambar 2) -->';

const startIndexHtml = html.indexOf(startMarkerHtml);
const endIndexHtml = html.indexOf(endMarkerHtml);

if (startIndexHtml === -1 || endIndexHtml === -1) {
  console.error('Could not find HTML markers in index.html');
  process.exit(1);
}

// Find preceding <div class="section-content"> or keep section-content
html = html.slice(0, startIndexHtml) + section1Markup.trim() + '\n    </div>\n</section>\n\n' + html.slice(endIndexHtml);

fs.writeFileSync(indexPath, html, 'utf-8');
console.log('Successfully updated index.html with 1:1 authentic Raycast keyboard section!');
