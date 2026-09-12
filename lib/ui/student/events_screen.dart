import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../state/app_state.dart';
//

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _searchQuery = '';
  bool _showMyRegistrationsOnly = false;

  final List<String> _categories = ["All", "Workshops", "Hackathons", "Tech Talks"];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    List<EventModel> displayedEvents = state.filteredEvents;

    if (_showMyRegistrationsOnly) {
      displayedEvents = displayedEvents.where((e) => e.isRegistered).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      displayedEvents = displayedEvents
          .where((e) =>
              e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.speaker.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.venue.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search events, workshops, speakers...',
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // My Registrations Toggle
                    FilterChip(
                      selected: _showMyRegistrationsOnly,
                      label: Text(
                        'Registered (${state.registeredEvents.length})',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _showMyRegistrationsOnly ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      selectedColor: AppColors.secondary,
                      backgroundColor: AppColors.surfaceContainerLow,
                      showCheckmark: false,
                      side: BorderSide.none,
                      onSelected: (val) => setState(() => _showMyRegistrationsOnly = val),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Category Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = state.selectedEventCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceContainerLow,
                          showCheckmark: false,
                          side: BorderSide.none,
                          onSelected: (_) => state.setEventCategory(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outline),

          // Department Events Header Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: AppColors.surfaceContainerLow,
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  'Department Live Events & Workshops',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  ' Available',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Events List with RefreshIndicator
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => state.syncFromSupabase(),
              color: const Color(0xFF3ECF8E),
              child: displayedEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 48, color: AppColors.outlineVariant),
                          const SizedBox(height: 12),
                          Text(
                            _showMyRegistrationsOnly
                                ? 'No registered events yet'
                                : 'No matching events found',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: displayedEvents.length,
                      itemBuilder: (ctx, i) => _buildEventCard(context, displayedEvents[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final state = context.watch<AppState>();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: event.isRegistered ? AppColors.secondary.withValues(alpha: 0.5) : AppColors.outline,
          width: event.isRegistered ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Card Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Block
                Container(
                  width: 52,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.dateMonth,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        event.dateDay,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.category.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (event.isRegistered)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'CONFIRMED',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Metadata Row: Speaker & Venue
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            child: Row(
              children: [
                const Icon(Icons.mic, size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.speaker,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  event.venue.split('&').first.trim(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Footer Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      '${event.seatsLeft} seats left',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: event.seatsLeft < 10 ? AppColors.error : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _showEventDetailsModal(context, event),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outline),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Details',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        state.toggleEventRegistration(event.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(event.isRegistered
                                ? 'RSVP Cancelled'
                                : 'RSVP Confirmed for ${event.title}!'),
                            backgroundColor: event.isRegistered ? AppColors.onSurfaceVariant : AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event.isRegistered ? AppColors.surfaceContainerHigh : AppColors.primary,
                        foregroundColor: event.isRegistered ? AppColors.onSurface : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        event.isRegistered ? 'Leave' : 'Register',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetailsModal(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.category.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${event.seatsLeft} of ${event.totalSeats} seats open',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.calendar_today, '${event.dateMonth} ${event.dateDay}, 2026 • ${event.time}'),
            const SizedBox(height: 8),
            _detailRow(Icons.location_on, event.venue),
            const SizedBox(height: 8),
            _detailRow(Icons.person, event.speaker),
            const SizedBox(height: 16),
            const Divider(color: AppColors.outline),
            const SizedBox(height: 12),
            Text(
              'About this Session',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              event.description,
              style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Text(
              'Prerequisites & Checklist',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            _checklistRow('Bring personal laptop with Docker or WSL2 configured'),
            _checklistRow('Department VPN profile installed (available in Software Hub)'),
            _checklistRow('Valid Lab Pass or Student NFC badge for turnstile entrance'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().toggleEventRegistration(event.id);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: event.isRegistered ? AppColors.surfaceContainerHigh : AppColors.primary,
                  foregroundColor: event.isRegistered ? AppColors.onSurface : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  event.isRegistered ? 'Cancel RSVP' : 'Confirm Registration & Generate Pass',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _checklistRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}



