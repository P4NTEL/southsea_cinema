import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() {
    return _BasketScreenState();
  }
}

class _BasketScreenState extends State<BasketScreen> {
  String _confirmationMessage = '';
  List<Booking> _bookings = [];
  String _bookingsError = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final List<Booking> bookings =
          await CinemaDatabase.instance.getAllBookings();
      if (!mounted) {
        return;
      }
      setState(() {
        _bookings = bookings;
        _bookingsError = '';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bookingsError = 'Could not load bookings: $error';
      });
    }
  }

  String _buildSummary(List<BasketItem> items) {
    final List<String> parts = [];
    for (final BasketItem item in items) {
      parts.add('${item.quantity} x ${item.movie.title}');
    }
    return parts.join(', ');
  }

  String _formatDate(DateTime now) {
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$day/$month/${now.year} $hour:$minute';
  }

  Future<void> _checkout(
    BasketRepository basket,
    List<BasketItem> items,
  ) async {
    final String summary = _buildSummary(items);
    final double total = basket.getTotalDue();
    final String date = _formatDate(DateTime.now());

    try {
      final CinemaDatabase database = CinemaDatabase.instance;
      final int bookingNumber = await database.getNextBookingNumber();
      final Booking booking = Booking(
        bookingNumber: bookingNumber,
        summary: summary,
        total: total,
        date: date,
      );

      await database.insertBooking(booking);
      basket.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _confirmationMessage = 'Booking $bookingNumber saved';
      });
      _loadBookings();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _confirmationMessage = 'Could not save your booking: $error';
      });
    }
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      color: cinemaSurface,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.bookingNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cinemaBrand,
                  ),
                ),
                Text(
                  '£${booking.total.toStringAsFixed(2)}',
                  style: const TextStyle(color: cinemaFontWhite),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              booking.summary,
              style: const TextStyle(color: cinemaFontWhite),
            ),
            const SizedBox(height: 4),
            Text(
              booking.date,
              style: const TextStyle(fontSize: 12, color: cinemaFontMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastBookings() {
    final List<Widget> children = [];

    children.add(const Text(
      'Past bookings',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ));
    children.add(const SizedBox(height: 8));

    if (_bookingsError.isNotEmpty) {
      children.add(Text(_bookingsError));
    } else if (_bookings.isEmpty) {
      children.add(const Text(
        'No bookings yet',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ));
    } else {
      for (final Booking booking in _bookings) {
        children.add(_buildBookingCard(booking));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Text(
          'Your basket is empty',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    const TextStyle style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 75, child: Text('Item', style: style)),
          Expanded(child: Text('Details', style: style)),
          SizedBox(
            width: 60,
            child: Text('Price', style: style, textAlign: TextAlign.right),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLineItem(BasketRepository basket, BasketItem item, int index) {
    final String ticketLabel;
    if (item.quantity == 1) {
      ticketLabel = '1 Ticket';
    } else {
      ticketLabel = '${item.quantity} Tickets';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              ticketLabel,
              style: const TextStyle(
                color: cinemaBrand,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${item.quantity} Standard\n'
              '${item.movie.title}, ${item.movie.datetime}, ${item.movie.room}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '£${item.lineTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 44,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cinemaBrand,
                foregroundColor: cinemaFontWhite,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                setState(() {
                  basket.removeItem(index);
                });
              },
              child: const Icon(Icons.delete_outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool emphasise = false}) {
    final TextStyle style;
    if (emphasise) {
      style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
    } else {
      style = const TextStyle(color: cinemaFontWhite, fontSize: 16);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildBasketList(BasketRepository basket, List<BasketItem> items) {
    final List<Widget> children = [];

    children.add(
      const Text(
        'MY ORDER',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
    children.add(const SizedBox(height: 16));
    children.add(_buildHeaderRow());

    for (int index = 0; index < items.length; index++) {
      final BasketItem item = items[index];
      children.add(_buildLineItem(basket, item, index));
    }

    children.add(const SizedBox(height: 24));
    children.add(
      _buildTotalRow(
        'Service Charge',
        '£${basket.getServiceCharge().toStringAsFixed(2)}',
      ),
    );
    children.add(
      _buildTotalRow(
        'Total Due',
        '£${basket.getTotalDue().toStringAsFixed(2)}',
        emphasise: true,
      ),
    );
    children.add(const SizedBox(height: 24));
    children.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PrimaryButton(
            label: 'UPDATE ORDER',
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          PrimaryButton(
            label: 'BUY TICKETS',
            onPressed: () {
              _checkout(basket, items);
            },
          ),
        ],
      ),
    );

    if (_confirmationMessage.isNotEmpty) {
      children.add(const SizedBox(height: 12));
      children.add(
        Text(
          _confirmationMessage,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final BasketRepository basket = BasketRepository.instance;
    final List<BasketItem> items = basket.getItems();

    final Widget content;
    if (items.isEmpty) {
      if (_confirmationMessage.isNotEmpty) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmptyState(),
            const SizedBox(height: 12),
            Text(
              _confirmationMessage,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      } else {
        content = _buildEmptyState();
      }
    } else {
      content = _buildBasketList(basket, items);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Southsea Cinema'), centerTitle: true),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            content,
            const SizedBox(height: 24),
            _buildPastBookings(),
          ],
        ),
      ),
    );
  }
}