Build a clean, modern **Flutter mobile application** called **KapdaKhata** for clothing-shop owners to manage products, sales, expenses, stock, and monthly profit/loss.

The app should be designed primarily for Android mobile devices but should use responsive Flutter layouts so it can later support iOS and tablets.

## 1. Product Goal

KapdaKhata is a simple clothing-business management app.

The core idea:

**Add products → record sales → automatically calculate profit → record expenses → see monthly profit/loss.**

The application must be extremely easy for a shop owner to use, with minimal typing and very clear financial information.

Do not make it look like a complicated accounting application.

The UI should feel like a modern SaaS/mobile finance app with a strong purple brand identity.

---

# 2. Brand

## App Name

**KapdaKhata**

## Tagline

**Manage • Sell • Grow**

## Brand Meaning

"Kapda" = clothing
"Khata" = business record/account

The application should communicate:

* Clothing management
* Sales tracking
* Profit tracking
* Expense tracking
* Simple business records

---

# 3. Design System

Use the following design system consistently throughout the entire application.

## Primary Colors

Primary Purple:

`#7132F5`

Dark Purple:

`#5741D8`

Deep Purple:

`#5B1ECF`

Soft Purple:

`rgba(133,91,251,0.16)`

Primary Text:

`#101114`

Neutral Text:

`#686B82`

Muted Text:

`#9497A9`

White:

`#FFFFFF`

Border:

`#DEDEE5`

Positive Green:

`#149E61`

Dark Green:

`#026B3F`

## Typography

Use a clean modern sans-serif.

Preferred:

`IBM Plex Sans`

Fallback:

`Helvetica Neue`, `Arial`

Use heavier typography for headings and lighter typography for secondary information.

Approximate hierarchy:

Large heading:
32–36px, bold

Page heading:
24–28px, bold

Section title:
18–20px, semibold

Body:
15–16px

Caption:
12–14px

## UI Style

Use:

* White backgrounds
* Very subtle purple accents
* 12px button radius
* 10–12px card radius
* Very light borders
* Extremely subtle shadows
* Spacious layouts
* Clean icons
* Large touch targets
* Minimal visual clutter

Do not use:

* Excessive gradients
* Glassmorphism everywhere
* Huge shadows
* Pill-shaped buttons
* Complicated dashboards
* Excessive animations

---

# 4. Main Navigation

Use a bottom navigation bar with five sections:

1. Home
2. Products
3. Sales
4. Expenses
5. More

Navigation should remain consistent across the primary screens.

---

# 5. Page Structure

The app should contain the following pages.

## A. Splash Screen

Purpose:

Introduce KapdaKhata.

Display:

KapdaKhata logo

App name

Optional tagline:

**Manage • Sell • Grow**

Then automatically navigate to Home or onboarding/login depending on implementation.

Keep it very simple.

---

# 6. Home / Dashboard

The Home page is the main overview screen.

## Header

Show:

Good Morning / Good Afternoon / Good Evening

Shop owner name

Notification icon

Current month selector

Example:

September 2026

The month selector should allow the user to select another month.

## Financial Summary Cards

Display:

### Total Sales

Total selling amount during selected month.

### Total Product Cost

Total cost of products sold during selected month.

### Gross Profit

`Total Sales - Total Product Cost`

### Total Expenses

All business expenses during selected month.

### Net Profit

`Gross Profit - Total Expenses`

This should be the most important financial number.

Example:

Sales: ₹48,500

Product Cost: ₹28,950

Gross Profit: ₹19,550

Expenses: ₹8,200

Net Profit: ₹11,350

## Products Sold

Display total quantity sold during selected month.

## Quick Actions

Provide large simple actions:

* Add Product
* Add Sale
* Add Expense
* View Reports

## Recent Sales

Show the latest 5–10 sales.

Each row should display:

Product name

Quantity

Selling amount

Profit

Date/time

## Monthly Profit Indicator

Show whether profit increased or decreased compared with the previous month.

Example:

`↑ 18% from last month`

or

`↓ 7% from last month`

---

# 7. Products Page

