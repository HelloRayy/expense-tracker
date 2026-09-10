import { useState } from 'react'
import { motion } from 'framer-motion'
import { Smartphone, ArrowDown, ArrowUp, Zap, Shield, Check, Download } from 'lucide-react'

export default function App() {
  const [weeklyIncome, setWeeklyIncome] = useState<number>(1500000)
  const [totalSpent, setTotalSpent] = useState<number>(205000)
  const [activeCard, setActiveCard] = useState<string>('personal')
  const savings = Math.round(weeklyIncome * 0.3)
  const spendable = Math.max(0, weeklyIncome - savings)
  // Assuming 5 days left in week (Wednesday to Sunday)
  const dailyAllowance = Math.max(0, Math.round(spendable / 5))

  const formatIDR = (num: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    }).format(num)
  }

  return (
    <div className="min-h-screen bg-[#0A0A0A] text-[#EBEBEB] selection:bg-[#6ECE9D]/30 selection:text-[#6ECE9D]">
      {/* Navigation */}
      <nav className="border-b border-white/[0.08] backdrop-blur-md sticky top-0 z-50 bg-transparent">
        <div className="max-w-6xl mx-auto px-6 h-[72px] flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-[#141414] border border-white/10 flex items-center justify-center font-bold text-[#6ECE9D]">
              J
            </div>
            <span className="font-bold tracking-tight text-lg">Jajan Tracker</span>
            <span className="text-[11px] font-semibold uppercase px-2 py-0.5 rounded-full bg-[#6ECE9D]/15 text-[#6ECE9D] border border-[#6ECE9D]/30">
              v1.0
            </span>
          </div>

          <div className="flex items-center gap-4">
            <a
              href="https://github.com/HelloRayy/expense-tracker"
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-2 text-sm text-[#A3A3A3] hover:text-white transition-colors py-2 px-3 rounded-lg hover:bg-white/5"
            >
              <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                <path fillRule="evenodd" clipRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" />
              </svg>
              <span className="hidden sm:inline">GitHub</span>
            </a>
            <a
              href="https://github.com/HelloRayy/expense-tracker/releases"
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-2 text-sm font-semibold bg-[#EBEBEB] text-[#0A0A0A] hover:bg-white px-4 py-2 rounded-full transition-all hover:scale-105 active:scale-95"
            >
              <Download size={15} />
              <span>Download APK</span>
            </a>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="max-w-6xl mx-auto px-6 pt-20 pb-28">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          {/* Left Column: Copywriting */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="lg:col-span-7 space-y-6 text-left"
          >
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs text-[#A3A3A3]">
              <span className="w-2 h-2 rounded-full bg-[#6ECE9D] animate-pulse"></span>
              Batas Jajan Real-time di Home Screen Android
            </div>

            <h1 className="text-4xl sm:text-6xl font-extrabold tracking-tight leading-[1.1]">
              Kendalikan jajan, <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#6ECE9D] via-[#A8F0C6] to-[#EBEBEB]">
                tanpa rasa tersiksa.
              </span>
            </h1>

            <p className="text-[#A3A3A3] text-lg sm:text-xl font-normal leading-relaxed max-w-xl">
              Aplikasi financial budgeting minimalis dengan konsep <b>Adaptive Daily Allowance</b>. Cukup lihat widget 4x2 di layar HP, kamu langsung tahu sisa jatah jajan hari ini.
            </p>

            <div className="pt-2 flex flex-wrap gap-4">
              <a
                href="#simulator"
                className="px-6 py-3.5 rounded-full bg-[#6ECE9D] text-[#0A0A0A] font-bold text-sm tracking-wide shadow-lg shadow-[#6ECE9D]/20 hover:bg-[#7ED8AB] transition-all hover:scale-105 active:scale-95 flex items-center gap-2"
              >
                <Zap size={16} />
                Coba Simulasi Widget
              </a>
              <a
                href="https://github.com/HelloRayy/expense-tracker/releases"
                target="_blank"
                rel="noreferrer"
                className="px-6 py-3.5 rounded-full bg-[#141414] border border-white/10 text-white font-semibold text-sm hover:bg-[#1A1A1A] transition-all flex items-center gap-2"
              >
                <Download size={16} />
                Download Langsung (APK)
              </a>
            </div>

            {/* Micro value props */}
            <div className="pt-6 grid grid-cols-3 gap-4 border-t border-white/[0.06] text-xs text-[#A3A3A3]">
              <div className="flex items-center gap-2">
                <Check size={14} className="text-[#6ECE9D]" />
                <span>100% Offline SQLite</span>
              </div>
              <div className="flex items-center gap-2">
                <Check size={14} className="text-[#6ECE9D]" />
                <span>Tanpa Login / Akun</span>
              </div>
              <div className="flex items-center gap-2">
                <Check size={14} className="text-[#6ECE9D]" />
                <span>Widget 4x2 Interaktif</span>
              </div>
            </div>
          </motion.div>

          {/* Right Column: Live Interactive Widget Mockup */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="lg:col-span-5 flex justify-center"
            id="simulator"
          >
            <div className="w-full max-w-[390px] space-y-4">
              <div className="text-xs uppercase font-bold tracking-widest text-[#A3A3A3] text-center mb-1">
                Preview Real-time Widget 4x2
              </div>

              {/* 4x2 Widget Card */}
              <div className="p-6 rounded-[28px] bg-[#0A0A0A] border border-white/[0.12] shadow-2xl shadow-black/80 space-y-5 relative overflow-hidden group">
                <div className="absolute inset-0 bg-gradient-to-br from-white/[0.03] to-transparent pointer-events-none" />

                {/* Header Row */}
                <div>
                  <div className="text-base font-bold text-[#EBEBEB] tracking-tight">
                    Hi, Raditya Rayhan
                  </div>
                  <div className="text-xs text-[#A3A3A3] mt-0.5">
                    Batas jajan hari ini
                  </div>
                </div>

                {/* Hero Nominal */}
                <div className="flex items-baseline gap-2 py-1">
                  <span className="text-4xl font-extrabold text-[#EBEBEB] tracking-tight font-mono">
                    {formatIDR(dailyAllowance)}
                  </span>
                  <span className="text-sm text-[#A3A3A3] font-medium">/hari</span>
                </div>

                {/* Bottom Metrics */}
                <div className="flex items-center gap-6 pt-1 border-t border-white/[0.06]">
                  <div className="flex items-center gap-1.5 text-[#6ECE9D]">
                    <ArrowDown size={17} strokeWidth={2.5} />
                    <span className="text-sm font-bold font-mono">{formatIDR(weeklyIncome)}</span>
                  </div>

                  <div className="flex items-center gap-1.5 text-[#E87B7B]">
                    <ArrowUp size={17} strokeWidth={2.5} />
                    <span className="text-sm font-bold font-mono">{formatIDR(totalSpent)}</span>
                  </div>
                </div>
              </div>

              {/* Interactive Controls */}
              <div className="p-4 rounded-2xl bg-[#141414] border border-white/[0.08] space-y-3">
                <div className="text-xs font-semibold text-[#A3A3A3] flex items-center justify-between">
                  <span>Uang Mingguan</span>
                  <span className="text-white font-mono">{formatIDR(weeklyIncome)}</span>
                </div>
                <input
                  type="range"
                  min={300000}
                  max={5000000}
                  step={50000}
                  value={weeklyIncome}
                  onChange={(e) => setWeeklyIncome(Number(e.target.value))}
                  className="w-full accent-[#6ECE9D] bg-white/10 h-1.5 rounded-lg appearance-none cursor-pointer"
                />

                <div className="text-xs font-semibold text-[#A3A3A3] flex items-center justify-between pt-1">
                  <span>Total Pengeluaran</span>
                  <span className="text-white font-mono">{formatIDR(totalSpent)}</span>
                </div>
                <input
                  type="range"
                  min={0}
                  max={weeklyIncome}
                  step={25000}
                  value={totalSpent}
                  onChange={(e) => setTotalSpent(Number(e.target.value))}
                  className="w-full accent-[#E87B7B] bg-white/10 h-1.5 rounded-lg appearance-none cursor-pointer"
                />
              </div>
            </div>
          </motion.div>
        </div>

        {/* Feature Grid */}
        <section className="mt-32 pt-16 border-t border-white/[0.08] grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="p-6 rounded-2xl bg-[#141414] border border-white/[0.08] space-y-3">
            <div className="w-10 h-10 rounded-xl bg-[#6ECE9D]/10 text-[#6ECE9D] flex items-center justify-center font-bold">
              <Smartphone size={20} />
            </div>
            <h3 className="font-bold text-lg text-white">Home Screen Widget</h3>
            <p className="text-sm text-[#A3A3A3] leading-relaxed">
              Widget 4x2 dengan desain Pirsch minimalis. Pantau batas jajan hari ini tanpa perlu repot buka aplikasi.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-[#141414] border border-white/[0.08] space-y-3">
            <div className="w-10 h-10 rounded-xl bg-[#6ECE9D]/10 text-[#6ECE9D] flex items-center justify-center font-bold">
              <Zap size={20} />
            </div>
            <h3 className="font-bold text-lg text-white">Quick-Log 1-Detik</h3>
            <p className="text-sm text-[#A3A3A3] leading-relaxed">
              Catat jajan instan lewat floating calculator dan quick settings tile Android tanpa mengganggu aplikasi lain.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-[#141414] border border-white/[0.08] space-y-3">
            <div className="w-10 h-10 rounded-xl bg-[#6ECE9D]/10 text-[#6ECE9D] flex items-center justify-center font-bold">
              <Shield size={20} />
            </div>
            <h3 className="font-bold text-lg text-white">100% Privacy-First</h3>
            <p className="text-sm text-[#A3A3A3] leading-relaxed">
              Semua data transaksi tersimpan aman di SQLite internal HP kamu. Tidak ada backend server, tidak ada tracking.
            </p>
          </div>
        </section>

        {/* Raycast Get Your Time Back Section */}
        <section className="mt-32 pt-16 border-t border-white/[0.08] relative overflow-hidden">
          <div className="grid grid-cols-1 lg:grid-cols-[440px_1fr] gap-[85px] text-[#ffffff] text-base leading-normal items-center">
            {/* Left Column */}
            <div className="flex flex-col items-start justify-center gap-12 p-6 leading-normal max-w-[430px]">
              <div className="h-fit leading-normal">
                <h2 className="text-[28px] font-semibold text-white tracking-[0.2px] leading-[36px]">Bukan hanya hemat uang.</h2>
                <p className="text-[#6a6b6c] text-[28px] font-medium tracking-[0.2px] leading-[36px]">Tapi merasa tidak pernah menyia-nyiakannya.</p>
              </div>
              <div className="flex items-center gap-[10px]">
                <a
                  href="https://github.com/HelloRayy/expense-tracker/releases/download/v1.0.0/app-release.apk"
                  className="flex items-center justify-center gap-2 py-2 px-4 bg-[#e6e6e6] text-[#2f3031] text-sm font-medium rounded-lg shadow-[rgba(0,_0,_0,_0.5)_0px_0px_0px_2px,_rgba(255,_255,_255,_0.19)_0px_0px_14px_0px,_rgba(0,_0,_0,_0.2)_0px_-1px_0.4px_0px_inset,_rgb(255,_255,_255)_0px_1px_0.4px_0px_inset] h-[38px] leading-normal transition-all duration-150 hover:bg-[#d6d6d6] active:scale-[0.98]"
                >
                  <Download size={15} />
                  <span className="leading-normal">Download</span>
                </a>
                <a
                  href="https://github.com/HelloRayy/expense-tracker"
                  target="_blank"
                  rel="noreferrer"
                  className="flex items-center justify-center gap-2 py-2 px-4 bg-[#ffffff0a] border border-[#ffffff2e] text-white text-sm font-medium rounded-lg h-[38px] leading-normal transition-all duration-150 hover:bg-white/10 active:scale-[0.98]"
                >
                  <svg className="w-[15px] h-[15px] fill-current" viewBox="0 0 24 24">
                    <path fillRule="evenodd" clipRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" />
                  </svg>
                  <span className="leading-normal">GitHub</span>
                </a>
              </div>
            </div>

            {/* Right Column: Keyboard canvas preview */}
            <div className="relative overflow-hidden [mask-image:radial-gradient(95%_70%_at_17.02%_47.84%,rgb(217,217,217)_16.79%,rgba(217,217,217,0)_83.76%)]">
              <div className="flex flex-col gap-3 leading-tight transition-all">
                <div className="flex gap-3 h-[110px] leading-tight transition-all overflow-hidden font-mono text-sm opacity-20">
                  {['esc', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12'].map((key) => (
                    <div key={key} className="w-[110px] h-[110px] rounded-[11px] bg-[#121212] border border-white/10 p-3 flex items-start justify-start text-xs font-semibold">
                      {key}
                    </div>
                  ))}
                </div>
                <div className="flex gap-3 h-[110px] leading-tight transition-all overflow-hidden font-mono text-sm opacity-20">
                  {['± §', '! 1', '@ 2', '# 3', '$ 4', '% 5', '^ 6', '& 7', '* 8', '( 9', ') 0', '_ -', '+ =', 'delete'].map((key) => (
                    <div key={key} className="w-[110px] h-[110px] rounded-[11px] bg-[#121212] border border-white/10 p-3 flex items-start justify-start text-xs font-semibold">
                      {key}
                    </div>
                  ))}
                </div>
                <div className="flex gap-3 h-[110px] leading-tight transition-all overflow-hidden text-sm">
                  {/* Fast Card */}
                  <div
                    onClick={() => setActiveCard('fast')}
                    className={`cursor-pointer grid py-[14.5px] px-[15px] text-[#ffffff] text-2xl font-medium rounded-[11px] h-[110px] w-[178px] leading-tight transition-all ${
                      activeCard === 'fast'
                        ? 'opacity-100 bg-[#222222] shadow-[rgba(0,_0,_0,_0.4)_0px_1.5px_0.5px_2.5px,_rgb(0,_0,_0)_0px_0px_0.5px_1px,_rgba(0,_0,_0,_0.25)_0px_2px_1px_1px_inset,_rgba(255,_255,_255,_0.2)_0px_1px_1px_1px_inset,_rgba(0,_0,_0,_0)_0px_0px_0px_0px_inset]'
                        : 'opacity-70 bg-[#141414] hover:opacity-95'
                    }`}
                  >
                    <div className="flex items-start h-[40.5px] w-full leading-tight transition-all">
                      <Zap size={20} className="text-white" />
                    </div>
                    <span className="text-[#9c9c9d] text-base leading-tight transition-all">
                      <strong className="text-[#ffffff] font-bold leading-tight transition-all">Fast.</strong> Think in milliseconds.
                    </span>
                  </div>

                  {/* Ergonomic Card */}
                  <div
                    onClick={() => setActiveCard('ergo')}
                    className={`cursor-pointer grid py-[14.5px] px-[15px] text-[#ffffff] text-2xl font-medium rounded-[11px] h-[110px] w-[208px] leading-tight transition-all ${
                      activeCard === 'ergo'
                        ? 'opacity-100 bg-[#222222] shadow-[rgba(0,_0,_0,_0.4)_0px_1.5px_0.5px_2.5px,_rgb(0,_0,_0)_0px_0px_0.5px_1px,_rgba(0,_0,_0,_0.25)_0px_2px_1px_1px_inset,_rgba(255,_255,_255,_0.2)_0px_1px_1px_1px_inset,_rgba(0,_0,_0,_0)_0px_0px_0px_0px_inset]'
                        : 'opacity-70 bg-[#141414] hover:opacity-95'
                    }`}
                  >
                    <div className="flex items-start h-[40.5px] w-full leading-tight transition-all">
                      <Smartphone size={20} className="text-white" />
                    </div>
                    <span className="text-[#9c9c9d] text-base leading-tight transition-all">
                      <strong className="text-[#ffffff] font-bold leading-tight transition-all">Ergonomic.</strong> Keyboard First.
                    </span>
                  </div>

                  {['E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{ [', '} ]', '| \\'].map((key) => (
                    <div key={key} className="w-[110px] h-[110px] rounded-[11px] bg-[#121212] border border-white/10 p-3 flex items-center justify-center text-lg font-semibold opacity-20">
                      {key}
                    </div>
                  ))}
                </div>

                <div className="flex gap-3 h-[110px] leading-tight transition-all overflow-hidden text-sm">
                  {/* Personal Card */}
                  <div
                    onClick={() => setActiveCard('personal')}
                    className={`cursor-pointer grid py-[14.5px] px-[15px] text-[#ffffff] text-2xl font-medium rounded-[11px] h-[110px] w-[208px] leading-tight transition-all ${
                      activeCard === 'personal'
                        ? 'opacity-100 bg-[#222222] shadow-[rgba(0,_0,_0,_0.4)_0px_1.5px_0.5px_2.5px,_rgb(0,_0,_0)_0px_0px_0.5px_1px,_rgba(0,_0,_0,_0.25)_0px_2px_1px_1px_inset,_rgba(255,_255,_255,_0.2)_0px_1px_1px_1px_inset,_rgba(0,_0,_0,_0)_0px_0px_0px_0px_inset]'
                        : 'opacity-70 bg-[#141414] hover:opacity-95'
                    }`}
                  >
                    <div className="flex items-start h-[40.5px] w-full leading-tight transition-all">
                      <Shield size={20} className="text-white" />
                    </div>
                    <span className="text-[#9c9c9d] text-base leading-tight transition-all">
                      <strong className="text-[#ffffff] font-bold leading-tight transition-all">Personal.</strong> Your tools, your way.
                    </span>
                  </div>

                  {/* Reliable Card */}
                  <div
                    onClick={() => setActiveCard('reliable')}
                    className={`cursor-pointer grid py-[14.5px] px-[15px] text-[#ffffff] text-2xl font-medium rounded-[11px] h-[110px] w-[178px] leading-tight transition-all ${
                      activeCard === 'reliable'
                        ? 'opacity-100 bg-[#222222] shadow-[rgba(0,_0,_0,_0.4)_0px_1.5px_0.5px_2.5px,_rgb(0,_0,_0)_0px_0px_0.5px_1px,_rgba(0,_0,_0,_0.25)_0px_2px_1px_1px_inset,_rgba(255,_255,_255,_0.2)_0px_1px_1px_1px_inset,_rgba(0,_0,_0,_0)_0px_0px_0px_0px_inset]'
                        : 'opacity-70 bg-[#141414] hover:opacity-95'
                    }`}
                  >
                    <div className="flex items-start h-[40.5px] w-full leading-tight transition-all">
                      <Check size={20} className="text-white" />
                    </div>
                    <span className="text-[#9c9c9d] text-base leading-tight transition-all">
                      <strong className="text-[#ffffff] font-bold leading-tight transition-all">Reliable.</strong> 99.8% crash-free rate.
                    </span>
                  </div>

                  {['S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ': ;', '" \''].map((key) => (
                    <div key={key} className="w-[110px] h-[110px] rounded-[11px] bg-[#121212] border border-white/10 p-3 flex items-center justify-center text-lg font-semibold opacity-20">
                      {key}
                    </div>
                  ))}
                </div>
                <div className="flex gap-3 h-[110px] leading-tight transition-all overflow-hidden font-mono text-sm opacity-20">
                  {['~ `', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '< ,', '> .', '? /'].map((key) => (
                    <div key={key} className="w-[110px] h-[110px] rounded-[11px] bg-[#121212] border border-white/10 p-3 flex items-center justify-center text-lg font-semibold">
                      {key}
                    </div>
                  ))}
                </div>
                <div className="flex gap-3 h-[110px] leading-tight transition-all overflow-hidden font-mono text-xs opacity-20">
                  {['fn', 'control', 'option', 'command', 'space', 'command', 'option'].map((key) => (
                    <div key={key} className="h-[110px] px-6 rounded-[11px] bg-[#121212] border border-white/10 flex items-center justify-center font-medium">
                      {key}
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>
    </div>
  )
}
