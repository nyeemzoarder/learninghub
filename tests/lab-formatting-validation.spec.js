const { test, expect } = require('@playwright/test');
const path = require('path');

const labs = {
  'Lab 01': path.join(__dirname, '../courses/az-104/01-identity-governance/documents/lab01-entra-users-groups.html'),
  'Lab 02': path.join(__dirname, '../courses/az-104/01-identity-governance/documents/lab02-rbac-azure-policy.html'),
  'Lab 03': path.join(__dirname, '../courses/az-104/01-identity-governance/documents/lab03-management-groups-subscriptions.html'),
  'Lab 04': path.join(__dirname, '../courses/az-104/02-storage/documents/lab04-storage-accounts.html'),
};

test.describe('Lab Formatting Validation', () => {
  for (const [labName, filePath] of Object.entries(labs)) {
    test(`${labName} - Check professional formatting elements`, async ({ page }) => {
      await page.goto(`file://${filePath}`);

      const results = {
        lab: labName,
        hasTimeEstimateHeader: false,
        hasRealLifeScenario: false,
        hasSectionHeaders: 0,
        hasTaskBoxes: 0,
        hasValidationChecklists: 0,
        hasCalloutBoxes: 0,
        hasSuccessBoxes: 0,
      };

      // Check for time estimate header
      const timeEstimateHeader = await page.locator('.time-estimate-header').count();
      results.hasTimeEstimateHeader = timeEstimateHeader > 0;

      // Check for "Real-Life Scenario"
      const realLifeScenario = await page.locator('text=Real-Life Scenario').count();
      results.hasRealLifeScenario = realLifeScenario > 0;

      // Check for section headers with time
      const sectionHeaders = await page.locator('.section-header').count();
      results.hasSectionHeaders = sectionHeaders;

      // Check for task boxes
      const taskBoxes = await page.locator('.task-box').count();
      results.hasTaskBoxes = taskBoxes;

      // Check for validation checklists
      const validationChecklists = await page.locator('.validation-checklist').count();
      results.hasValidationChecklists = validationChecklists;

      // Check for callout boxes
      const calloutBoxes = await page.locator('.callout-box').count();
      results.hasCalloutBoxes = calloutBoxes;

      // Check for success boxes
      const successBoxes = await page.locator('.success-box').count();
      results.hasSuccessBoxes = successBoxes;

      console.log(`\n${labName} Formatting Results:`, JSON.stringify(results, null, 2));

      // Assertions - all labs should have these elements
      expect(results.hasTimeEstimateHeader).toBeTruthy();
      expect(results.hasRealLifeScenario).toBeTruthy();
      expect(results.hasSectionHeaders).toBeGreaterThan(0);
      expect(results.hasTaskBoxes).toBeGreaterThan(0);
      expect(results.hasValidationChecklists).toBeGreaterThan(0);
      expect(results.hasCalloutBoxes).toBeGreaterThan(0);
    });
  }
});