The Products page manages the shop's product inventory.

## Header

Title:

Products

Search icon/input

Filter button

Add Product button

## Search

Search by:

* Product name
* Product type
* Size
* SKU if implemented

Search should be instant.

## Filters

Filter by:

* All
* T-Shirt
* Shirt
* Jeans
* Trousers
* Hoodie
* Jacket
* Other

Categories should be configurable through Settings.

## Product Card / List Item

Each product row should display:

Optional product image

Product name

Type/category

Size

Cost price

Selling price

Profit per unit

Stock quantity

Example:

Oversized T-Shirt

T-Shirt • M

Cost: ₹300

Sell: ₹799

Profit: ₹499

Stock: 12

## Product Actions

Each product should support:

* Edit
* Delete
* View details
* Add stock
* Record sale

Deletion should require confirmation.

---

# 8. Add Product Page

Create a dedicated product creation page.

Fields:

## Product Photo

Optional.

Allow:

* Camera
* Gallery
* Remove photo

Photo is NOT mandatory.

## Product Name

Required.

Example:

Round Neck T-Shirt

## Type

Required.

Dropdown/select category.

Example:

T-Shirt

## Size

Optional.

Example:

S / M / L / XL / XXL

Allow custom values.

## Color

Optional.

Example:

Black

## Cost Price

Required.

This is the amount paid by the shop owner.

Example:

₹300

## Selling Price

Required.

This is the normal selling price.

Example:

₹799

## Automatic Profit

Automatically calculate:

`Profit = Selling Price - Cost Price`

Example:

₹799 - ₹300 = ₹499

Show it immediately in a highlighted green financial card.

Do not allow users to manually enter this profit.

## Stock Quantity

Optional but strongly recommended.

Example:

20

## SKU / Product Code

Optional.

Could be added for future inventory management.

## Notes

Optional.

## Save Product

Primary purple button.

Validation:

* Product name required
* Type required
* Cost price required
* Selling price required
* Prices cannot be negative
* Selling price can be lower than cost price, but show a warning because it would generate a loss

Example warning:

`Selling below cost. Expected loss: ₹100`

---

# 9. Product Details Page

When a product is opened, show:

Product photo

Product name

Category

Size

Color

Cost price

Selling price

Profit per unit

Available stock

Total quantity sold

Total revenue from this product

Total profit generated by this product

Date added

Notes

Actions:

Edit Product

Add Stock

Record Sale

Delete Product

## Product Profit Calculation

For a product:

`Unit Profit = Selling Price - Cost Price`

For sold quantity:

`Gross Product Profit = Unit Profit × Quantity Sold`

---

# 10. Sales Page

The Sales page shows all sales.

## Header

Sales

Date/month selector

Search

Filter

Add Sale

## Filters

* Today
* This Week
* This Month
* Custom Date Range

## Sale List

Each sale should show:

Product

Quantity

Selling amount

Cost amount

Profit

Date

Time

Example:

T-Shirt

Qty: 2

Sale: ₹1,598

Cost: ₹600

Profit: ₹998

## Sale Details

Opening a sale should show:

Sale ID

Product

Quantity

Unit cost

Unit selling price

Total cost

Total selling amount

Profit

Date

Time

Notes

---

# 11. Add Sale Page

This is one of the most important pages.

## Product Selection

Search/select an existing product.

Once selected automatically show:

Cost price

Selling price

Current stock

Profit per unit

## Quantity

Stepper:

* button
* current quantity
* * button

Minimum:

1

Quantity cannot exceed available stock unless stock tracking has been disabled.

## Automatic Calculations

For quantity:

`Total Cost = Cost Price × Quantity`

`Total Selling Amount = Selling Price × Quantity`

`Profit = Total Selling Amount - Total Cost`

Example:

Cost = ₹300

Selling = ₹799

Quantity = 2

Total Cost = ₹600

Total Sale = ₹1,598

Profit = ₹998

## Sale Date

Default to today.

Allow changing the date.

## Notes

Optional.

Example:

Walk-in customer

## Save Sale

