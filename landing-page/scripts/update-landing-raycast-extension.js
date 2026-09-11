import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const indexPath = path.resolve(__dirname, '../index.html');

let html = fs.readFileSync(indexPath, 'utf-8');

// The replacement HTML for Section #fitur matching Raycast ExtensionHighlight 1:1
const newFiturSection = `<!-- Raycast Section 2: ExtensionHighlight Reel & Categories Capsule (1:1 Clone) -->
<section id="fitur" class="content" style="padding-top: 24px;">
    <div class="section-content" style="max-width: 100%; padding: 0;">
        <div class="raycast-section-card">
            <!-- Top Bar: Title & Categories Capsule Pill Bar -->
            <div class="raycast-top-bar">
                <div class="raycast-title-group">
                    <h2>Ada fitur cerdas untuk setiap rupiahmu.</h2>
                    <p>Kelola dan amankan uang jajan harian tanpa ribet buka aplikasi.</p>
                </div>
                <!-- Comment #2: .ExtensionHighlight-module__3Yq4tG__categories with activeBackdrop -->
                <div class="raycast-categories-container">
                    <div class="raycast-categories" id="raycastCategories">
                        <div class="raycast-active-backdrop" id="activeBackdrop"></div>
                        <div class="raycast-category-pill active" onclick="selectShowcaseCategory(0, 0, this)">
                            Widget Cepat
                        </div>
                        <div class="raycast-category-pill" onclick="selectShowcaseCategory(416, 1, this)">
                            Smart Nudge
                        </div>
                        <div class="raycast-category-pill" onclick="selectShowcaseCategory(832, 2, this)">
                            Amplop Mental
                        </div>
                        <div class="raycast-category-pill" onclick="selectShowcaseCategory(1248, 3, this)">
                            Privasi SQLite
                        </div>
                    </div>
                </div>
            </div>

            <!-- Comment #1: .ExtensionHighlight-module__3Yq4tG__reelContainer (Cards Reel Track) -->
            <div class="raycast-reel-container" id="showcaseTrack">
                <div class="raycast-reel-track">
                    <!-- Card 1: Widget 4x2 Interaktif (Linear Theme Style) -->
                    <div class="raycast-card raycast-card-1" id="card-widget-4x2">
                        <div class="raycast-card-header">
                            <div class="raycast-header-top">
                                <div style="display: flex; align-items: center;">
                                    <div class="raycast-icon-wrap" style="background: rgba(255, 255, 255, 0.04); border: 1px solid rgba(255, 255, 255, 0.12);">
                                        <div style="width: 32px; height: 32px; border-radius: 16px; background: linear-gradient(-135deg, #818cf8 14.6%, #4f46e5 85.4%); display: flex; align-items: center; justify-content: center;">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83Z"/><path d="m22 17.65-9.17 4.16a2 2 0 0 1-1.66 0L2 17.65"/><path d="m22 12.65-9.17 4.16a2 2 0 0 1-1.66 0L2 12.65"/></svg>
                                        </div>
                                    </div>
                                    <div class="raycast-title-box">
                                        <span class="raycast-card-title">Widget 4x2</span>
                                        <span class="raycast-card-subtitle" style="color: #818cf8;">Home Screen 1-Tap Log</span>
                                    </div>
                                </div>
                                <div class="raycast-action-btn">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
                                </div>
                            </div>
                            <p class="raycast-card-desc">Catat pengeluaran &lt; 2 detik langsung dari layar utama tanpa buka aplikasi.</p>
                            <div class="raycast-card-divider"></div>
                        </div>
                        <div class="raycast-card-stage">
                            <!-- Starry background decoration matching Raycast linear card -->
                            <div style="position: absolute; width: 2px; height: 2px; border-radius: 50%; background: rgba(255,255,255,0.4); top: 30px; left: 40px;"></div>
                            <div style="position: absolute; width: 2px; height: 2px; border-radius: 50%; background: rgba(255,255,255,0.3); top: 80px; left: 180px;"></div>
                            <div style="position: absolute; width: 2px; height: 2px; border-radius: 50%; background: rgba(255,255,255,0.5); top: 40px; left: 280px;"></div>
                            <!-- Linear Wireframe Horizon Arc -->
                            <div style="width: 260px; height: 260px; border-radius: 50%; border: 1.5px solid rgba(255,255,255,0.4); position: absolute; top: 15px; left: 50px;"></div>
                            <div style="width: 130px; height: 16px; border-radius: 8px; border: 1.5px solid rgba(255,255,255,0.4); position: absolute; top: 110px; left: 45px; transform: rotate(40deg); transform-origin: top left; background: rgba(255,255,255,0.04);"></div>
                            <div style="width: 110px; height: 16px; border-radius: 8px; border: 1.5px solid rgba(255,255,255,0.3); position: absolute; top: 140px; left: 35px; transform: rotate(40deg); transform-origin: top left; background: rgba(255,255,255,0.04);"></div>
                            <!-- Status Dock -->
                            <div style="position: absolute; bottom: 30px; width: 310px; display: flex; justify-content: center; gap: 16px; z-index: 5;">
                                <div style="width: 44px; height: 44px; border-radius: 22px; border: 1.5px dashed rgba(255,255,255,0.7); display: flex; align-items: center; justify-content: center;">
                                    <span style="font-size: 11px; font-weight: 600; color: #fff;">10k</span>
                                </div>
                                <div style="width: 44px; height: 44px; border-radius: 22px; border: 3px solid #ffffff; box-shadow: 0 0 14px rgba(255,255,255,0.7); display: flex; align-items: center; justify-content: center;">
                                    <span style="font-size: 11px; font-weight: 600; color: #fff;">20k</span>
                                </div>
                                <div style="width: 44px; height: 44px; border-radius: 22px; border: 3px solid #f59e0b; box-shadow: 0 0 14px rgba(245,158,11,0.6); display: flex; align-items: center; justify-content: center; background: rgba(245,158,11,0.15);">
                                    <span style="font-size: 11px; font-weight: 600; color: #f59e0b;">50k</span>
                                </div>
                                <div style="width: 44px; height: 44px; border-radius: 22px; background: #707bfb; box-shadow: 0 0 16px rgba(112,123,251,0.8); display: flex; align-items: center; justify-content: center;">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Card 2: Smart Nudge (Shopee/QRIS Radar) -->
                    <div class="raycast-card raycast-card-2" id="card-smart-nudge">
                        <div class="raycast-card-header">
                            <div class="raycast-header-top">
                                <div style="display: flex; align-items: center;">
                                    <div class="raycast-icon-wrap" style="background: linear-gradient(-135deg, #0284c7 14.6%, #0369a1 85.4%); border: 1px solid rgba(255, 255, 255, 0.2);">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/><path d="M4 2C2.8 3.7 2 5.7 2 8"/><path d="M22 8c0-2.3-.8-4.3-2-6"/></svg>
                                    </div>
                                    <div class="raycast-title-box">
                                        <span class="raycast-card-title">Smart Nudge</span>
                                        <span class="raycast-card-subtitle" style="color: #38bdf8;">Shopee &amp; QRIS Radar</span>
                                    </div>
                                </div>
                                <div class="raycast-action-btn">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
                                </div>
                            </div>
                            <p class="raycast-card-desc">Floating chip otomatis melayang lembut selama 6 detik saat membuka app belanja.</p>
                            <div class="raycast-card-divider"></div>
                        </div>
                        <div class="raycast-card-stage" style="padding: 20px;">
                            <div style="width: 100%; max-width: 320px; background: #091322; border: 1.2px solid rgba(56, 189, 248, 0.35); border-radius: 16px; padding: 16px; box-shadow: 0 12px 28px rgba(0,0,0,0.6); display: flex; flex-direction: column; gap: 14px;">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <div style="display: flex; align-items: center; gap: 8px;">
                                        <div style="width: 8px; height: 8px; border-radius: 4px; background: #fb923c; box-shadow: 0 0 8px #fb923c;"></div>
                                        <span style="font-size: 12px; font-weight: 600; color: #fb923c;">Shopee Terdeteksi</span>
                                    </div>
                                    <span style="font-size: 11px; color: #787a85;">⏳ 5s</span>
                                </div>
                                <div style="background: #0f2238; border: 1px solid rgba(56, 189, 248, 0.2); border-radius: 12px; padding: 12px 14px; display: flex; align-items: center; gap: 12px;">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#38bdf8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/></svg>
                                    <div>
                                        <div style="font-size: 13px; font-weight: 600; color: #ffffff;">Sisa Uang Jajan: Rp 120.000</div>
                                        <div style="font-size: 11px; color: #93c5fd;">Yakin mau checkout sekarang?</div>
                                    </div>
                                </div>
                                <div style="display: flex; align-items: center; justify-content: center; gap: 6px;">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/><path d="m9 12 2 2 4-4"/></svg>
                                    <span style="font-size: 10px; color: #64748b;">0 Keystroke Log • Package ID Match Only</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Card 3: Amplop Mental (Budget Separation) -->
                    <div class="raycast-card raycast-card-3" id="card-amplop-mental">
                        <div class="raycast-card-header">
                            <div class="raycast-header-top">
                                <div style="display: flex; align-items: center;">
                                    <div class="raycast-icon-wrap" style="background: linear-gradient(-135deg, #d97706 14.6%, #b45309 85.4%); border: 1px solid rgba(255, 255, 255, 0.2);">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12V7H5a2 2 0 0 1 0-4h14v4"/><path d="M3 5v14a2 2 0 0 0 2 2h16v-5"/><path d="M18 12a2 2 0 0 0 0 4h4v-4Z"/></svg>
                                    </div>
                                    <div class="raycast-title-box">
                                        <span class="raycast-card-title">Amplop Mental</span>
                                        <span class="raycast-card-subtitle" style="color: #fbbf24;">Strict Budget Separation</span>
                                    </div>
                                </div>
                                <div class="raycast-action-btn">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
                                </div>
                            </div>
                            <p class="raycast-card-desc">Pisahkan Uang Pokok (kos, tagihan) dari Uang Jajan bebas tanpa rasa bersalah.</p>
                            <div class="raycast-card-divider"></div>
                        </div>
                        <div class="raycast-card-stage" style="padding: 20px;">
                            <div style="width: 100%; max-width: 320px; background: #140e05; border: 1.2px solid rgba(251, 191, 36, 0.3); border-radius: 16px; padding: 14px; box-shadow: 0 12px 28px rgba(0,0,0,0.6); display: flex; flex-direction: column; gap: 10px;">
                                <div style="background: #1e160a; border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 10px; padding: 12px; display: flex; justify-content: space-between; align-items: center;">
                                    <div style="display: flex; align-items: center; gap: 8px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                                        <div>
                                            <div style="font-size: 11px; font-weight: 600; color: #e2e8f0;">Uang Pokok (Terkunci)</div>
                                            <div style="font-size: 10px; color: #64748b;">Kos, Listrik, Tabungan</div>
                                        </div>
                                    </div>
                                    <div style="font-size: 13px; font-weight: 700; color: #cbd5e1;">Rp 3.500.000</div>
                                </div>
                                <div style="background: rgba(251, 191, 36, 0.12); border: 1px solid rgba(251, 191, 36, 0.4); border-radius: 10px; padding: 12px; display: flex; justify-content: space-between; align-items: center;">
                                    <div style="display: flex; align-items: center; gap: 8px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#fbbf24" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 8h1a4 4 0 1 1 0 8h-1"/><path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4Z"/><line x1="6" x2="6" y1="2" y2="4"/><line x1="10" x2="10" y1="2" y2="4"/><line x1="14" x2="14" y1="2" y2="4"/></svg>
                                        <div>
                                            <div style="font-size: 11px; font-weight: 600; color: #fbbf24;">Uang Jajan Bebas</div>
                                            <div style="font-size: 10px; color: rgba(251, 191, 36, 0.8);">Boleh dihabiskan</div>
                                        </div>
                                    </div>
                                    <div style="font-size: 13px; font-weight: 700; color: #fbbf24;">Rp 750.000</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Card 4: Privasi SQLite (100% Offline & Local) -->
                    <div class="raycast-card raycast-card-4" id="card-privasi-sqlite">
                        <div class="raycast-card-header">
                            <div class="raycast-header-top">
                                <div style="display: flex; align-items: center;">
                                    <div class="raycast-icon-wrap" style="background: linear-gradient(-135deg, #a855f7 14.6%, #7e22ce 85.4%); border: 1px solid rgba(255, 255, 255, 0.2);">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M3 5V19A9 3 0 0 0 21 19V5"/><path d="M3 12A9 3 0 0 0 21 12"/></svg>
                                    </div>
                                    <div class="raycast-title-box">
                                        <span class="raycast-card-title">Privasi SQLite</span>
                                        <span class="raycast-card-subtitle" style="color: #c084fc;">100% Offline &amp; Lokal</span>
                                    </div>
                                </div>
                                <div class="raycast-action-btn">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
                                </div>
                            </div>
                            <p class="raycast-card-desc">Data keuangan tersimpan aman di internal HP tanpa kirim ke cloud atau server.</p>
                            <div class="raycast-card-divider"></div>
                        </div>
                        <div class="raycast-card-stage" style="padding: 20px;">
                            <div style="width: 100%; max-width: 320px; background: #130924; border: 1.2px solid rgba(168, 85, 247, 0.35); border-radius: 16px; padding: 14px; box-shadow: 0 12px 28px rgba(0,0,0,0.6); display: flex; flex-direction: column; gap: 10px;">
                                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 8px;">
                                    <span style="font-size: 11px; font-weight: 600; color: #c084fc;">Enkripsi Room SQLite v3.45</span>
                                    <span style="font-size: 10px; color: #34d399; display: flex; align-items: center; gap: 4px;">
                                        <span style="width: 6px; height: 6px; border-radius: 3px; background: #34d399;"></span>
                                        Terenkripsi
                                    </span>
                                </div>
                                <div style="background: rgba(255,255,255,0.03); border-radius: 8px; padding: 8px 10px; font-size: 11px; color: #cbd5e1; display: flex; justify-content: space-between;">
                                    <span>Penyimpanan Lokal:</span>
                                    <span style="color: #ffffff; font-weight: 600;">/data/user/0/app</span>
                                </div>
                                <div style="background: rgba(255,255,255,0.03); border-radius: 8px; padding: 8px 10px; font-size: 11px; color: #cbd5e1; display: flex; justify-content: space-between;">
                                    <span>Akses Internet:</span>
                                    <span style="color: #34d399; font-weight: 600;">0 Permission (Nol)</span>
                                </div>
                                <div style="background: rgba(255,255,255,0.03); border-radius: 8px; padding: 8px 10px; font-size: 11px; color: #cbd5e1; display: flex; justify-content: space-between;">
                                    <span>Ketergantungan Cloud:</span>
                                    <span style="color: #34d399; font-weight: 600;">Nir-Server (100% Offline)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Showcase Reel Bottom Bar: Browse link & Prev/Next buttons -->
            <div class="raycast-bottom-bar">
                <a href="#fitur" class="raycast-browse-link">
                    <span>Pelajari seluruh arsitektur fitur</span>
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
                </a>
                <div style="display: flex; gap: 12px; align-items: center;">
                    <button type="button" onclick="scrollShowcaseStep(-1)" aria-label="Previous feature" class="raycast-nav-btn">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
                    </button>
                    <button type="button" onclick="scrollShowcaseStep(1)" aria-label="Next feature" class="raycast-nav-btn">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
                    </button>
                </div>
            </div>
        </div>

        <script>
            function selectShowcaseCategory(scrollPos, pillIndex, pillEl) {
                const track = document.getElementById("showcaseTrack");
                if (track) {
                    track.scrollTo({ left: scrollPos, behavior: "smooth" });
                }
                const pills = document.querySelectorAll(".raycast-category-pill");
                pills.forEach(p => p.classList.remove("active"));
                if (pillEl) {
                    pillEl.classList.add("active");
                    updateActiveBackdrop(pillEl);
                }
            }

            function updateActiveBackdrop(pillEl) {
                const backdrop = document.getElementById("activeBackdrop");
                if (!backdrop || !pillEl) return;
                backdrop.style.width = pillEl.offsetWidth + "px";
                backdrop.style.transform = "translate3d(" + pillEl.offsetLeft + "px, 0, 0)";
            }

            function scrollShowcaseStep(direction) {
                const track = document.getElementById("showcaseTrack");
                if (track) {
                    const step = 416; // 360px card + 56px gap
                    track.scrollBy({ left: direction * step, behavior: "smooth" });
                }
            }

            // Initialize active backdrop on load
            window.addEventListener("DOMContentLoaded", function() {
                const activePill = document.querySelector(".raycast-category-pill.active");
                if (activePill) {
                    setTimeout(function() { updateActiveBackdrop(activePill); }, 50);
                }
            });
            window.addEventListener("resize", function() {
                const activePill = document.querySelector(".raycast-category-pill.active");
                if (activePill) {
                    updateActiveBackdrop(activePill);
                }
            });
        </script>
    </div>
</section>`;

