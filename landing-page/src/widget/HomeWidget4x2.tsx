import { ArrowDown, ArrowUp } from 'lucide-react'
import { type HomeWidget4x2Props, WIDGET_TOKENS, formatRupiah } from './tokens'

/**
 * 100% faithful React + Tailwind replica of pen.dev's HomeWidget4x2 (E7Zt3L).
 * Mirroring typography, layout, sizing (360x180), radial coin glow, 
 * Coins-amico illustration, and Pirsch color tokens.
 */
export function HomeWidget4x2({
  userName = 'Raditya Rayhan',
  dailyAllowance,
  weeklyIncome,
  totalSpent,
  isDark = true,
  onTap,
  className = '',
  style,
}: HomeWidget4x2Props) {
  const tokens = isDark ? WIDGET_TOKENS.dark : WIDGET_TOKENS.light

  return (
    <div
      onClick={onTap}
      role={onTap ? 'button' : undefined}
      tabIndex={onTap ? 0 : undefined}
      style={{
        backgroundColor: tokens.bg,
        boxShadow: tokens.boxShadow,
        fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
        ...style,
      }}
      className={`relative w-full max-w-[360px] h-[180px] rounded-[24px] border border-solid ${
        isDark ? 'border-[#27272a]/50' : 'border-zinc-200'
      } overflow-hidden select-none transition-all duration-200 ${
        onTap ? 'cursor-pointer active:scale-[0.98]' : ''
      } ${className}`}
    >
      {/* 1. Coin Back Glow (Radial gradient matching pen.dev node I0wOSt) */}
      <div
        className="absolute -top-[26px] -right-[35px] w-[219px] h-[219px] rounded-full pointer-events-none"
        style={{
          background: isDark
            ? 'radial-gradient(circle, rgba(59, 130, 246, 0.12) 0%, rgba(0, 0, 0, 0) 70%)'
            : 'radial-gradient(circle, rgba(59, 130, 246, 0.08) 0%, rgba(0, 0, 0, 0) 70%)',
        }}
      />

      {/* 2. Coins Illustration (pen.dev node sewzm) */}
      <img
        src="/images/coins_illustration.png"
        alt="Coins illustration"
        className="absolute top-[19px] -right-[60px] w-[221px] h-[195px] object-contain pointer-events-none select-none"
        draggable={false}
      />

      {/* 3. Left Content Column */}
      <div className="relative z-10 w-full h-full px-[20px] py-[22px] flex flex-col justify-between">
        {/* Top Header: Greeting & Context Subtitle */}
        <div className="flex flex-col">
          <span
            style={{
              color: tokens.textPrimary,
              fontSize: '16px',
              fontWeight: 600,
              letterSpacing: '-0.2px',
              lineHeight: 1.2,
            }}
          >
            Hi, {userName}
          </span>
          <span
            style={{
              color: tokens.textSecondary,
              fontSize: '13px',
              fontWeight: 400,
              marginTop: '4px',
              lineHeight: 1.2,
            }}
          >
            Batas jajan hari ini
          </span>
        </div>

        {/* Lower Group (borderGreen): Hero + Metrics */}
        <div className="flex flex-col gap-2">
          {/* Center Hero: Daily Allowance + /hari */}
          <div className="flex items-baseline gap-1">
            <span
              style={{
                color: tokens.textPrimary,
                fontSize: '32px',
                fontWeight: 700,
                letterSpacing: '-0.8px',
                lineHeight: 1,
              }}
            >
              {formatRupiah(dailyAllowance)}
            </span>
            <span
              style={{
                color: tokens.textSecondary,
                fontSize: '15px',
                fontWeight: 500,
                lineHeight: 1,
              }}
            >
              /hari
            </span>
          </div>

          {/* Bottom Metrics: Weekly Income (Green) & Total Spent (Red) */}
          <div className="flex items-center gap-3">
            {/* Weekly Income */}
            <div
              className="inline-flex items-center gap-1"
              style={{ color: tokens.incomeGreen }}
            >
              <ArrowDown size={15} strokeWidth={2.4} className="shrink-0" />
              <span
                style={{
                  fontSize: '15px',
                  fontWeight: 600,
                  letterSpacing: '-0.2px',
                  lineHeight: 1,
                }}
              >
                {formatRupiah(weeklyIncome)}
              </span>
            </div>

            {/* Total Spent */}
            <div
              className="inline-flex items-center gap-1"
              style={{ color: tokens.expenseRed }}
            >
              <ArrowUp size={15} strokeWidth={2.4} className="shrink-0" />
              <span
                style={{
                  fontSize: '15px',
                  fontWeight: 600,
                  letterSpacing: '-0.2px',
                  lineHeight: 1,
                }}
              >
                {formatRupiah(totalSpent)}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
export type { HomeWidget4x2Props }
