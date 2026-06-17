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

    // Check SVG has the correct viewBox (2300 width for no right-side cutoff)
    const viewBox = await svg.getAttribute('viewBox');
    expect(viewBox).toBe('0 0 2300 800');
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
    expect(viewBox).toBe('0 0 2300 800');
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
    const closedModal = page.locator('#chartModal');
    const hasActiveClass = await closedModal.evaluate(el => el.classList.contains('active'));
    expect(hasActiveClass).toBe(false);
  });

  test('should close modal when clicking outside (backdrop)', async ({ page }) => {
    // Open modal
    const magnifyBtn = page.locator('.magnify-btn');
    await magnifyBtn.click();

    // Click on the modal overlay (outside content)
    const overlay = page.locator('#chartModal');
    await overlay.click({ position: { x: 10, y: 10 } });

    // Verify modal closed (no .active class)
    const closedModal = page.locator('#chartModal');
    const hasActiveClass = await closedModal.evaluate(el => el.classList.contains('active'));
    expect(hasActiveClass).toBe(false);
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

    // Verify modal is closed (no .active class)
    const closedModal = page.locator('#chartModal');
    const hasActiveClass = await closedModal.evaluate(el => el.classList.contains('active'));
    expect(hasActiveClass).toBe(false);
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

  test('should not have right-side cutoff in SVG', async ({ page }) => {
    const chartContainer = page.locator('#chart-container');
    const svg = chartContainer.locator('svg').first();

    // Get viewBox dimensions
    const viewBox = await svg.getAttribute('viewBox');
    const [, , viewBoxWidth, viewBoxHeight] = viewBox.split(' ').map(Number);

    // Get all rectangles and check they're within viewBox
    const rects = svg.locator('rect');
    const rectCount = await rects.count();

    for (let i = 0; i < rectCount; i++) {
      const rect = rects.nth(i);
      const x = parseFloat(await rect.getAttribute('x'));
      const width = parseFloat(await rect.getAttribute('width'));
      const rightEdge = x + width;

      // All elements should fit within viewBox width with 10px padding
      expect(rightEdge).toBeLessThanOrEqual(viewBoxWidth);
    }
  });

  test('should not have bottom cutoff in SVG', async ({ page }) => {
    const chartContainer = page.locator('#chart-container');
    const svg = chartContainer.locator('svg').first();

    // Get viewBox dimensions
    const viewBox = await svg.getAttribute('viewBox');
    const [, , viewBoxWidth, viewBoxHeight] = viewBox.split(' ').map(Number);

    // Get all rectangles and check they're within viewBox
    const rects = svg.locator('rect');
    const rectCount = await rects.count();

    for (let i = 0; i < rectCount; i++) {
      const rect = rects.nth(i);
      const y = parseFloat(await rect.getAttribute('y'));
      const height = parseFloat(await rect.getAttribute('height'));
      const bottomEdge = y + height;

      // All elements should fit within viewBox height
      expect(bottomEdge).toBeLessThanOrEqual(viewBoxHeight);
    }
  });

  test('should have resource groups properly aligned under subscriptions', async ({ page }) => {
    const chartContainer = page.locator('#chart-container');
    const svg = chartContainer.locator('svg').first();

    // Get all text elements to find subscriptions and RGs
    const texts = svg.locator('text');
    const textCount = await texts.count();

    const subscriptions = {};
    const resourceGroups = {};
    const allTextContent = [];

    // Collect subscription and RG positions
    for (let i = 0; i < textCount; i++) {
      const text = texts.nth(i);
      const content = await text.textContent();
      const xPos = parseFloat(await text.getAttribute('x'));

      // Store all text for debugging
      if (content && content.trim()) {
        allTextContent.push({ text: content.trim(), x: xPos });
      }

      if (content === 'IT_Core' || content === 'IT_IaaS' ||
          content === 'Business_Prod' || content === 'Loc_US' || content === 'Loc_EU') {
        subscriptions[content] = xPos;
      }

      if (content && content.startsWith('RG-')) {
        if (!resourceGroups[content]) {
          resourceGroups[content] = xPos;
        }
      }
    }

    // Verify RGs are aligned with their subscriptions
    // RG-Core and RG-Mgmt should be centered under IT_Core
    const itCoreX = subscriptions['IT_Core'];
    expect(Math.abs(resourceGroups['RG-Core'] - itCoreX)).toBeLessThan(100);
    expect(Math.abs(resourceGroups['RG-Mgmt'] - itCoreX)).toBeLessThan(100);

    // RG-IaaS and RG-Dev should be centered under IT_IaaS
    const itIaaSX = subscriptions['IT_IaaS'];
    expect(Math.abs(resourceGroups['RG-IaaS'] - itIaaSX)).toBeLessThan(100);
    expect(Math.abs(resourceGroups['RG-Dev'] - itIaaSX)).toBeLessThan(100);

    // RG-Prod should be under Business_Prod
    const businessProdX = subscriptions['Business_Prod'];
    expect(Math.abs(resourceGroups['RG-Prod'] - businessProdX)).toBeLessThan(100);

    // RG-US and RG-US-2 should be under Loc_US
    const locUSX = subscriptions['Loc_US'];
    expect(Math.abs(resourceGroups['RG-US'] - locUSX)).toBeLessThan(100);
    expect(Math.abs(resourceGroups['RG-US-2'] - locUSX)).toBeLessThan(100);

    // RG-EU and RG-EU2 should be under Loc_EU
    const locEUX = subscriptions['Loc_EU'];
    expect(Math.abs(resourceGroups['RG-EU'] - locEUX)).toBeLessThan(100);
    expect(Math.abs(resourceGroups['RG-EU2'] - locEUX)).toBeLessThan(100);
  });

  test('should display all RG text labels completely without cutoff', async ({ page }) => {
    const chartContainer = page.locator('#chart-container');
    const svg = chartContainer.locator('svg').first();

    // Get all text elements in RG nodes
    const texts = svg.locator('.rg-text');
    const textCount = await texts.count();

    // Verify all RGs are present and visible
    const expectedRGs = ['RG-Core', 'RG-Mgmt', 'RG-IaaS', 'RG-Dev', 'RG-Prod', 'RG-US', 'RG-US-2', 'RG-EU', 'RG-EU2'];
    const foundRGs = [];

    for (let i = 0; i < textCount; i++) {
      const text = texts.nth(i);
      const content = await text.textContent();
      if (content) {
        foundRGs.push(content.trim());
      }
    }

    // All expected RGs should be found
    for (const expectedRG of expectedRGs) {
      expect(foundRGs).toContain(expectedRG);
    }
  });

  test('should capture visual screenshot for alignment analysis', async ({ page }) => {
    // Scroll to chart section
    const chartContainer = page.locator('#chart-container');
    await chartContainer.scrollIntoViewIfNeeded();
    await page.waitForTimeout(500);

    // Take screenshot of just the chart area
    const boundingBox = await chartContainer.boundingBox();
    if (boundingBox) {
      await page.screenshot({
        path: 'rg-alignment-screenshot.png',
        clip: {
          x: boundingBox.x - 20,
          y: boundingBox.y - 20,
          width: boundingBox.width + 40,
          height: boundingBox.height + 40
        }
      });
    }
  });

  test('should diagnose RG alignment - detailed visual analysis', async ({ page }) => {
    const svg = page.locator('#chart-container svg').first();
    const texts = svg.locator('text');
    const textCount = await texts.count();

    const subscriptions = {};
    const resourceGroups = {};
    const rgNodes = {};

    // Collect all text positions (text centers)
    for (let i = 0; i < textCount; i++) {
      const text = texts.nth(i);
      const content = await text.textContent();
      const x = parseFloat(await text.getAttribute('x'));
      const y = parseFloat(await text.getAttribute('y'));

      if (content === 'IT_Core' || content === 'IT_IaaS' ||
          content === 'Business_Prod' || content === 'Loc_US' || content === 'Loc_EU') {
        subscriptions[content] = { x, y };
      }

      if (content && content.startsWith('RG-')) {
        resourceGroups[content] = { x, y };
      }
    }

    // Get RG node rectangles for centering analysis
    const rects = svg.locator('.rg-node');
    const rectCount = await rects.count();

    for (let i = 0; i < rectCount; i++) {
      const rect = rects.nth(i);
      const x = parseFloat(await rect.getAttribute('x'));
      const width = parseFloat(await rect.getAttribute('width'));
      const centerX = x + width / 2;

      if (i === 0) rgNodes['RG-Core'] = { x, width, centerX };
      if (i === 1) rgNodes['RG-Mgmt'] = { x, width, centerX };
      if (i === 2) rgNodes['RG-IaaS'] = { x, width, centerX };
      if (i === 3) rgNodes['RG-Dev'] = { x, width, centerX };
      if (i === 4) rgNodes['RG-Prod'] = { x, width, centerX };
      if (i === 5) rgNodes['RG-US'] = { x, width, centerX };
      if (i === 6) rgNodes['RG-US-2'] = { x, width, centerX };
      if (i === 7) rgNodes['RG-EU'] = { x, width, centerX };
      if (i === 8) rgNodes['RG-EU2'] = { x, width, centerX };
    }

    console.log('\n=== DETAILED VISUAL ALIGNMENT ANALYSIS ===\n');

    // Analyze each group
    const groups = [
      { name: 'IT_Core', rgList: ['RG-Core', 'RG-Mgmt'] },
      { name: 'IT_IaaS', rgList: ['RG-IaaS', 'RG-Dev'] },
      { name: 'Business_Prod', rgList: ['RG-Prod'] },
      { name: 'Loc_US', rgList: ['RG-US', 'RG-US-2'] },
      { name: 'Loc_EU', rgList: ['RG-EU', 'RG-EU2'] }
    ];

    for (const group of groups) {
      const subText = subscriptions[group.name];
      console.log(`\n${group.name} subscription text center: x=${subText.x}`);

      let minX = Infinity, maxX = -Infinity;
      for (const rgName of group.rgList) {
        const rgNode = rgNodes[rgName];
        const diff = rgNode.centerX - subText.x;
        console.log(`  ${rgName}: box center=${rgNode.centerX}, diff=${diff.toFixed(1)}px ${diff < 0 ? 'LEFT' : 'RIGHT'}`);
        minX = Math.min(minX, rgNode.x);
        maxX = Math.max(maxX, rgNode.x + rgNode.width);
      }

      const rgGroupCenter = (minX + maxX) / 2;
      const rgGroupCenterDiff = rgGroupCenter - subText.x;
      console.log(`  RG group span: ${minX} to ${maxX}, center=${rgGroupCenter.toFixed(1)}, diff from sub text=${rgGroupCenterDiff.toFixed(1)}px`);

      if (group.rgList.length === 2) {
        const rg1 = rgNodes[group.rgList[0]];
        const rg2 = rgNodes[group.rgList[1]];
        const spacing = rg2.x - (rg1.x + rg1.width);
        console.log(`  Spacing between RG boxes: ${spacing}px`);
      }
    }
  });
});
