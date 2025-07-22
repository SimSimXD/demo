import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';

class PdfService {
  static const String companyName = "Your Company Name";
  static const String companyAddress = "123 Business Street\nCity, State 12345\nPhone: (555) 123-4567\nEmail: info@company.com";

  static Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(),
            pw.SizedBox(height: 30),

            // Invoice Info
            _buildInvoiceInfo(invoice, dateFormat),
            pw.SizedBox(height: 30),

            // Customer Info
            _buildCustomerInfo(invoice.customer),
            pw.SizedBox(height: 30),

            // Items Table
            _buildItemsTable(invoice, currencyFormat),
            pw.SizedBox(height: 30),

            // Totals
            _buildTotals(invoice, currencyFormat),
            pw.SizedBox(height: 30),

            // Payment Info
            if (invoice.paymentStatus == PaymentStatus.paid ||
                invoice.paymentStatus == PaymentStatus.partiallyPaid)
              _buildPaymentInfo(invoice, currencyFormat, dateFormat),

            // Notes
            if (invoice.notes.isNotEmpty) _buildNotes(invoice.notes),

            pw.Spacer(),

            // Footer
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              companyName,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              companyAddress,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            'INVOICE',
            style: pw.TextStyle(
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Invoice invoice, DateFormat dateFormat) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Invoice Number:', style: _labelStyle()),
            pw.Text(invoice.invoiceNumber, style: _valueStyle()),
            pw.SizedBox(height: 8),
            pw.Text('Issue Date:', style: _labelStyle()),
            pw.Text(dateFormat.format(invoice.issueDate), style: _valueStyle()),
            pw.SizedBox(height: 8),
            pw.Text('Due Date:', style: _labelStyle()),
            pw.Text(dateFormat.format(invoice.dueDate), style: _valueStyle()),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Status:', style: _labelStyle()),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: _getStatusColor(invoice.status),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                _getStatusText(invoice.status),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Payment Status:', style: _labelStyle()),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: _getPaymentStatusColor(invoice.paymentStatus),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                _getPaymentStatusText(invoice.paymentStatus),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(Customer customer) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Bill To:', style: _sectionHeaderStyle()),
          pw.SizedBox(height: 8),
          pw.Text(customer.name, style: _valueStyle()),
          if (customer.email.isNotEmpty) pw.Text(customer.email, style: _smallTextStyle()),
          if (customer.phone.isNotEmpty) pw.Text(customer.phone, style: _smallTextStyle()),
          if (customer.address.isNotEmpty) pw.Text(customer.address, style: _smallTextStyle()),
          if (customer.city.isNotEmpty || customer.state.isNotEmpty || customer.zipCode.isNotEmpty)
            pw.Text('${customer.city} ${customer.state} ${customer.zipCode}', style: _smallTextStyle()),
          if (customer.country.isNotEmpty) pw.Text(customer.country, style: _smallTextStyle()),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(Invoice invoice, NumberFormat currencyFormat) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _tableHeaderCell('Description'),
            _tableHeaderCell('Qty'),
            _tableHeaderCell('Unit Price'),
            _tableHeaderCell('Amount'),
          ],
        ),
        // Items
        ...invoice.items.map((item) => pw.TableRow(
          children: [
            _tableCell(item.description),
            _tableCell(item.quantity.toString()),
            _tableCell(currencyFormat.format(item.unitPrice)),
            _tableCell(currencyFormat.format(item.subtotal)),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildTotals(Invoice invoice, NumberFormat currencyFormat) {
    return pw.Container(
      width: 250,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _totalRow('Subtotal:', currencyFormat.format(invoice.subtotal)),
          if (invoice.discountPercentage > 0) ...[
            _totalRow('Discount (${invoice.discountPercentage}%):', 
                     '-${currencyFormat.format(invoice.discountAmount)}'),
            _totalRow('Subtotal after discount:', 
                     currencyFormat.format(invoice.subtotalAfterDiscount)),
          ],
          if (invoice.taxAmount > 0)
            _totalRow('Tax:', currencyFormat.format(invoice.taxAmount)),
          pw.Divider(color: PdfColors.grey400),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total:', style: _totalLabelStyle()),
              pw.Text(currencyFormat.format(invoice.total), style: _totalValueStyle()),
            ],
          ),
          if (invoice.paidAmount > 0) ...[
            pw.SizedBox(height: 8),
            _totalRow('Paid:', currencyFormat.format(invoice.paidAmount)),
            _totalRow('Balance Due:', currencyFormat.format(invoice.remainingAmount)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildPaymentInfo(Invoice invoice, NumberFormat currencyFormat, DateFormat dateFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Payment Information', style: _sectionHeaderStyle()),
          pw.SizedBox(height: 8),
          pw.Text('Amount Paid: ${currencyFormat.format(invoice.paidAmount)}', style: _valueStyle()),
          if (invoice.paymentMethod.isNotEmpty)
            pw.Text('Payment Method: ${invoice.paymentMethod}', style: _smallTextStyle()),
          if (invoice.paymentReference.isNotEmpty)
            pw.Text('Reference: ${invoice.paymentReference}', style: _smallTextStyle()),
          if (invoice.paidDate != null)
            pw.Text('Payment Date: ${dateFormat.format(invoice.paidDate!)}', style: _smallTextStyle()),
        ],
      ),
    );
  }

  static pw.Widget _buildNotes(String notes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Notes:', style: _sectionHeaderStyle()),
          pw.SizedBox(height: 8),
          pw.Text(notes, style: _smallTextStyle()),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Center(
        child: pw.Text(
          'Thank you for your business!',
          style: pw.TextStyle(
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey600,
          ),
        ),
      ),
    );
  }

  // Helper methods for styling
  static pw.TextStyle _labelStyle() {
    return pw.TextStyle(fontSize: 10, color: PdfColors.grey600);
  }

  static pw.TextStyle _valueStyle() {
    return pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
  }

  static pw.TextStyle _smallTextStyle() {
    return const pw.TextStyle(fontSize: 10, color: PdfColors.grey700);
  }

  static pw.TextStyle _sectionHeaderStyle() {
    return pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800);
  }

  static pw.TextStyle _totalLabelStyle() {
    return pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
  }

  static pw.TextStyle _totalValueStyle() {
    return pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800);
  }

  static pw.Widget _tableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static pw.Widget _totalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: _labelStyle()),
          pw.Text(value, style: _valueStyle()),
        ],
      ),
    );
  }

  static PdfColor _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return PdfColors.grey600;
      case InvoiceStatus.pending:
        return PdfColors.orange600;
      case InvoiceStatus.approved:
        return PdfColors.blue600;
      case InvoiceStatus.sent:
        return PdfColors.purple600;
      case InvoiceStatus.paid:
        return PdfColors.green600;
      case InvoiceStatus.overdue:
        return PdfColors.red600;
      case InvoiceStatus.cancelled:
        return PdfColors.red800;
    }
  }

  static PdfColor _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return PdfColors.red600;
      case PaymentStatus.partiallyPaid:
        return PdfColors.orange600;
      case PaymentStatus.paid:
        return PdfColors.green600;
      case PaymentStatus.refunded:
        return PdfColors.purple600;
    }
  }

  static String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'DRAFT';
      case InvoiceStatus.pending:
        return 'PENDING';
      case InvoiceStatus.approved:
        return 'APPROVED';
      case InvoiceStatus.sent:
        return 'SENT';
      case InvoiceStatus.paid:
        return 'PAID';
      case InvoiceStatus.overdue:
        return 'OVERDUE';
      case InvoiceStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return 'UNPAID';
      case PaymentStatus.partiallyPaid:
        return 'PARTIALLY PAID';
      case PaymentStatus.paid:
        return 'PAID';
      case PaymentStatus.refunded:
        return 'REFUNDED';
    }
  }

  // Save PDF to device
  static Future<File?> savePdfToDevice(Uint8List pdfData, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(pdfData);
      return file;
    } catch (e) {
      print('Error saving PDF: $e');
      return null;
    }
  }

  // Print PDF
  static Future<bool> printPdf(Uint8List pdfData, String fileName) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: fileName,
      );
      return true;
    } catch (e) {
      print('Error printing PDF: $e');
      return false;
    }
  }

  // Share PDF
  static Future<bool> sharePdf(Uint8List pdfData, String fileName) async {
    try {
      await Printing.sharePdf(
        bytes: pdfData,
        filename: '$fileName.pdf',
      );
      return true;
    } catch (e) {
      print('Error sharing PDF: $e');
      return false;
    }
  }
}