const { test, expect } = require('@playwright/test');
const path = require('path');

test.describe('Lab Formatting Audit - Detailed Comparison', () => {
  
  const labs = {
    'Lab 04 (Reference)': 'file://c:/Users/nyeemzoarder/.claude/context/learning-hub/courses/az-104/02-storage/documents/lab04-storage-accounts.html',
    'Lab 07 (Target)': 'file://c:/Users/nyeemzoarder/.claude/context/learning-hub/courses/az-104/03-compute/documents/lab07-arm-bicep-templates.html',
    'Lab 12 (Target)': 'file://c:/Users/nyeemzoarder/.claude/context/learning-hub/courses/az-104/04-networking/documents/lab12-vnet-subnets.html'
  };

  for (const [labName, url] of Object.entries(labs)) {
    test(`${labName} - Complete Formatting Audit`, async ({ page }) => {
      await page.goto(url);

      // Count all formatting elements
      const counts = {
        'Time Estimate Header': await page.locator('.time-estimate-header').count(),
        'Real-Life Scenario': await page.locator('h2').filter({ hasText: /Real-Life Scenario/ }).count(),
        'Section Headers': await page.locator('.section-header').count(),
        'Section Times': await page.locator('.section-time').count(),
        'Task Boxes': await page.locator('.task-box').count(),
        'Step Numbers': await page.locator('.step-number').count(),
        'Code Blocks': await page.locator('.code-block, pre').count(),
        'Validation Checklists': await page.locator('.validation-checklist').count(),
        'Checklist Items': await page.locator('.checklist-item').count(),
        'Success Boxes': await page.locator('.success-box').count(),
        'Success Items': await page.locator('.success-items li').count(),
        'Callout Boxes': await page.locator('.callout-box').count(),
        'Callout Important': await page.locator('.callout-important').count(),
        'Callout Tip': await page.locator('.callout-tip').count(),
        'Callout Warning': await page.locator('.callout-warning').count(),
      };

      // Get page title and structure info
      const title = await page.locator('h1').textContent();
      const h2Count = await page.locator('h2').count();
      const h3Count = await page.locator('h3').count();

      // Build detailed report
      const report = {
        lab: labName,
        title: title,
        structure: {
          'H2 Headings': h2Count,
          'H3 Headings': h3Count
        },
        formatting: counts
      };

      // Determine completeness score
      const hasBasics = counts['Time Estimate Header'] > 0 && counts['Real-Life Scenario'] > 0 && counts['Section Headers'] > 0;
      const hasSteps = counts['Task Boxes'] > 0 && counts['Step Numbers'] > 0;
      const hasCode = counts['Code Blocks'] > 5;
      const hasValidation = counts['Validation Checklists'] > 0 && counts['Checklist Items'] > 0;
      const hasSuccess = counts['Success Boxes'] > 0 && counts['Success Items'] > 0;
      const hasCallouts = counts['Callout Boxes'] > 0;

      const completeness = {
        'Basic Structure': hasBasics ? '✅' : '❌',
        'Task Boxes & Steps': hasSteps ? '✅' : '❌',
        'Code Blocks': hasCode ? '✅' : '❌',
        'Validation Checklists': hasValidation ? '✅' : '❌',
        'Success Criteria': hasSuccess ? '✅' : '❌',
        'Visual Callouts': hasCallouts ? '✅' : '❌'
      };

      console.log(`\n${'='.repeat(70)}`);
      console.log(`📊 FORMATTING AUDIT: ${labName}`);
      console.log(`${'='.repeat(70)}`);
      console.log(`\n📄 Page Structure:`);
      console.log(`   Title: ${title}`);
      console.log(`   H2 Sections: ${h2Count}`);
      console.log(`   H3 Subsections: ${h3Count}`);
      
      console.log(`\n📋 Formatting Elements:`);
      Object.entries(counts).forEach(([element, count]) => {
        const icon = count > 0 ? '✅' : '❌';
        console.log(`   ${icon} ${element}: ${count}`);
      });

      console.log(`\n✨ Completeness Checklist:`);
      Object.entries(completeness).forEach(([element, status]) => {
        console.log(`   ${status} ${element}`);
      });

      console.log(`\n${'='.repeat(70)}\n`);
    });
  }
});
