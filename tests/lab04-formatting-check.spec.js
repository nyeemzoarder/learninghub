const { test, expect } = require('@playwright/test');
const path = require('path');

test('Lab 04 Formatting - Comprehensive Check', async ({ page }) => {
  const filePath = path.join(__dirname, '../courses/az-104/02-storage/documents/lab04-storage-accounts.html');
  await page.goto(`file://${filePath}`);

  const results = {
    hasTimeEstimateHeader: await page.locator('.time-estimate-header').count(),
    hasRealLifeScenario: await page.locator('text=Real-Life Scenario').count(),
    hasSectionHeaders: await page.locator('.section-header').count(),
    hasTaskBoxes: await page.locator('.task-box').count(),
    hasValidationChecklists: await page.locator('.validation-checklist').count(),
    hasCalloutBoxes: await page.locator('.callout-box').count(),
    hasSuccessBoxes: await page.locator('.success-box').count(),
  };

  console.log('\n📊 Lab 04 Formatting Analysis:');
  console.log('================================');
  console.log(`✓ Time Estimate Header: ${results.hasTimeEstimateHeader > 0 ? 'YES ✅' : 'NO ❌'} (${results.hasTimeEstimateHeader})`);
  console.log(`✓ Real-Life Scenario: ${results.hasRealLifeScenario > 0 ? 'YES ✅' : 'NO ❌'} (${results.hasRealLifeScenario})`);
  console.log(`✓ Section Headers: ${results.hasSectionHeaders > 0 ? 'YES ✅' : 'NO ❌'} (${results.hasSectionHeaders})`);
  console.log(`✓ Task Boxes: ${results.hasTaskBoxes > 0 ? 'YES ✅' : 'NO ❌'} (${results.hasTaskBoxes})`);
  console.log(`✓ Validation Checklists: ${results.hasValidationChecklists > 0 ? 'YES ✅' : 'NO ❌'} (${results.hasValidationChecklists})`);
  console.log(`✓ Callout Boxes: ${results.hasCalloutBoxes > 0 ? 'YES ✅' : 'NO ❌'} (${results.hasCalloutBoxes})`);
  console.log(`✓ Success Boxes: ${results.hasSuccessBoxes > 0 ? 'YES ✅' : 'NO ❌'} (${results.hasSuccessBoxes})`);
  console.log('================================\n');

  // Verify all required elements are present
  expect(results.hasTimeEstimateHeader).toBeGreaterThan(0);
  expect(results.hasRealLifeScenario).toBeGreaterThan(0);
  expect(results.hasSectionHeaders).toBeGreaterThan(0);
  expect(results.hasTaskBoxes).toBeGreaterThan(0);
  expect(results.hasValidationChecklists).toBeGreaterThan(0);
  expect(results.hasCalloutBoxes).toBeGreaterThan(0);
  expect(results.hasSuccessBoxes).toBeGreaterThan(0);
});
