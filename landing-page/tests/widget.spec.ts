import { test, expect } from '@playwright/test'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

test.describe('Widget Studio & Redesign Lab Route (/widget)', () => {
  test('should render /widget successfully with dark & light cards and copy controls', async ({ page }) => {
    // Navigate to /widget
    await page.goto('/widget', { waitUntil: 'networkidle' })

    // Verify title and main heading
    await expect(page).toHaveTitle(/Widget Studio/)
    await expect(page.locator('h1')).toContainText('Widget Studio & Redesign Lab')

    // Verify cards are rendered
    const darkLabel = page.locator('text=Dark Mode (Onyx #0C0C0E)')
    await expect(darkLabel).toBeVisible()

    const lightLabel = page.locator('text=Light Mode (Beige #F5F6FA)')
    await expect(lightLabel).toBeVisible()

    // Verify widget content
    await expect(page.locator('text=Hi, Raditya Rayhan').first()).toBeVisible()
    await expect(page.locator('text=Batas jajan hari ini').first()).toBeVisible()
    await expect(page.locator('text=Rp 50.000').first()).toBeVisible()
    await expect(page.locator('text=/hari').first()).toBeVisible()
    await expect(page.locator('text=Rp 1.500.000').first()).toBeVisible()
    await expect(page.locator('text=Rp 205.000').first()).toBeVisible()

    // Capture screenshot of Widget Studio (Side by Side)
    const screenshotPath = path.join(__dirname, 'widget-studio-preview.png')
    await page.screenshot({ path: screenshotPath, fullPage: true })

    // Click on Homescreen Tab
    await page.click('text=Homescreen')
    await expect(page.locator('text=09:41').first()).toBeVisible()
    const homescreenScreenshotPath = path.join(__dirname, 'widget-homescreen-preview.png')
    await page.screenshot({ path: homescreenScreenshotPath, fullPage: true })
  })
})