After saving:

* Decrease stock
* Create sale record
* Update monthly calculations
* Update dashboard
* Update reports

Show success confirmation.

---

# 12. Important Pricing Rule

The application must preserve exact money calculations.

Use a proper money representation.

Prefer storing currency values as integer paise rather than floating-point values.

Example:

₹799.50 should be stored as:

79950 paise

This avoids floating-point calculation errors.

Display values using Indian currency formatting:

`₹799`

`₹1,598`

`₹48,500`

Use Indian number formatting where appropriate:

₹1,00,000

---

# 13. Expenses Page

Expenses should be completely separate from product costs.

Product cost = money spent to purchase inventory.

Expense = business operating expense.

Examples:

* Shop Rent
* Electricity
* Internet
* Staff Salary
* Transport
* Packaging
* Marketing
* Maintenance
* Miscellaneous

## Expenses Header

Expenses

Selected month

Add Expense button

## Expense Categories

Examples:

Shop

Utilities

Salary

Transport

Packaging

Marketing

Maintenance

Other

Categories should be editable from Settings.

## Expense List

Each item:

Expense name

Category

Date

Amount

Notes

Example:

Shop Rent

Shop

12 Sep 2026

₹3,000

## Add Expense

Fields:

Expense Title

Category

Amount

Date

Notes

Save Expense

Amount must be required and greater than zero.

---

# 14. Monthly Profit & Loss System

This is a core feature.

Create a proper monthly P&L calculation.

## Monthly Revenue

Sum of all sales in the selected month.

`Total Sales = Σ sale.totalSellingAmount`

## Cost of Goods Sold

Sum of product costs for all items sold.

`COGS = Σ sale.totalCost`

## Gross Profit

`Gross Profit = Total Sales - COGS`

## Operating Expenses

Sum all expenses.

`Expenses = Σ expense.amount`

## Net Profit

`Net Profit = Gross Profit - Expenses`

Example:

Total Sales:

₹50,000

Cost of Goods Sold:

₹30,000

Gross Profit:

₹20,000

Expenses:

₹8,000

Net Profit:

₹12,000

## Important

Do not calculate profit using current product prices after a sale has already happened.

When creating a sale, save the actual:

* Unit cost at sale time
* Unit selling price at sale time

This protects historical reports when the product price is edited later.

---

# 15. Reports Page

Create a dedicated Reports page.

Top selector:

Month

## Overview

Show:

Total Sales

Total Cost

Gross Profit

Expenses

Net Profit

Products Sold

## Profit & Loss

Display:

Revenue

COGS

Gross Profit

Expenses

Net Profit

## Charts

Use simple clean charts.

### Monthly Sales Chart

Show sales by month.

### Profit Chart

Show monthly net profit.

### Expense Breakdown

Show expense categories.

### Best Selling Products

Show top products by quantity sold.

### Highest Profit Products

Show products generating the most profit.

Charts should remain simple and readable.

Do not overload the screen.

---

# 16. Reports Date Range

Support:

Current Month

Previous Month

Last 3 Months

Last 6 Months

Current Year

Custom Range

When the date range changes, all financial numbers and charts must update.

---

# 17. More Page

The More section contains:

### Shop Settings

Shop name

Owner name

Currency

Default categories

Business details

### Manage Categories

Create/edit/delete:

Product categories

Expense categories

### Backup & Restore

Backup local database.

Restore previous backup.

### Export Data

Export:

Products

Sales

Expenses

Reports

Prefer CSV/Excel-compatible export.

PDF report can be considered later.

### Notifications

Manage optional reminders.

### App Settings

Theme

Notifications

Currency formatting

Language

### Help & Support

Basic help information.

### About

KapdaKhata

Version number

---

# 18. Settings Page

Create a separate Settings page rather than hiding all settings in a popup.

Sections:

## Shop Profile

Shop name

Owner name

Phone number

Address

Currency

## Product Settings

Manage categories

Manage sizes

Manage colors

## Expense Settings

Manage expense categories

## App Preferences

Theme:

System / Light / Dark

