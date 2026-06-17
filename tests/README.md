# Playwright E2E Tests

This directory contains Playwright end-to-end tests for the Learning Hub pages.

## Setup

```bash
npm install
```

## Running Tests

### Run all tests
```bash
npm test
```

### Run Lab 03 tests only
```bash
npm run test:lab03
```

### Run tests in debug mode
```bash
npm run test:debug
```

### Run tests with interactive UI mode
```bash
npm run test:ui
```

### View HTML test report
```bash
npm run test:report
```

## Test Files

### `lab03-management-groups.spec.js`
Tests for Lab 03 - Management Groups & Azure Policy

**Coverage:**
- ✅ Page loads successfully
- ✅ Organizational hierarchy section displays
- ✅ Magnifying glass button functionality
- ✅ SVG chart renders with correct dimensions
- ✅ All hierarchy levels visible (Tenant, Root MG, Departments, Subscriptions, Resource Groups, Resources)
- ✅ SVG styling and connectors
- ✅ Color-coded nodes (blue, purple, pink)
- ✅ Modal opens/closes properly
- ✅ Keyboard shortcuts (Escape key)
- ✅ Click-outside modal dismiss
- ✅ Page structure and headings
- ✅ Responsive design
- ✅ No broken elements or errors

## Writing Tests

Tests use Playwright's test syntax. Example:

```javascript
test('should display organizational chart', async ({ page }) => {
  await page.goto(labPageUrl);
  const chart = page.locator('#chart-container svg');
  await expect(chart).toBeVisible();
});
```

## CI/CD Integration

Tests can be integrated into GitHub Actions. See `.github/workflows/` for CI configuration.

## Troubleshooting

**Issue: Tests fail to find page elements**
- Ensure the HTML file path is correct in the test
- Check that element selectors match the actual HTML

**Issue: Modal tests fail**
- Verify that JavaScript is enabled (it is in Playwright by default)
- Check that event listeners are properly attached

**Issue: File path not found**
- Use absolute paths with `path.join(__dirname, ...)`
- Verify the file path matches your project structure
