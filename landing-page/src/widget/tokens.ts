export interface HomeWidget4x2Props {
  userName?: string
  dailyAllowance: number
  weeklyIncome: number
  totalSpent: number
  isDark?: boolean
  onTap?: () => void
  className?: string
  style?: React.CSSProperties
}

export function formatRupiah(amount: number): string {
  const rounded = Math.round(amount)
  const formatted = rounded.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.')
  return `Rp ${formatted}`
}

export const WIDGET_TOKENS = {
  dark: {
    bg: '#0C0C0E',
    border: 'transparent',
    boxShadow: '0 6px 16px rgba(0, 0, 0, 0.35)',
    textPrimary: '#EDEDED', // Calibrated soft off-white (WCAG AAA 16.7:1, anti-glare)
    textSecondary: '#A1A1AA', // Calibrated Zinc-400 (WCAG AAA 7.6:1, anti-fatigue)
    incomeGreen: '#4ADE80',
    expenseRed: '#F87171',
  },
  light: {
    bg: '#F5F6FA',
    border: 'transparent',
    boxShadow: '0 6px 16px rgba(0, 0, 0, 0.06)',
    textPrimary: '#0C0C0C',
    textSecondary: '#6B7280',
    incomeGreen: '#1D7A4A',
    expenseRed: '#DC2626',
  },
} as const
