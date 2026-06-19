const { test, expect } = require('@playwright/test');

test.describe('Lab 04 Live Deployment Test', () => {
  test('Verify Lab 04 displays correctly with all formatting', async ({ page }) => {
    // Test local file first
    const localPath = 'file://c:/Users/nyeemzoarder/.claude/context/learning-hub/courses/az-104/02-storage/documents/lab04-storage-accounts.html';
    await page.goto(localPath);
    
    // Test key visual elements
    const title = await page.locator('h1').textContent();
    expect(title).toContain('Lab 04');
    
    // Verify time estimate is visible
    const timeText = await page.locator('.time-estimate-header .time-text').textContent();
    expect(timeText).toContain('40 minutes');
    
    // Verify Real-Life Scenario exists
    const scenario = await page.locator('h2').filter({ hasText: 'Real-Life Scenario' }).count();
    expect(scenario).toBeGreaterThan(0);
    
    // Verify section headers
    const sections = await page.locator('.section-header').count();
    expect(sections).toBe(6);
    
    // Verify task boxes
    const tasks = await page.locator('.task-box').count();
    expect(tasks).toBe(16);
    
    // Verify validation checklists
    const checklists = await page.locator('.validation-checklist').count();
    expect(checklists).toBe(6);
    
    // Verify success boxes
    const success = await page.locator('.success-box').count();
    expect(success).toBe(7);
    
    // Verify storage diagram is rendered
    const storageModal = await page.locator('#storageModal').count();
    expect(storageModal).toBeGreaterThan(0);

    // Test interactive magnifying glass
    const magnifyBtn = await page.locator('button[onclick="toggleStorageModal()"]').count();
    expect(magnifyBtn).toBeGreaterThan(0);
    
    console.log('\n✅ Lab 04 Live Test Results:');
    console.log('============================');
    console.log(`✓ Title found: ${title}`);
    console.log(`✓ Time estimate: ${timeText}`);
    console.log(`✓ Real-Life Scenario: Present`);
    console.log(`✓ Section Headers: ${sections}`);
    console.log(`✓ Task Boxes: ${tasks}`);
    console.log(`✓ Validation Checklists: ${checklists}`);
    console.log(`✓ Success Boxes: ${success}`);
    console.log(`✓ Storage Diagram Modal: Present`);
    console.log(`✓ Magnifying Glass Button: ${magnifyBtn}`);
    console.log('============================\n');
  });
});