Notifications

Language

## Data

Backup

Restore

Export

Clear local data

Dangerous actions must require confirmation.

---

# 19. Database

Use a local-first architecture.

Recommended:

**Drift (SQLite)**

or another robust local database solution.

The app should work without internet for normal shop operations.

## Main Tables

### products

Fields:

* id
* name
* typeId
* size
* color
* photoPath
* costPricePaise
* sellingPricePaise
* stockQuantity
* sku
* notes
* createdAt
* updatedAt
* isDeleted

### sales

Fields:

* id
* productId
* quantity
* unitCostPaise
* unitSellingPricePaise
* totalCostPaise
* totalSellingAmountPaise
* profitPaise
* saleDate
* notes
* createdAt

### expenses

Fields:

* id
* title
* categoryId
* amountPaise
* expenseDate
* notes
* createdAt

### product_categories

Fields:

* id
* name
* createdAt

### expense_categories

Fields:

* id
* name
* createdAt

### shop_settings

Fields:

* shopName
* ownerName
* phone
* address
* currency
* etc.

---

# 20. Architecture

Use a scalable Flutter architecture.

Recommended structure:

`features/`

Inside:

`home/`

`products/`

`sales/`

`expenses/`

`reports/`

`settings/`

`core/`

`database/`

`shared/`

Use a clear separation between:

UI

State Management

Repositories

Database

Models

Services

Do not put all business logic directly inside widgets.

---

# 21. State Management

Use one consistent state-management approach.

Recommended:

**Riverpod**

Use providers for:

* Product list
* Product search
* Sales
* Expenses
* Dashboard metrics
* Monthly reports
* Settings

UI should react automatically when database data changes.

---

# 22. Image Handling

Product photos are optional.

Use:

* Image picker
* Camera
* Gallery

Store only the local file path/identifier in the database.

Do not store huge binary images directly inside the database unless there is a strong reason.

Compress large images before saving.

Provide:

Add Photo

Change Photo

Remove Photo

---

# 23. Empty States

Every list screen needs a useful empty state.

Example Products:

`No products yet`

`Add your first product to start tracking your shop.`

Button:

`+ Add Product`

Sales:

`No sales recorded yet`

Expenses:

`No expenses recorded yet`

Reports:

`Not enough data yet`

---

# 24. Validation & Error Handling

All forms must have proper validation.

Examples:

Required field errors

Invalid number

Negative amount

Duplicate category

Insufficient stock

Invalid dates

Failed image selection

Database failure

Every destructive operation must require confirmation.

Example:

`Delete this product?`

`This cannot be undone.`

---

# 25. Stock Rules

When a sale is saved:

`stock = stock - quantity`

When stock is manually added:

`stock = current stock + added stock`

Do not allow stock to become negative.

Show low-stock warning when stock is at or below a configurable threshold.

Default low-stock threshold:

5

---

# 26. Dashboard Financial Rules

Dashboard metrics must be generated from database records rather than manually maintained totals.

For selected month:

Total Sales:

sum of sale totals

Total Cost:

sum of sale costs

Gross Profit:

sales - cost

Expenses:

sum of expenses

Net Profit:

gross profit - expenses

Products Sold:

sum of sale quantities

---

# 27. Monthly Comparison

Compare selected month against previous month.

Examples:

Sales:

`+12%`

Profit:

`+18%`

Expenses:

`-5%`

Do not display a percentage when the previous month has zero value unless a clear alternative is provided.

Example:

`No previous data`

---

# 28. Search & Filtering

Products:

Search name/category/SKU.

Sales:

Search product name.

Expenses:

Search title/category.

Use debounced search for performance.

---

# 29. UX Principles

The app is intended for shop owners who may not be technical.

Therefore:

* Keep forms short
* Prefer dropdowns
* Use sensible defaults
* Minimize typing
* Use large buttons
* Show calculations immediately
* Avoid accounting jargon where possible
* Always explain important financial numbers
* Make primary actions obvious

For example, instead of displaying only:

`Gross Margin`

show:

`Gross Profit`

