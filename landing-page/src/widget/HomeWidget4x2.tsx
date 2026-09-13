import { ArrowDown, ArrowUp } from 'lucide-react'
import { type HomeWidget4x2Props, WIDGET_TOKENS, formatRupiah } from './tokens'

/**
 * 100% faithful React + Tailwind replica of Flutter's HomeWidget4x2Card.
 * Mirroring typography, layout, sizing (360x180), padding, and Pirsch color tokens.
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
      className={`relative w-full max-w-[360px] h-[180px] rounded-[24px] border-[1.2px] border-transparent px-[22px] py-[20px] flex flex-col justify-between select-none transition-all duration-200 ${
        onTap ? 'cursor-pointer active:scale-[0.98]' : ''
      } ${className}`}
    >
      {/* Top Header: Greeting & Context Subtitle */}
      <div className="flex flex-col">
        <span
          style={{
            color: tokens.textPrimary,
            fontSize: '16px',
            fontWeight: 600,
            letterSpacing: '-0.2px',
            lineHeight: 1.25,
          }}
        >
          Hi, {userName}
        </span>
        <span
          style={{
            color: tokens.textSecondary,
            fontSize: '13px',
            fontWeight: 400,
            marginTop: '2px',
            lineHeight: 1.25,
          }}
        >
          Batas jajan hari ini
        </span>
      </div>

      {/* Center Hero: Daily Allowance + /hari */}
      <div className="flex items-baseline gap-2">
        <span
          style={{
            color: tokens.textPrimary,
            fontSize: '36px',
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
      <div className="flex items-center gap-5">
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
  )
}
export type { HomeWidget4x2Props }
