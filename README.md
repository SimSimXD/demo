# Invoice Management System

A clean and simple Flutter-based Invoice Management System with full-featured invoice lifecycle management, including creation, approval workflow, and payment tracking.

## Features

### 🧾 Invoice Management
- **Create & Edit Invoices**: Full-featured invoice creation with customer details, line items, tax calculations, and discounts
- **Invoice Status Tracking**: Draft → Pending → Approved → Sent → Paid workflow
- **Customer Management**: Store and reuse customer information
- **Automatic Invoice Numbering**: Generate sequential invoice numbers with date-based formatting

### 📊 Dashboard & Analytics
- **Real-time Statistics**: Track total invoices, pending approvals, paid invoices, and overdue amounts
- **Financial Overview**: Monitor total outstanding amounts and payment status
- **Visual Status Indicators**: Color-coded status badges for quick identification

### 🔍 Search & Filtering
- **Smart Search**: Search invoices by number, customer name, or details
- **Advanced Filtering**: Filter by invoice status, payment status, and date ranges
- **Tab-based Navigation**: Quick access to different invoice categories (All, Pending, Unpaid, Paid, Overdue)

### ✅ Approval Workflow
- **Multi-stage Approval**: Submit invoices for approval with approval tracking
- **Approval History**: Track who approved invoices and when
- **Rejection Handling**: Reject invoices with reasons and feedback

### 💰 Payment Management
- **Payment Recording**: Record payments with multiple payment methods
- **Partial Payments**: Support for partial payment tracking
- **Payment History**: Complete payment audit trail
- **Balance Tracking**: Automatic calculation of remaining balances

### 💾 Data Management
- **Local Storage**: Persistent data storage using SharedPreferences
- **Data Export/Import**: JSON-based data backup and restore
- **Sample Data**: Pre-loaded sample invoices for testing

## Technology Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences
- **Date Formatting**: intl package

## Project Structure

```
lib/
├── models/
│   └── invoice_model.dart          # Data models (Invoice, Customer, InvoiceItem)
├── providers/
│   └── invoice_provider.dart       # State management and business logic
├── screens/
│   ├── invoice_detail_screen.dart  # Detailed invoice view
│   ├── invoice_form_screen.dart    # Create/edit invoice form
│   └── payment_form_screen.dart    # Payment recording form
├── main.dart                       # App entry point
└── invoice.dart                    # Main invoice list screen
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart 3.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd invoice-management-system
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Dependencies

The following packages are required and included in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  intl: ^0.19.0              # Date formatting and currency
  shared_preferences: ^2.2.2  # Local storage
  provider: ^6.1.1           # State management
```

## Usage Guide

### Creating an Invoice

1. **Navigate to Invoice Screen**: Tap on the "Invoices" tab in the bottom navigation
2. **Create New Invoice**: Tap the "+" button in the app bar
3. **Fill Invoice Details**:
   - Set issue and due dates
   - Enter customer information (or select existing customer)
   - Add invoice items with descriptions, quantities, and prices
   - Apply discounts and taxes as needed
   - Add notes if necessary
4. **Save Invoice**: Tap "Save" to create the invoice in draft status

### Managing Invoice Workflow

1. **Submit for Approval**: From invoice details, select "Submit for Approval"
2. **Approve/Reject**: Authorized users can approve or reject pending invoices
3. **Send to Customer**: Once approved, invoices can be sent to customers
4. **Track Status**: Monitor invoice progress through the status indicators

### Recording Payments

1. **Open Invoice Details**: Tap on any unpaid invoice
2. **Record Payment**: Select "Record Payment" from the menu
3. **Enter Payment Details**:
   - Payment amount (can be partial)
   - Payment method (Bank Transfer, Credit Card, etc.)
   - Payment reference/transaction ID
4. **Confirm Payment**: The system automatically updates payment status



### Dashboard Analytics

The main invoice screen provides:
- **Total Invoices**: Count of all invoices in the system
- **Pending Approval**: Invoices waiting for approval
- **Paid Invoices**: Successfully paid invoices
- **Overdue Invoices**: Invoices past their due date
- **Outstanding Amount**: Total unpaid invoice value

## Data Models

### Invoice Model
- Comprehensive invoice information including status, dates, amounts
- Customer relationship and line items
- Payment tracking and approval workflow data

### Customer Model
- Complete customer contact information
- Reusable across multiple invoices

### InvoiceItem Model
- Individual line items with quantities, prices, and tax rates
- Automatic total calculations

## Customization

### Styling
Modify colors and themes in `lib/main.dart` and individual screen files.

### Business Logic
Extend functionality in `lib/providers/invoice_provider.dart` for custom business rules.

## Features in Detail

### Invoice Status Workflow
1. **Draft**: Initial creation state, editable
2. **Pending**: Submitted for approval, awaiting review
3. **Approved**: Approved by authorized user, ready to send
4. **Sent**: Delivered to customer, awaiting payment
5. **Paid**: Payment received and recorded
6. **Overdue**: Past due date without full payment
7. **Cancelled**: Cancelled invoice

### Payment Status Tracking
1. **Unpaid**: No payments received
2. **Partially Paid**: Some payment received, balance remaining
3. **Paid**: Full payment received
4. **Refunded**: Payment refunded to customer

### Search and Filtering
- **Text Search**: Invoice numbers, customer names
- **Status Filters**: Filter by invoice or payment status
- **Date Ranges**: Filter by issue date, due date, or payment date
- **Quick Tabs**: Predefined filter combinations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions, please create an issue in the repository or contact the development team.

---

## Screenshots

### Dashboard View
- Statistics cards showing invoice counts and amounts
- Search functionality and filter tabs
- Invoice list with status indicators

### Invoice Details
- Comprehensive invoice information display
- Status tracking and approval workflow
- Payment history and balance information

### Create/Edit Invoice
- User-friendly form with validation
- Customer selection and management
- Dynamic item addition with calculations
- Tax and discount handling

### Payment Recording
- Payment amount and method selection
- Real-time balance calculations
- Payment confirmation and tracking

This Invoice Management System provides a clean and efficient solution for businesses to manage their invoicing workflow from creation to payment, with comprehensive tracking capabilities and an intuitive user interface.
