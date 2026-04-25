import { test, expect, Page, ConsoleMessage } from '@playwright/test';
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
    if (e.isDirectory()) {
      out.push(...findMockups(full, rel));
    } else if (e.isFile() && e.name.endsWith('.html')) {
      out.push(rel);
    }
  }
  return out;
}

const allMockups = findMockups(MOCKUPS_DIR).sort();
const targetFile = process.env.PW_TARGET_FILE;
const mockups = targetFile
  ? allMockups.filter((m) => m === targetFile.replace(/\\/g, '/'))
  : allMockups;

const IGNORED_CONSOLE_PATTERNS = [
  /favicon\.ico/i,
  /Failed to load resource.*404.*\.png/i,
  /\[vite\]/i,
  /fonts\.gstatic\.com/i,
  /fonts\.googleapis\.com/i,
];

function isIgnored(msg: string): boolean {
  return IGNORED_CONSOLE_PATTERNS.some((re) => re.test(msg));
}

async function collectErrors(page: Page): Promise<string[]> {
  const errors: string[] = [];
  page.on('console', (msg: ConsoleMessage) => {
    if (msg.type() === 'error') {
      const text = msg.text();
      if (!isIgnored(text)) errors.push(`[console.error] ${text}`);
    }
  });
  page.on('pageerror', (err) => {
    if (!isIgnored(err.message)) errors.push(`[pageerror] ${err.message}`);
  });
  page.on('requestfailed', (req) => {
    const url = req.url();
    if (isIgnored(url)) return;
    errors.push(`[requestfailed] ${req.failure()?.errorText ?? 'unknown'} :: ${url}`);
  });
  return errors;
}

test.describe('ARK Mockups · Smoke', () => {
  for (const mockup of mockups) {
    test(`loads: ${mockup}`, async ({ page }) => {
      const errors = await collectErrors(page);
      const url = encodeURI(mockup);
      const response = await page.goto(url, { waitUntil: 'load' });
      expect(response, `no response for ${mockup}`).not.toBeNull();
      const status = response!.status();
      expect(status, `${mockup} status`).toBeLessThan(400);
      const title = await page.title();
      expect(title.length, `${mockup} has empty <title>`).toBeGreaterThan(0);
      await page.waitForTimeout(300);
      expect(errors, `console/page errors in ${mockup}:\n${errors.join('\n')}`).toHaveLength(0);
    });
  }
});
