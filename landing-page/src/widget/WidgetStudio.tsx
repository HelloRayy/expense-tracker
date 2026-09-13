import { useState } from 'react'
import {
  ArrowLeft,
  Check,
  Code2,
  Copy,
  Moon,
  Smartphone,
  Sun,
  Sliders,
  Sparkles,
  RefreshCw,
  Layers,
} from 'lucide-react'
import { HomeWidget4x2 } from './HomeWidget4x2'

type TabMode = 'side-by-side' | 'dark' | 'light' | 'homescreen'
type CodeTab = 'react' | 'tailwind' | 'flutter'

export function WidgetStudio() {
  const [userName, setUserName] = useState('Raditya Rayhan')
  const [dailyAllowance, setDailyAllowance] = useState(50000)
  const [weeklyIncome, setWeeklyIncome] = useState(1500000)
  const [totalSpent, setTotalSpent] = useState(205000)
  const [tabMode, setTabMode] = useState<TabMode>('side-by-side')
  const [codeTab, setCodeTab] = useState<CodeTab>('react')
  const [copied, setCopied] = useState(false)

  const handleCopy = (text: string) => {
    navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const applyPreset = (preset: 'normal' | 'payday' | 'lowBudget' | 'highExpense') => {
    switch (preset) {
      case 'normal':
        setDailyAllowance(50000)
        setWeeklyIncome(1500000)
        setTotalSpent(205000)
        break
      case 'payday':
        setDailyAllowance(125000)
        setWeeklyIncome(4500000)
        setTotalSpent(150000)
        break
      case 'lowBudget':
        setDailyAllowance(25000)
        setWeeklyIncome(750000)
        setTotalSpent(680000)
        break
      case 'highExpense':
        setDailyAllowance(40000)
        setWeeklyIncome(1200000)
        setTotalSpent(1150000)
        break
    }
  }

  const reactCode = `import React from 'react'
import { ArrowDown, ArrowUp } from 'lucide-react'

export interface HomeWidget4x2Props {
  userName?: string
  dailyAllowance: number
  weeklyIncome: number
  totalSpent: number
  isDark?: boolean
}

export function formatRupiah(amount: number): string {
  const rounded = Math.round(amount)
  return 'Rp ' + rounded.toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, '.')
}

export function HomeWidget4x2({
  userName = '${userName}',
  dailyAllowance = ${dailyAllowance},
  weeklyIncome = ${weeklyIncome},
  totalSpent = ${totalSpent},
  isDark = true,
}: HomeWidget4x2Props) {
  const bg = isDark ? '#0C0D10' : '#FFFFFF'
  const border = isDark ? 'rgba(39, 39, 42, 0.5)' : '#E4E4E7'
  const shadow = isDark ? '0 6px 16px rgba(0,0,0,0.35)' : '0 6px 16px rgba(0,0,0,0.06)'
  const textPrimary = isDark ? '#EDEDED' : '#0C0C0E'
  const textSecondary = isDark ? '#A1A1AA' : '#71717A'
  const greenColor = isDark ? '#4ADE80' : '#16A34A'
  const redColor = isDark ? '#F87171' : '#DC2626'

  return (
    <div
      style={{ backgroundColor: bg, boxShadow: shadow, borderColor: border }}
      className="relative w-full max-w-[360px] h-[180px] rounded-[24px] border overflow-hidden select-none font-sans"
    >
      {/* 1. Radial Coin Glow */}
      <div
        className="absolute -top-[26px] -right-[35px] w-[219px] h-[219px] rounded-full pointer-events-none"
        style={{
          background: isDark
            ? 'radial-gradient(circle, rgba(59, 130, 246, 0.12) 0%, rgba(0, 0, 0, 0) 70%)'
            : 'radial-gradient(circle, rgba(59, 130, 246, 0.08) 0%, rgba(0, 0, 0, 0) 70%)',
        }}
      />

      {/* 2. Coins Illustration (pen.dev) */}
      <img
        src="/images/coins_illustration.png"
        alt="Coins illustration"
        className="absolute top-[19px] -right-[60px] w-[221px] h-[195px] object-contain pointer-events-none select-none"
      />

      {/* 3. Left Content */}
      <div className="relative z-10 w-full h-full px-[20px] py-[22px] flex flex-col justify-between">
        <div>
          <div style={{ color: textPrimary }} className="text-[16px] font-semibold tracking-[-0.2px] leading-tight">
            Hi, {userName}
          </div>
          <div style={{ color: textSecondary }} className="text-[13px] font-normal mt-1 leading-tight">
            Batas jajan hari ini
          </div>
        </div>

        <div className="flex items-baseline gap-1">
          <span style={{ color: textPrimary }} className="text-[32px] font-bold tracking-[-0.8px] leading-none">
            {formatRupiah(dailyAllowance)}
          </span>
          <span style={{ color: textSecondary }} className="text-[15px] font-medium leading-none">
            /hari
          </span>
        </div>

        <div className="flex items-center gap-3">
          <div className="inline-flex items-center gap-1" style={{ color: greenColor }}>
            <ArrowDown size={15} strokeWidth={2.4} />
            <span className="text-[15px] font-semibold tracking-[-0.2px] leading-none">
              {formatRupiah(weeklyIncome)}
            </span>
          </div>
          <div className="inline-flex items-center gap-1" style={{ color: redColor }}>
            <ArrowUp size={15} strokeWidth={2.4} />
            <span className="text-[15px] font-semibold tracking-[-0.2px] leading-none">
              {formatRupiah(totalSpent)}
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}`

  const tailwindHtml = `<!-- 4x2 Android Widget (pen.dev E7Zt3L Replica) -->
<div class="relative w-full max-w-[360px] h-[180px] rounded-[24px] bg-[#0C0D10] border border-[#27272A]/50 shadow-[0_6px_16px_rgba(0,0,0,0.35)] overflow-hidden select-none font-sans">
  <div class="absolute -top-[26px] -right-[35px] w-[219px] h-[219px] rounded-full pointer-events-none bg-[radial-gradient(circle,rgba(59,130,246,0.12)_0%,transparent_70%)]"></div>
  <img src="/images/coins_illustration.png" class="absolute top-[19px] -right-[60px] w-[221px] h-[195px] object-contain pointer-events-none" />

  <div class="relative z-10 w-full h-full px-[20px] py-[22px] flex flex-col justify-between">
    <div>
      <div class="text-[#EDEDED] text-[16px] font-semibold tracking-[-0.2px] leading-tight">Hi, ${userName}</div>
      <div class="text-[#A1A1AA] text-[13px] font-normal mt-1 leading-tight">Batas jajan hari ini</div>
    </div>

    <div class="flex items-baseline gap-1">
      <span class="text-[#EDEDED] text-[32px] font-bold tracking-[-0.8px] leading-none">Rp ${(dailyAllowance).toLocaleString('id-ID')}</span>
      <span class="text-[#A1A1AA] text-[15px] font-medium leading-none">/hari</span>
    </div>

    <div class="flex items-center gap-3">
      <div class="inline-flex items-center gap-1 text-[#4ADE80]">
        <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 5v14M19 12l-7 7-7-7"/>
        </svg>
        <span class="text-[15px] font-semibold tracking-[-0.2px] leading-none">Rp ${(weeklyIncome).toLocaleString('id-ID')}</span>
      </div>
      <div class="inline-flex items-center gap-1 text-[#F87171]">
        <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 19V5M5 12l7-7 7 7"/>
        </svg>
        <span class="text-[15px] font-semibold tracking-[-0.2px] leading-none">Rp ${(totalSpent).toLocaleString('id-ID')}</span>
      </div>
    </div>
  </div>
</div>`

  const flutterDart = `import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class HomeWidget4x2Card extends StatelessWidget {
  final String userName;
  final int dailyAllowance;
  final int weeklyIncome;
  final int totalSpent;
  final bool isDark;
  final VoidCallback? onTap;

  const HomeWidget4x2Card({
    super.key,
    this.userName = '${userName}',
    required this.dailyAllowance,
    required this.weeklyIncome,
    required this.totalSpent,
    this.isDark = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? PirschColors.darkBg : PirschColors.lightBg;
    final borderColor = isDark ? PirschColors.darkBorder : PirschColors.lightBorder;
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);
    final greenColor = PirschColors.green(isDark);
    final redColor = PirschColors.red(isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $userName',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Batas jajan hari ini',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    CurrencyFormatter.format(dailyAllowance),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/hari',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_downward_rounded, size: 16, color: greenColor),
                      const SizedBox(width: 4),
                      Text(
                        CurrencyFormatter.format(weeklyIncome),
                        style: TextStyle(
                          color: greenColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward_rounded, size: 16, color: redColor),
                      const SizedBox(width: 4),
                      Text(
                        CurrencyFormatter.format(totalSpent),
                        style: TextStyle(
                          color: redColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}`

  const currentCode = codeTab === 'react' ? reactCode : codeTab === 'tailwind' ? tailwindHtml : flutterDart

  return (
    <div className="min-h-screen bg-[#09090B] text-[#EDEDED] font-sans">
      {/* Top Navigation */}
      <header className="sticky top-0 z-40 border-b border-white/10 bg-[#09090B]/80 backdrop-blur-md px-6 py-4">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-4">
            <a
              href="/"
              className="inline-flex items-center gap-2 text-xs font-semibold text-neutral-400 hover:text-white transition-colors bg-white/5 hover:bg-white/10 px-3 py-1.5 rounded-lg border border-white/10"
            >
              <ArrowLeft size={14} />
              Landing Page
            </a>
            <div className="h-4 w-[1px] bg-white/10" />
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-base font-bold text-white tracking-tight">
                  Widget Studio &amp; Redesign Lab
                </h1>
                <span className="text-[11px] font-semibold bg-[#6578C8]/20 text-[#8F9FE6] border border-[#6578C8]/30 px-2 py-0.5 rounded-full">
                  Android 4x2
                </span>
              </div>
              <p className="text-xs text-neutral-400">
                100% pixel-perfect replica of Flutter HomeWidget4x2Card
              </p>
            </div>
          </div>

          {/* Quick preset buttons */}
          <div className="hidden md:flex items-center gap-2">
            <span className="text-xs text-neutral-400 flex items-center gap-1">
              <Sparkles size={12} /> Preset:
            </span>
            <button
              onClick={() => applyPreset('normal')}
              className="text-xs px-2.5 py-1 rounded bg-white/5 hover:bg-white/10 border border-white/10 transition-colors"
            >
              Default
            </button>
            <button
              onClick={() => applyPreset('payday')}
              className="text-xs px-2.5 py-1 rounded bg-white/5 hover:bg-white/10 border border-white/10 transition-colors"
            >
              Gajian
            </button>
            <button
              onClick={() => applyPreset('lowBudget')}
              className="text-xs px-2.5 py-1 rounded bg-white/5 hover:bg-white/10 border border-white/10 transition-colors"
            >
              Krisis
            </button>
          </div>
        </div>
      </header>

      {/* Main Workspace Layout */}
      <main className="max-w-7xl mx-auto px-4 py-8 grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Left / Center Preview Column */}
        <div className="lg:col-span-7 flex flex-col gap-6">
          {/* View Mode Bar */}
          <div className="flex items-center justify-between bg-white/[0.03] border border-white/10 p-1.5 rounded-xl">
            <div className="flex items-center gap-1">
              <button
                onClick={() => setTabMode('side-by-side')}
                className={`flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-lg transition-colors ${
                  tabMode === 'side-by-side'
                    ? 'bg-white/15 text-white shadow-sm'
                    : 'text-neutral-400 hover:text-white'
                }`}
              >
                <Layers size={13} />
                Side by Side
              </button>
              <button
                onClick={() => setTabMode('dark')}
                className={`flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-lg transition-colors ${
                  tabMode === 'dark'
                    ? 'bg-white/15 text-white shadow-sm'
                    : 'text-neutral-400 hover:text-white'
                }`}
              >
                <Moon size={13} />
                Dark Only
              </button>
              <button
                onClick={() => setTabMode('light')}
                className={`flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-lg transition-colors ${
                  tabMode === 'light'
                    ? 'bg-white/15 text-white shadow-sm'
                    : 'text-neutral-400 hover:text-white'
                }`}
              >
                <Sun size={13} />
                Light Only
              </button>
              <button
                onClick={() => setTabMode('homescreen')}
                className={`flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-lg transition-colors ${
                  tabMode === 'homescreen'
                    ? 'bg-white/15 text-white shadow-sm'
                    : 'text-neutral-400 hover:text-white'
                }`}
              >
                <Smartphone size={13} />
                Homescreen
              </button>
            </div>

            <span className="text-[11px] text-neutral-500 font-mono hidden sm:inline">
              360px × 180px (r: 24px)
            </span>
          </div>

          {/* Interactive Canvas Canvas */}
          <div className="rounded-2xl border border-white/10 bg-[#121215] p-6 flex flex-col items-center justify-center min-h-[440px] relative overflow-hidden">
            {/* Background grid pattern */}
            <div
              className="absolute inset-0 opacity-[0.03] pointer-events-none"
              style={{
                backgroundImage:
                  'radial-gradient(circle, #ffffff 1px, transparent 1px)',
                backgroundSize: '24px 24px',
              }}
            />

            {/* Side-by-side View */}
            {tabMode === 'side-by-side' && (
              <div className="w-full flex flex-col gap-8 items-center z-10">
                {/* Dark Mode Card */}
                <div className="w-full max-w-[360px]">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-[11px] font-medium text-neutral-400 flex items-center gap-1">
                      <Moon size={12} /> Dark Mode (Onyx #0C0C0E)
                    </span>
                    <span className="text-[10px] text-neutral-500 font-mono">100% Match</span>
                  </div>
                  <HomeWidget4x2
                    userName={userName}
                    dailyAllowance={dailyAllowance}
                    weeklyIncome={weeklyIncome}
                    totalSpent={totalSpent}
                    isDark={true}
                  />
                </div>

                {/* Light Mode Card */}
                <div className="w-full max-w-[360px]">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-[11px] font-medium text-neutral-400 flex items-center gap-1">
                      <Sun size={12} /> Light Mode (Beige #F5F6FA)
                    </span>
                    <span className="text-[10px] text-neutral-500 font-mono">100% Match</span>
                  </div>
                  <HomeWidget4x2
                    userName={userName}
                    dailyAllowance={dailyAllowance}
                    weeklyIncome={weeklyIncome}
                    totalSpent={totalSpent}
                    isDark={false}
                  />
                </div>
              </div>
            )}

            {/* Dark Only View */}
            {tabMode === 'dark' && (
              <div className="w-full max-w-[360px] z-10 flex flex-col items-center">
                <div className="w-full flex items-center justify-between mb-2">
                  <span className="text-[11px] font-medium text-neutral-400 flex items-center gap-1">
                    <Moon size={12} /> Dark Mode
                  </span>
                  <span className="text-[10px] text-emerald-400 font-mono">Pirsch Theme</span>
                </div>
                <HomeWidget4x2
                  userName={userName}
                  dailyAllowance={dailyAllowance}
                  weeklyIncome={weeklyIncome}
                  totalSpent={totalSpent}
                  isDark={true}
                />
              </div>
            )}

            {/* Light Only View */}
            {tabMode === 'light' && (
              <div className="w-full max-w-[360px] z-10 flex flex-col items-center">
                <div className="w-full flex items-center justify-between mb-2">
                  <span className="text-[11px] font-medium text-neutral-400 flex items-center gap-1">
                    <Sun size={12} /> Light Mode
                  </span>
                  <span className="text-[10px] text-emerald-400 font-mono">Pirsch Theme</span>
                </div>
                <HomeWidget4x2
                  userName={userName}
                  dailyAllowance={dailyAllowance}
                  weeklyIncome={weeklyIncome}
                  totalSpent={totalSpent}
                  isDark={false}
                />
              </div>
            )}

            {/* Homescreen Phone Mockup View */}
            {tabMode === 'homescreen' && (
              <div className="relative z-10 w-[320px] sm:w-[350px] h-[600px] rounded-[40px] border-[6px] border-neutral-800 bg-[#0d1117] p-4 shadow-2xl flex flex-col justify-between overflow-hidden">
                {/* Phone Status Bar */}
                <div className="flex justify-between items-center text-[10px] font-medium text-neutral-300 px-2 pt-1">
                  <span>09:41</span>
                  <div className="flex items-center gap-1.5">
                    <span className="text-[9px]">5G</span>
                    <div className="w-4 h-2 border border-neutral-300 rounded-[2px] p-[1px]">
                      <div className="w-2.5 h-full bg-neutral-300 rounded-[1px]" />
                    </div>
                  </div>
                </div>

                {/* Clock & Date Header */}
                <div className="text-center mt-6">
                  <div className="text-4xl font-light tracking-tight text-white/90">09:41</div>
                  <div className="text-xs text-white/60 mt-1">Minggu, 13 September</div>
                </div>

                {/* 4x2 Widget Placed on Homescreen */}
                <div className="my-auto">
                  <HomeWidget4x2
                    userName={userName}
                    dailyAllowance={dailyAllowance}
                    weeklyIncome={weeklyIncome}
                    totalSpent={totalSpent}
                    isDark={true}
                    className="shadow-2xl"
                  />
                </div>

                {/* Fake App Dock */}
                <div className="bg-white/10 backdrop-blur-md rounded-2xl p-2.5 flex justify-around items-center mb-2">
                  <div className="w-10 h-10 rounded-xl bg-emerald-500 flex items-center justify-center text-white text-xs font-bold">
                    WA
                  </div>
                  <div className="w-10 h-10 rounded-xl bg-blue-500 flex items-center justify-center text-white text-xs font-bold">
                    JT
                  </div>
                  <div className="w-10 h-10 rounded-xl bg-orange-500 flex items-center justify-center text-white text-xs font-bold">
                    SP
                  </div>
                  <div className="w-10 h-10 rounded-xl bg-indigo-600 flex items-center justify-center text-white text-xs font-bold">
                    YT
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Design Specs Callout */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            <div className="p-3 rounded-xl bg-white/[0.02] border border-white/5">
              <div className="text-[10px] text-neutral-400 uppercase font-mono">Dimensions</div>
              <div className="text-xs font-bold text-white mt-1">360px × 180px</div>
              <div className="text-[10px] text-neutral-500">Android 4x2 Ratio</div>
            </div>
            <div className="p-3 rounded-xl bg-white/[0.02] border border-white/5">
              <div className="text-[10px] text-neutral-400 uppercase font-mono">Border Radius</div>
              <div className="text-xs font-bold text-white mt-1">24px (rounded-3xl)</div>
              <div className="text-[10px] text-neutral-500">Smooth Squircle</div>
            </div>
            <div className="p-3 rounded-xl bg-white/[0.02] border border-white/5">
              <div className="text-[10px] text-neutral-400 uppercase font-mono">Padding</div>
              <div className="text-xs font-bold text-white mt-1">px: 22px / py: 20px</div>
              <div className="text-[10px] text-neutral-500">Balanced Margins</div>
            </div>
            <div className="p-3 rounded-xl bg-white/[0.02] border border-white/5">
              <div className="text-[10px] text-neutral-400 uppercase font-mono">Typography</div>
              <div className="text-xs font-bold text-white mt-1">Inter (800 / 700 / 500)</div>
              <div className="text-[10px] text-neutral-500">Letter-spacing tuned</div>
            </div>
          </div>
        </div>

        {/* Right Controls & Code Column */}
        <div className="lg:col-span-5 flex flex-col gap-6">
          {/* Controls Panel */}
          <div className="rounded-2xl border border-white/10 bg-[#121215] p-5">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Sliders size={15} className="text-[#8F9FE6]" />
                <h2 className="text-sm font-bold text-white">Live Data Editor</h2>
              </div>
              <button
                onClick={() => {
                  setUserName('Raditya Rayhan')
                  applyPreset('normal')
                }}
                className="text-xs text-neutral-400 hover:text-white flex items-center gap-1 transition-colors"
              >
                <RefreshCw size={11} /> Reset
              </button>
            </div>

            <div className="space-y-3.5">
              {/* Name */}
              <div>
                <label className="text-xs text-neutral-300 font-medium block mb-1">
                  Nama User
                </label>
                <input
                  type="text"
                  value={userName}
                  onChange={(e) => setUserName(e.target.value)}
                  className="w-full bg-white/5 border border-white/10 rounded-lg px-3 py-1.5 text-xs text-white focus:outline-none focus:border-[#6578C8]"
                />
              </div>

              {/* Daily Allowance */}
              <div>
                <div className="flex justify-between items-center mb-1">
                  <label className="text-xs text-neutral-300 font-medium">
                    Batas Jajan (/hari)
                  </label>
                  <span className="text-xs font-mono text-[#8F9FE6]">
                    Rp {dailyAllowance.toLocaleString('id-ID')}
                  </span>
                </div>
                <input
                  type="range"
                  min={10000}
                  max={300000}
                  step={5000}
                  value={dailyAllowance}
                  onChange={(e) => setDailyAllowance(Number(e.target.value))}
                  className="w-full accent-[#6578C8] cursor-pointer"
                />
              </div>

              {/* Weekly Income */}
              <div>
                <div className="flex justify-between items-center mb-1">
                  <label className="text-xs text-neutral-300 font-medium flex items-center gap-1">
                    <span className="w-2 h-2 rounded-full bg-[#4ADE80]" /> Pemasukan Mingguan (↓)
                  </label>
                  <span className="text-xs font-mono text-[#4ADE80]">
                    Rp {weeklyIncome.toLocaleString('id-ID')}
                  </span>
                </div>
                <input
                  type="range"
                  min={0}
                  max={5000000}
                  step={50000}
                  value={weeklyIncome}
                  onChange={(e) => setWeeklyIncome(Number(e.target.value))}
                  className="w-full accent-[#4ADE80] cursor-pointer"
                />
              </div>

              {/* Total Spent */}
              <div>
                <div className="flex justify-between items-center mb-1">
                  <label className="text-xs text-neutral-300 font-medium flex items-center gap-1">
                    <span className="w-2 h-2 rounded-full bg-[#F87171]" /> Pengeluaran Total (↑)
                  </label>
                  <span className="text-xs font-mono text-[#F87171]">
                    Rp {totalSpent.toLocaleString('id-ID')}
                  </span>
                </div>
                <input
                  type="range"
                  min={0}
                  max={5000000}
                  step={10000}
                  value={totalSpent}
                  onChange={(e) => setTotalSpent(Number(e.target.value))}
                  className="w-full accent-[#F87171] cursor-pointer"
                />
              </div>
            </div>
          </div>

          {/* Code Export & Copy Panel */}
          <div className="rounded-2xl border border-white/10 bg-[#121215] p-5 flex flex-col flex-1">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <Code2 size={15} className="text-[#8F9FE6]" />
                <h2 className="text-sm font-bold text-white">Copy Code UI</h2>
              </div>
              <button
                onClick={() => handleCopy(currentCode)}
                className="inline-flex items-center gap-1.5 text-xs font-semibold bg-white hover:bg-neutral-200 text-black px-3 py-1.5 rounded-lg transition-all active:scale-95 shadow-sm"
              >
                {copied ? <Check size={14} className="text-emerald-600" /> : <Copy size={14} />}
                {copied ? 'Tersalin!' : 'Copy Code'}
              </button>
            </div>

            {/* Code Language Tabs */}
            <div className="flex items-center gap-1 bg-white/[0.04] p-1 rounded-lg border border-white/5 mb-3">
              <button
                onClick={() => setCodeTab('react')}
                className={`flex-1 text-xs font-medium py-1.5 rounded-md transition-colors ${
                  codeTab === 'react'
                    ? 'bg-white/15 text-white font-semibold'
                    : 'text-neutral-400 hover:text-white'
                }`}
              >
                React (.tsx)
              </button>
              <button
                onClick={() => setCodeTab('tailwind')}
                className={`flex-1 text-xs font-medium py-1.5 rounded-md transition-colors ${
                  codeTab === 'tailwind'
                    ? 'bg-white/15 text-white font-semibold'
                    : 'text-neutral-400 hover:text-white'
                }`}
              >
                Tailwind HTML
              </button>
              <button
                onClick={() => setCodeTab('flutter')}
                className={`flex-1 text-xs font-medium py-1.5 rounded-md transition-colors ${
                  codeTab === 'flutter'
                    ? 'bg-white/15 text-white font-semibold'
                    : 'text-neutral-400 hover:text-white'
                }`}
              >
                Flutter (.dart)
              </button>
            </div>

            {/* Code Viewer */}
            <div className="relative flex-1 min-h-[260px] max-h-[420px] overflow-auto rounded-xl bg-[#09090B] border border-white/5 p-4 text-[11px] font-mono text-neutral-300 leading-relaxed">
              <pre className="whitespace-pre">
                <code>{currentCode}</code>
              </pre>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}
