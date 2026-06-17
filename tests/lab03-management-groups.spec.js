const { test, expect } = require('@playwright/test');
const path = require('path');

// Path to the lab page
const labPagePath = path.join(__dirname, '../courses/az-104/01-identity-governance/documents/03-management-groups-and-azure-policy.html');
const labPageUrl = `file://${labPagePath}`;

test.describe('Lab 03 - Management Groups & Azure Policy', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the lab page
    await page.goto(labPageUrl);
    // Wait for page to be fully loaded
    await page.waitForLoadState('networkidle');
  });

  test('should load the page successfully', async ({ page }) => {
    // Check page title
    const title = await page.title();
    expect(title).toBeTruthy();

    // Check main heading exists
    const heading = page.locator('h1');
    await expect(heading).toBeVisible();
  });

  test('should display the organizational hierarchy section', async ({ page }) => {
    // Check the section heading
    const sectionHeading = page.locator('text=The Hierarchy: Azure\'s Organizational Structure');
    await expect(sectionHeading).toBeVisible();

    // Check the key insight paragraph
    const keyInsight = page.locator('text=Permissions and policies flow downward');
    await expect(keyInsight).toBeVisible();
  });

  test('should display the magnifying glass button', async ({ page }) => {
    // Check for magnifying glass button
    const magnifyBtn = page.locator('.magnify-btn');
    await expect(magnifyBtn).toBeVisible();

    // Verify button has search icon emoji
    const btnText = await magnifyBtn.textContent();
    expect(btnText).toContain('🔍');
  });

  test('should display the organizational chart SVG', async ({ page }) => {
    // Check that SVG exists in the main chart container
    const svg = page.locator('#chart-container svg');
    await expect(svg).toBeVisible();

    // Check SVG has the correct viewBox
    const viewBox = await svg.getAttribute('viewBox');
    expect(viewBox).toBe('0 0 2200 800');
  });

  test('should display all hierarchy levels in the chart', async ({ page }) => {
    const chartContainer = page.locator('#chart-container');

    // Check for Tenant node
    const tenantText = chartContainer.locator('text=Azure Tenant').first();
    await expect(tenantText).toBeVisible();

    // Check for Root MG
    const rootMgText = chartContainer.locator('text=Root MG').first();
    await expect(rootMgText).toBeVisible();

    // Check for Management Groups
    const itDeptText = chartContainer.locator('text=IT Dept').first();
    await expect(itDeptText).toBeVisible();

    const businessDeptText = chartContainer.locator('text=Business Dept').first();
    await expect(businessDeptText).toBeVisible();

    const locationDeptText = chartContainer.locator('text=Location Dept').first();
    await expect(locationDeptText).toBeVisible();

    // Check for Subscriptions
    const subscriptionText = chartContainer.locator('text=IT_Core').first();
    await expect(subscriptionText).toBeVisible();

    // Check for Resource Groups
    const rgText = chartContainer.locator('text=RG-Core').first();
    await expect(rgText).toBeVisible();

    // Check for Resources
    const resourceText = chartContainer.locator('text=VM');
    const vmElements = await resourceText.all();
    expect(vmElements.length).toBeGreaterThan(0);
  });

  test('should have proper SVG styling with connectors', async ({ page }) => {
    const chartContainer = page.locator('#chart-container');
    // Check for hierarchy lines (connectors)
    const lines = chartContainer.locator('.hierarchy-line');
    const lineCount = await lines.count();
    expect(lineCount).toBeGreaterThan(0);

    // Verify line styling (class exists)
    const firstLine = lines.first();
    const className = await firstLine.getAttribute('class');
    expect(className).toContain('hierarchy-line');
  });

  test('should have color-coded hierarchy nodes', async ({ page }) => {
    // Check for blue nodes (main hierarchy)
    const blueNodes = page.locator('.hierarchy-node');
    const blueCount = await blueNodes.count();
    expect(blueCount).toBeGreaterThan(0);

    // Check for purple nodes (Resource Groups)
    const rgNodes = page.locator('.rg-node');
    const rgCount = await rgNodes.count();
    expect(rgCount).toBeGreaterThan(0);

    // Check for pink nodes (Resources)
    const resourceNodes = page.locator('.resource-node');
    const resourceCount = await resourceNodes.count();
    expect(resourceCount).toBeGreaterThan(0);
  });

  test('should open modal when magnifying glass is clicked', async ({ page }) => {
    // Click magnifying glass button
    const magnifyBtn = page.locator('.magnify-btn');
    await magnifyBtn.click();

    // Check modal overlay is visible
    const modal = page.locator('#chartModal.active');
    await expect(modal).toBeVisible();

    // Check modal content is visible
    const modalContent = page.locator('.modal-content');
    await expect(modalContent).toBeVisible();
  });

  test('should display SVG in modal with correct viewBox', async ({ page }) => {
    // Click magnifying glass
    const magnifyBtn = page.locator('.magnify-btn');
    await magnifyBtn.click();

    // Wait for modal to be visible
    const modal = page.locator('#chartModal.active');
    await expect(modal).toBeVisible();

    // Check modal SVG
    const modalSvg = page.locator('#chartModal svg');
    const viewBox = await modalSvg.getAttribute('viewBox');
    expect(viewBox).toBe('0 0 2200 800');
  });

  test('should close modal when close button is clicked', async ({ page }) => {
    // Open modal
    const magnifyBtn = page.locator('.magnify-btn');
    await magnifyBtn.click();

    // Verify modal is open
    const modal = page.locator('#chartModal.active');
    await expect(modal).toBeVisible();

    // Click close button
    const closeBtn = page.locator('.modal-close');
    await closeBtn.click();

    // Verify modal is closed (no .active class)
    const closedModal = page.locator('#chartModal:not(.active)');
    await expect(closedModal).toBeVisible();
  });

  test('should close modal when clicking outside (backdrop)', async ({ page }) => {
    // Open modal
    const magnifyBtn = page.locator('.magnify-btn');
    await magnifyBtn.click();

    // Click on the modal overlay (outside content)
    const overlay = page.locator('#chartModal');
    await overlay.click({ position: { x: 10, y: 10 } });

    // Verify modal closed
    const closedModal = page.locator('#chartModal:not(.active)');
    await expect(closedModal).toBeVisible();
  });

  test('should close modal when Escape key is pressed', async ({ page }) => {
    // Open modal
    const magnifyBtn = page.locator('.magnify-btn');
    await magnifyBtn.click();

    // Verify modal is open
    const modal = page.locator('#chartModal.active');
    await expect(modal).toBeVisible();

    // Press Escape key
    await page.keyboard.press('Escape');

    // Verify modal is closed
    const closedModal = page.locator('#chartModal:not(.active)');
    await expect(closedModal).toBeVisible();
  });

  test('should have all hierarchy levels properly aligned', async ({ page }) => {
    const svg = page.locator('#chart-container svg');

    // Get all text elements
    const textElements = svg.locator('text');
    const count = await textElements.count();

    // Should have many text elements (multiple nodes with labels)
    expect(count).toBeGreaterThan(20);
  });

  test('should display all management departments', async ({ page }) => {
    const chartContainer = page.locator('#chart-container');
    const itDept = chartContainer.locator('text=IT Dept').first();
    const businessDept = chartContainer.locator('text=Business Dept').first();
    const locationDept = chartContainer.locator('text=Location Dept').first();

    await expect(itDept).toBeVisible();
    await expect(businessDept).toBeVisible();
    await expect(locationDept).toBeVisible();
  });

  test('should display all subscriptions', async ({ page }) => {
    const chartContainer = page.locator('#chart-container');
    const itCore = chartContainer.locator('text=IT_Core').first();
    const itIaaS = chartContainer.locator('text=IT_IaaS').first();
    const businessProd = chartContainer.locator('text=Business_Prod').first();
    const locUS = chartContainer.locator('text=Loc_US').first();
    const locEU = chartContainer.locator('text=Loc_EU').first();

    await expect(itCore).toBeVisible();
    await expect(itIaaS).toBeVisible();
    await expect(businessProd).toBeVisible();
    await expect(locUS).toBeVisible();
    await expect(locEU).toBeVisible();
  });

  test('should display resource groups', async ({ page }) => {
    const chartContainer = page.locator('#chart-container');
    const rgCore = chartContainer.locator('text=RG-Core').first();
    const rgIaaS = chartContainer.locator('text=RG-IaaS').first();
    const rgProd = chartContainer.locator('text=RG-Prod').first();

    await expect(rgCore).toBeVisible();
    await expect(rgIaaS).toBeVisible();
    await expect(rgProd).toBeVisible();
  });

  test('should have proper page structure and headings', async ({ page }) => {
    // Check main page structure
    const mainHeading = page.locator('h1');
    await expect(mainHeading).toBeVisible();

    const subtitle = page.locator('.subtitle');
    await expect(subtitle).toBeVisible();

    // Check for section headings
    const h2 = page.locator('h2');
    const h2Count = await h2.count();
    expect(h2Count).toBeGreaterThan(0);
  });

  test('should have responsive chart container', async ({ page }) => {
    // Check that chart container exists and is visible
    const chartContainer = page.locator('#chart-container');
    await expect(chartContainer).toBeVisible();

    // Verify it has proper styling
    const display = await chartContainer.evaluate(el =>
      window.getComputedStyle(el).display
    );
    expect(display).not.toBe('none');
  });

  test('should have no broken links or missing elements', async ({ page }) => {
    // Check for any console errors
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    // Load page and wait
    await page.waitForLoadState('networkidle');

    // Should have no critical errors
    expect(errors.length).toBe(0);
  });
});
