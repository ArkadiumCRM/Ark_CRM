import { test, expect } from '@playwright/test';
import fs from 'fs';
import path from 'path';

const MOCKUPS_DIR = path.resolve(__dirname, '..', 'mockups');
const SKIP_DIRS = new Set(['_archive', '_deprecated']);

function findMockups(dir: string, prefix = ''): string[] {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const out: string[] = [];
  for (const e of entries) {
    if (SKIP_DIRS.has(e.name)) continue;
    const rel = prefix ? `${prefix}/${e.name}` : e.name;
    const full = path.join(dir, e.name);
    if (e.isDirectory()) out.push(...findMockups(full, rel));
    else if (e.isFile() && e.name.endsWith('.html')) out.push(rel);
  }
  return out;
}

// Default: curated set of mockups that previously regressed under Codex CLI.
// Override via env to baseline more: PW_VISUAL_TARGETS="all" or "file1.html,dir/file2.html"
const DEFAULT_TARGETS = [
  'crm-mobile.html',
  'Vollansichten/admin.html',
  'Vollansichten/candidates.html',
  'Vollansichten/stammdaten.html',
  'ERP Tools/performance/performance-coverage.html',
];
const targetsEnv = process.env.PW_VISUAL_TARGETS;
const VISUAL_TARGETS =
  targetsEnv === 'all'
    ? findMockups(MOCKUPS_DIR)
    : targetsEnv
    ? targetsEnv.split(',').map((s) => s.trim()).filter(Boolean)
    : DEFAULT_TARGETS;

test.describe('ARK Mockups · Visual regression', () => {
  test.use({ viewport: { width: 1440, height: 900 } });

  for (const mockup of VISUAL_TARGETS) {
    test(`screenshot: ${mockup}`, async ({ page }) => {
      const url = encodeURI(mockup);
      await page.goto(url, { waitUntil: 'networkidle' });
      await page.evaluate(() => {
        document.querySelectorAll('*').forEach((el) => {
          (el as HTMLElement).style.transition = 'none';
          (el as HTMLElement).style.animation = 'none';
        });
      });
      await page.waitForTimeout(400);
      await expect(page).toHaveScreenshot({
        fullPage: true,
        maxDiffPixelRatio: 0.01,
        animations: 'disabled',
      });
    });
  }
});
