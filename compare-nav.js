const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  console.log('='.repeat(80));
  console.log('COMPARING NAVIGATION BETWEEN CONCEPT PAGE AND LAB PAGE');
  console.log('='.repeat(80));

  // ========== CONCEPT PAGE ==========
  console.log('\n📚 CONCEPT PAGE: 01-entra-id-overview.html');
  console.log('-'.repeat(80));
  
  await page.goto('https://www.manzspace.au/01-identity-governance/documents/01-entra-id-overview.html');
  await page.waitForLoadState('networkidle');

  // Check top navigation (site-nav)
  const conceptTopNav = await page.locator('.site-nav').innerText();
  console.log('\n✓ TOP NAVIGATION (site-nav):');
  console.log(conceptTopNav);

  // Check sidebar navigation
  const conceptSidebar = await page.locator('.sidebar').innerText();
  console.log('\n✓ SIDEBAR NAVIGATION:');
  console.log(conceptSidebar);

  // Check all sidebar details sections
  const conceptDetails = await page.locator('.sidebar details').count();
  console.log(`\n✓ Number of collapsible sections: ${conceptDetails}`);

  const conceptDetailsSummaries = await page.locator('.sidebar details summary').allTextContents();
  console.log('✓ Sidebar section titles:');
  conceptDetailsSummaries.forEach((s, i) => console.log(`  ${i+1}. ${s}`));

  // ========== LAB PAGE ==========
  console.log('\n\n🧪 LAB PAGE: lab01-entra-users-groups.html');
  console.log('-'.repeat(80));
  
  await page.goto('https://www.manzspace.au/01-identity-governance/documents/lab01-entra-users-groups.html');
  await page.waitForLoadState('networkidle');

  // Check top navigation (site-nav)
  const labTopNav = await page.locator('.site-nav').innerText();
  console.log('\n✓ TOP NAVIGATION (site-nav):');
  console.log(labTopNav);

  // Check sidebar navigation
  const labSidebar = await page.locator('.sidebar').innerText();
  console.log('\n✓ SIDEBAR NAVIGATION:');
  console.log(labSidebar);

  // Check all sidebar details sections
  const labDetails = await page.locator('.sidebar details').count();
  console.log(`\n✓ Number of collapsible sections: ${labDetails}`);

  const labDetailsSummaries = await page.locator('.sidebar details summary').allTextContents();
  console.log('✓ Sidebar section titles:');
  labDetailsSummaries.forEach((s, i) => console.log(`  ${i+1}. ${s}`));

  // ========== DIFFERENCES ==========
  console.log('\n\n' + '='.repeat(80));
  console.log('🔍 DIFFERENCES FOUND');
  console.log('='.repeat(80));

  if (conceptTopNav === labTopNav) {
    console.log('\n✓ TOP NAVIGATION: SAME ✓');
  } else {
    console.log('\n✗ TOP NAVIGATION: DIFFERENT ✗');
    console.log('\nCONCEPT PAGE TOP NAV:');
    console.log(conceptTopNav);
    console.log('\nLAB PAGE TOP NAV:');
    console.log(labTopNav);
  }

  if (conceptSidebar === labSidebar) {
    console.log('\n✓ SIDEBAR NAVIGATION: SAME ✓');
  } else {
    console.log('\n✗ SIDEBAR NAVIGATION: DIFFERENT ✗');
  }

  if (conceptDetailsSummaries.length === labDetailsSummaries.length) {
    console.log(`\n✓ SIDEBAR SECTIONS: SAME (${conceptDetailsSummaries.length} sections) ✓`);
  } else {
    console.log(`\n✗ SIDEBAR SECTIONS: DIFFERENT ✗`);
    console.log(`  Concept page: ${conceptDetailsSummaries.length} sections`);
    console.log(`  Lab page: ${labDetailsSummaries.length} sections`);
  }

  console.log('\n' + '='.repeat(80));

  await browser.close();
})();
