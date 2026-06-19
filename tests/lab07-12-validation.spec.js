const { test, expect } = require('@playwright/test');
const path = require('path');

test.describe('Lab 07 & 12 Formatting Validation', () => {
  
  test('Lab 07 - Verify formatting elements', async ({ page }) => {
    const filePath = 'file://c:/Users/nyeemzoarder/.claude/context/learning-hub/courses/az-104/03-compute/documents/lab07-arm-bicep-templates.html';
    await page.goto(filePath);
    
    // Check all required elements
    const title = await page.locator('h1').textContent();
    expect(title).toContain('Lab 07');
    
    const timeHeader = await page.locator('.time-estimate-header').count();
    expect(timeHeader).toBe(1);
    
    const timeText = await page.locator('.time-estimate-header .time-text').textContent();
    expect(timeText).toContain('50');
    
    const scenario = await page.locator('h2').filter({ hasText: /Real-Life Scenario/ }).count();
    expect(scenario).toBeGreaterThan(0);
    
    const techcorp = await page.locator('text=TechCorp').count();
    expect(techcorp).toBeGreaterThan(0);
    
    const sections = await page.locator('.section-header').count();
    expect(sections).toBe(7);
    
    const sectionTimes = await page.locator('.section-time').count();
    expect(sectionTimes).toBe(7);
    
    console.log('\n✅ Lab 07 Validation Results:');
    console.log('============================');
    console.log(`✓ Title: ${title}`);
    console.log(`✓ Time Estimate: ${timeText}`);
    console.log(`✓ Real-Life Scenario: Present`);
    console.log(`✓ TechCorp Context: Present`);
    console.log(`✓ Section Headers: ${sections}/7`);
    console.log(`✓ Section Times: ${sectionTimes}/7`);
    console.log('============================\n');
  });

  test('Lab 12 - Verify formatting elements', async ({ page }) => {
    const filePath = 'file://c:/Users/nyeemzoarder/.claude/context/learning-hub/courses/az-104/04-networking/documents/lab12-vnet-subnets.html';
    await page.goto(filePath);
    
    const title = await page.locator('h1').textContent();
    expect(title).toContain('Lab 12');
    
    const timeHeader = await page.locator('.time-estimate-header').count();
    expect(timeHeader).toBe(1);
    
    const timeText = await page.locator('.time-estimate-header .time-text').textContent();
    expect(timeText).toContain('45');
    
    const scenario = await page.locator('h2').filter({ hasText: /Real-Life Scenario/ }).count();
    expect(scenario).toBeGreaterThan(0);
    
    const finserve = await page.locator('text=FinServe').count();
    expect(finserve).toBeGreaterThan(0);
    
    const sections = await page.locator('.section-header').count();
    expect(sections).toBe(5);
    
    const sectionTimes = await page.locator('.section-time').count();
    expect(sectionTimes).toBe(5);
    
    console.log('\n✅ Lab 12 Validation Results:');
    console.log('============================');
    console.log(`✓ Title: ${title}`);
    console.log(`✓ Time Estimate: ${timeText}`);
    console.log(`✓ Real-Life Scenario: Present`);
    console.log(`✓ FinServe Context: Present`);
    console.log(`✓ Section Headers: ${sections}/5`);
    console.log(`✓ Section Times: ${sectionTimes}/5`);
    console.log('============================\n');
  });
});
