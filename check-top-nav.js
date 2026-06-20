const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  console.log('='.repeat(80));
  console.log('CHECKING TOP NAVIGATION MODULES ORDER');
  console.log('='.repeat(80));

  // Check concept page
  console.log('\n📚 CONCEPT PAGE: 01-entra-id-overview.html');
  await page.goto('https://www.manzspace.au/01-identity-governance/documents/01-entra-id-overview.html');
  await page.waitForLoadState('networkidle');
  
  const conceptLinks = await page.locator('.nav-menu a').allTextContents();
  console.log('\nTop Navigation Links:');
  conceptLinks.forEach((link, i) => console.log(`  ${i+1}. ${link}`));

  // Check lab page
  console.log('\n\n🧪 LAB PAGE: lab01-entra-users-groups.html');
  await page.goto('https://www.manzspace.au/01-identity-governance/documents/lab01-entra-users-groups.html');
  await page.waitForLoadState('networkidle');
  
  const labLinks = await page.locator('.nav-menu a').allTextContents();
  console.log('\nTop Navigation Links:');
  labLinks.forEach((link, i) => console.log(`  ${i+1}. ${link}`));

  console.log('\n' + '='.repeat(80));
  
  if (JSON.stringify(conceptLinks) === JSON.stringify(labLinks)) {
    console.log('✅ TOP NAVIGATION: SAME ORDER');
  } else {
    console.log('❌ TOP NAVIGATION: DIFFERENT ORDER');
    console.log('\nExpected order (from module-home):');
    console.log('  1. 00 - Prerequisites');
    console.log('  2. 01 - Identity & Governance');
    console.log('  3. 02 - Networking');
    console.log('  4. 03 - Compute');
    console.log('  5. 04 - Storage');
    console.log('  6. 05 - Monitor & Maintain');
  }

  await browser.close();
})();
