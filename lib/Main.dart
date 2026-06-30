import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'GuestHomePage.dart';
import 'about.dart';
import 'BrowseServicesPage.dart';
import 'SearchVenues.dart';
import 'LoginPage.dart';
import 'ContactPage.dart';
import 'Createaccountpage.dart';
import 'UserDashboardPage.dart';
import 'UserBookinghistorypage.dart';
import 'Bookingpage.dart';
import 'Paymentpage.dart';
import 'UserFavoritespage.dart';
import 'UserNotificationsPage.dart';
import 'UserProfilePage.dart';
import 'Reviewpage.dart';
import 'VenueDetailPage.dart';
import 'FarhaSplashScreen.dart';

void main() {
  runApp(const FarhaApp());
}

class FarhaApp extends StatelessWidget {
  const FarhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farha',
      theme: farhaTheme(),
      home: const FarhaSplashScreen(),
    );
  }
}