import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';

class MovieListing extends StatefulWidget {
  final Movie movie;

  const MovieListing({super.key, required this.movie});

  @override
  State<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends State<MovieListing> {
  int _ticketQuantity = 1;
  String _feedback = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      drawer: const NavDrawer(),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: cinemaFontWhite,
              ),
            ),
            const SizedBox(height: 45),
            Text(
              widget.movie.room,
              style: const TextStyle(
                fontSize: 18,
                color: cinemaFontWhite,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              widget.movie.datetime,
              style: const TextStyle(
                fontSize: 18,
                color: cinemaFontWhite,
              ),
            ),
            const SizedBox(height: 45),
            const Text(
              'Please note that Discounts / Membership Benefits will be applied once you have selected your tickets',
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
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      Text(
                        'Adult (${widget.movie.formattedPrice})',
                        style: const TextStyle(
                          fontSize: 18,
                          color: cinemaFontWhite,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 15),
                      Text(
                        'Adult (${widget.movie.formattedPrice})',
                        style: const TextStyle(
                          fontSize: 18,
                          color: cinemaFontWhite,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              label: 'Add to order',
              onPressed: () {
                setState(() {
                  BasketRepository.instance.addItem(
                    BasketItem(movie: widget.movie, quantity: _ticketQuantity),
                );
                  _feedback = 'Added $_ticketQuantity ticket(s) to your order';
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              _feedback,
              style: const TextStyle(
                fontSize: 18,
                color: cinemaFontWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