// CSS styles to inject into <style id="visual-diff-freeze"> or main style block
const raycastCSS = `
      /* === RAYCAST SECTION 2: EXTENSION HIGHLIGHT & CATEGORIES 1:1 TOKENS === */
      .raycast-section-card {
        box-sizing: border-box;
        width: 100%;
        max-width: 1440px;
        margin: 0 auto;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: flex-start;
        gap: 36px;
        padding: 80px 0;
        background-color: #0a0a0c;
        color: #ffffff;
        border-radius: 24px;
        overflow: hidden;
        position: relative;
      }
      .raycast-top-bar {
        box-sizing: border-box;
        width: 100%;
        max-width: 1204px;
        margin: 0 auto;
        padding: 0 32px;
        display: flex;
        flex-direction: row;
        flex-wrap: nowrap;
        justify-content: space-between;
        align-items: center;
        gap: 24px;
      }
      .raycast-title-group {
        flex: 1 1 auto;
        max-width: 520px;
        text-align: left;
      }
      .raycast-title-group h2 {
        font-size: 26px;
        font-weight: 600;
        letter-spacing: -0.4px;
        color: #ffffff;
        line-height: 1.25;
        margin: 0 0 6px 0;
        text-align: left;
      }
      .raycast-title-group p {
        font-size: 15px;
        color: #8f9099;
        margin: 0;
        line-height: 1.4;
        text-align: left;
      }
      .raycast-categories-container {
        flex-shrink: 0;
        padding: 0;
        display: flex;
        align-items: center;
      }
      @media (max-width: 860px) {
        .raycast-top-bar {
          flex-direction: column;
          align-items: flex-start;
          gap: 20px;
          padding: 0 20px;
        }
        .raycast-categories-container {
          width: 100%;
          overflow-x: auto;
          scrollbar-width: none;
          -webkit-overflow-scrolling: touch;
        }
        .raycast-categories-container::-webkit-scrollbar {
          display: none;
        }
      }
      .raycast-categories {
        height: 63px;
        padding: 8px 12px;
        background: linear-gradient(137deg, rgb(17, 18, 20) 4.87%, rgb(12, 13, 15) 75.88%);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 31px;
        box-shadow: rgba(255, 255, 255, 0.1) 0px 1px 0px 0px inset;
        display: flex;
        align-items: center;
        position: relative;
        gap: 4px;
      }
      .raycast-active-backdrop {
        position: absolute;
        top: 8px;
        left: 0;
        height: 46px;
        border-radius: 36px;
        background: radial-gradient(51.07% 92.4% at 51% 7.61%, rgb(90, 90, 90) 0%, rgb(26, 26, 26) 100%);
        backdrop-filter: blur(2px);
        -webkit-backdrop-filter: blur(2px);
        box-shadow: 0px 1px 0px 0px rgba(255, 255, 255, 0.15) inset;
        transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), width 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        pointer-events: none;
        z-index: 0;
      }
      .raycast-category-pill {
        position: relative;
        z-index: 1;
        height: 46px;
        padding: 0 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        font-weight: 500;
        letter-spacing: 0.2px;
        color: rgb(106, 107, 108);
        cursor: pointer;
        white-space: nowrap;
        transition: color 0.2s ease;
        user-select: none;
        border-radius: 36px;
      }
      .raycast-category-pill.active {
        color: #ffffff;
      }
      .raycast-category-pill:hover:not(.active) {
        color: #ffffff;
      }
      .raycast-reel-container {
        box-sizing: border-box;
        width: 100%;
        padding: 40px 0;
        margin: -40px 0;
        overflow-x: auto;
        scrollbar-width: none;
        scroll-behavior: smooth;
        scroll-snap-type: x mandatory;
      }
      .raycast-reel-container::-webkit-scrollbar {
        display: none;
      }
      .raycast-reel-track {
        box-sizing: border-box;
        display: inline-flex;
        flex-direction: row;
        gap: 56px;
        padding: 0 24px;
        margin: 0;
      }
      @media (min-width: 1250px) {
        .raycast-reel-track {
          padding-left: calc((100vw - 1204px) / 2);
          padding-right: calc((100vw - 1204px) / 2);
        }
      }
      .raycast-card {
        box-sizing: border-box;
        width: 360px;
        height: 536px;
        flex-shrink: 0;
        border-radius: 20px;
        display: grid;
        grid-template-rows: auto 1fr;
        overflow: hidden;
        position: relative;
        scroll-snap-align: start;
        transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      }
      .raycast-card:hover {
        transform: translateY(-2px);
      }
      .raycast-card-1 {
        background: linear-gradient(138deg, rgba(32, 35, 91, 0.70) 22%, rgba(7, 9, 33, 0.70) 82%);
        box-shadow: rgba(255, 255, 255, 0.1) 0px 1px 0px 0px inset, rgba(7, 13, 79, 0.05) 0px 0px 20px 3px, rgba(7, 13, 79, 0.05) 0px 0px 40px 20px, rgba(255, 255, 255, 0.06) 0px 0px 0px 1px inset;
      }
      .raycast-card-2 {
        background: radial-gradient(94.21% 78.40% at 50% 29.91%, rgba(43, 94, 180, 0.70), rgba(13, 16, 35, 0.42));
        box-shadow: rgba(255, 255, 255, 0.1) 0px 1px 0px 0px inset, rgba(7, 13, 79, 0.10) 0px 0px 20px 3px, rgba(85, 0, 98, 0.10) 0px 0px 40px 20px, rgba(255, 255, 255, 0.06) 0px 0px 0px 1px inset;
      }
      .raycast-card-3 {
        background: radial-gradient(30% 40% at 52% 36.91%, rgba(180, 83, 9, 0.85), rgba(69, 26, 3, 0.85));
        box-shadow: rgba(255, 255, 255, 0.1) 0px 1px 0px 0px inset, rgba(245, 158, 11, 0.08) 0px 0px 20px 3px, rgba(245, 158, 11, 0.05) 0px 0px 40px 20px, rgba(255, 255, 255, 0.06) 0px 0px 0px 1px inset;
      }
      .raycast-card-4 {
        background: radial-gradient(86.88% 75.47% at 50% 24.53%, rgba(82, 48, 145, 0.70), rgba(26, 11, 51, 0.40));
        box-shadow: rgba(255, 255, 255, 0.1) 0px 1px 0px 0px inset, rgba(51, 3, 129, 0.09) 0px 4px 24px 0px, rgba(255, 255, 255, 0.06) 0px 0px 0px 1px inset;
      }
      .raycast-card-header {
        padding: 24px 24px 0 24px;
        display: flex;
        flex-direction: column;
        gap: 12px;
      }
      .raycast-header-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
      }
      .raycast-icon-wrap {
        width: 56px;
        height: 56px;
        border-radius: 12px;
        box-shadow: rgba(0, 0, 0, 0.28) 0px 1.189px 2.377px 0px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
      }
      .raycast-title-box {
        display: flex;
        flex-direction: column;
        margin-left: 14px;
        flex-grow: 1;
      }
      .raycast-card-title {
        font-size: 18px;
        font-weight: 500;
        line-height: 20.7px;
        color: #ffffff;
      }
      .raycast-card-subtitle {
        font-size: 12px;
        font-weight: 500;
        margin-top: 3px;
      }
      .raycast-action-btn {
        width: 36px;
        height: 36px;
        border-radius: 8px;
        border: 1px solid rgba(255, 255, 255, 0.25);
        background: linear-gradient(180deg, rgba(255, 255, 255, 0.03) 0%, rgba(255, 255, 255, 0.1) 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0px 1px 0px 0px rgba(255, 255, 255, 0.05) inset;
        color: #e6e6e6;
        transition: all 0.2s ease;
      }
      .raycast-card:hover .raycast-action-btn {
        border-color: rgba(255, 255, 255, 0.5);
        box-shadow: rgba(255, 255, 255, 0.05) 0px 1px inset, rgba(255, 255, 255, 0.5) 0px 0px 0px 1px;
      }
      .raycast-card-desc {
        font-size: 16px;
        font-weight: 500;
        line-height: 25.6px;
        color: #ffffff;
        width: 312px;
        margin: 0;
      }
      .raycast-card-divider {
        width: 100%;
        height: 1px;
        background: rgba(255, 255, 255, 0.06);
      }
      .raycast-card-stage {
        width: 360px;
        height: 360px;
        overflow: hidden;
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      .raycast-bottom-bar {
        box-sizing: border-box;
        width: 100%;
        max-width: 1204px;
        padding: 0 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .raycast-browse-link {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 15px;
        font-weight: 500;
        color: #9c9c9d;
        text-decoration: none;
        transition: color 0.2s ease;
      }
      .raycast-browse-link:hover {
        color: #ffffff;
      }
      .raycast-nav-btn {
        width: 44px;
        height: 44px;
        border-radius: 22px;
        background: linear-gradient(137deg, rgb(17, 18, 20) 4.87%, rgb(12, 13, 15) 75.88%);
        border: 1.5px solid rgba(255, 255, 255, 0.08);
        box-shadow: rgba(255, 255, 255, 0.1) 0px 1px inset;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #6a6b6c;
        cursor: pointer;
        transition: all 0.2s ease;
      }
      .raycast-nav-btn:hover {
        color: #ffffff;
        border-color: rgba(255, 255, 255, 0.2);
        box-shadow: rgba(255, 255, 255, 0.1) 0px 1px 1px inset, rgba(154, 170, 255, 0.05) 0px 2px 40px 10px;
      }
`;

// 1. Inject CSS before </style> in head
if (!html.includes('.raycast-section-card')) {
  html = html.replace('</style>', `${raycastCSS}\n    </style>`);
}

// 2. Replace the #fitur section
const fiturStart = html.indexOf('<section id="fitur"');
const faqStart = html.indexOf('<section id="faq"');

if (fiturStart === -1 || faqStart === -1) {
  console.error('Could not find #fitur or #faq section markers!');
  process.exit(1);
}

const before = html.substring(0, fiturStart);
const after = html.substring(faqStart);

const updatedHtml = before + newFiturSection + '\n\n' + after;

fs.writeFileSync(indexPath, updatedHtml, 'utf-8');
console.log('Successfully updated landing-page/index.html with 1:1 Raycast ExtensionHighlight!');
