import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class MovieListing extends StatefulWidget {
  const MovieListing({super.key});

  @override
  State<MovieListing> createState() => _MovieListingState();
}
class _MovieListingState extends State<MovieListing>{
  int _ticketQuantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle, style: cinemaHeaderStyle),
        backgroundColor: cinemaSurface,
        iconTheme: const IconThemeData(color: cinemaBrand),
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text(
              'How To Train Your Dragon (2025)',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: cinemaFontWhite,
              ),
            ),

            const SizedBox(height: 45),

            const Text(
              'Southsea Cinema Room',
              style: TextStyle(
                fontSize: 18,
                color: cinemaFontWhite,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Thursday 22 Oct 2026, 18:00 - ends at 20:05',
              style: TextStyle(
                fontSize: 18,
                color: cinemaFontWhite,
              ),
            ),

            const SizedBox(height: 45),

            const Text(
              'Please note that Discounts / Membreship Benefits will be applied once you have selected you tickets',
              style: TextStyle(
                fontSize: 18,
                color: cinemaFontWhite,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Select Quantities (Up to 5 in total)',
              style: TextStyle(
                fontSize: 18,
                color: cinemaFontWhite,
              ),
              ),

              const SizedBox(height: 45),

              const Text(
                'Tickets',
                style: TextStyle(
                  fontSize: 24,
                  color: cinemaFontWhite,
                ),
              ),

              const SizedBox(height: 22),


              Row(
                children: [
                  DropdownMenu<int>(
                    initialSelection: 1,
                    onSelected: (int? value) {
                      if (value != null) {
                        setState(() {
                          _ticketQuantity = value;
                        });
                      }
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 1, label: '1'),
                      DropdownMenuEntry(value: 2, label: '2'),
                      DropdownMenuEntry(value: 3, label: '3'),
                      DropdownMenuEntry(value: 4, label: '4'),
                      DropdownMenuEntry(value: 5, label: '5'),
                    ],
                  ),

                  const SizedBox(width: 15),

                  const Text(
                    'Adult (£7.50)',
                    style: TextStyle(
                      fontSize: 18,
                      color: cinemaFontWhite,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cinemaBrand,
                    foregroundColor: cinemaFontWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added $_ticketQuantity ticket(s) to your order',
                        ),
                      ),
                    );
                  },
                  child: const Text('Add to order'),
                ),
            
          ],
        ),
      ),
    );
  }
}