with the calculation understandable from the surrounding UI.

---

# 30. Home Page UX Priority

The user should understand these five numbers within a few seconds:

**Sales**

**Cost**

**Gross Profit**

**Expenses**

**Net Profit**

Net Profit should have the strongest visual hierarchy.

---

# 31. Product Profit Display

Every product should make this obvious:

Cost:

₹300

Selling:

₹799

Profit:

₹499

This automatic profit calculation is one of the core reasons to use KapdaKhata.

---

# 32. Offline-first

Normal operations must work without internet:

* Add product
* Edit product
* Delete product
* Record sale
* Record expense
* View reports
* Search
* View dashboard

Cloud synchronization can be added later.

Do not make internet connectivity a requirement for the MVP.

---

# 33. Backup

For MVP, create local backup/export capability.

Recommended:

Export database/data into a backup file.

Allow importing/restoring it later.

Future versions can support:

Google Drive

Cloud backup

Automatic synchronization

---

# 34. Security

For the MVP:

* Keep local data private
* Do not expose database files unnecessarily
* Confirm destructive actions
* Consider optional PIN/biometric lock in a future version

---

# 35. Performance

The application must remain fast with at least:

10,000 products

50,000 sales

10,000 expenses

Use database queries rather than loading everything into memory.

Paginate long lists.

---

# 36. Animations

Use subtle animations only:

* Page transitions
* Button feedback
* Success state
* Card number updates
* Bottom navigation transitions

Avoid excessive animations.

---

# 37. Icons

Use a consistent icon set, preferably Material Symbols / Icons.

Suggested:

Home

Inventory

Shopping bag

Receipt

Trending Up

Wallet

Chart

Settings

Add

Edit

Delete

Search

Filter

Calendar

Camera

Image

---

# 38. Important Edge Cases

Handle all of the following:

1. Product selling price lower than cost price.

2. Product is deleted after historical sales exist.

Historical sales must remain intact.

3. Product price changes after sales already exist.

Past sales must not change.

4. Product stock reaches zero.

Show:

`Out of stock`

5. Product has no photo.

Use a consistent placeholder.

6. No expenses exist.

Show zero rather than breaking reports.

7. No sales exist.

Show zero and a useful empty state.

8. Previous month has zero revenue.

Avoid divide-by-zero percentage calculations.

9. Sale quantity exceeds stock.

Prevent the sale and explain why.

---

# 39. Product Deletion Rule

Prefer soft deletion.

Never physically remove a product if historical sales depend on it.

Instead mark the product as deleted/inactive.

Historical reports must continue working.

---

# 40. Editing a Product

If the user changes:

Cost:

₹300 → ₹350

Selling:

₹799 → ₹849

Only future sales use the new prices.

Existing sales keep their original stored prices.

This is extremely important for correct financial reporting.

---

# 41. MVP Scope

The first version should focus on:

### Core

Product management

Sales management

Expense management

Automatic profit calculation

Stock management

Monthly P&L

Dashboard

Reports

Settings

Backup/export

Product photos

The application should not become overloaded with unnecessary features.

---

# 42. Future Features

Keep the architecture ready for:

Customer management

Customer credit/udhaar

Supplier management

Purchase tracking

Barcode scanning

Invoice generation

WhatsApp invoice sharing

Cloud backup

Multi-device synchronization

Multi-user/shop staff accounts

GST support

Online store integration

Advanced analytics

AI business insights

These should NOT block the MVP.

---

# 43. Suggested Flutter Packages

Use stable maintained packages where appropriate.

Possible stack:

Flutter

Dart

Riverpod

Drift / SQLite

GoRouter

Image Picker

Path Provider

Intl

Fl Chart

Share Plus

File Picker

Permission Handler

Use current stable versions compatible with the selected Flutter SDK.

Do not blindly copy outdated package versions.

---

# 44. Routing

Use named routes / GoRouter.

Suggested routes:

`/`

`/home`

`/products`

`/products/add`

`/products/:id`

`/products/:id/edit`

`/sales`

`/sales/add`

`/sales/:id`
