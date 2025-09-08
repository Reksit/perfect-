import 'package:flutter/material.dart';
import '../../services/api_extensions.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _myEvents = [];
  List<Map<String, dynamic>> _registeredEvents = [];
  bool _isLoading = false;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCategory = 'Academic';
  String _selectedType = 'Workshop';
  bool _requiresApproval = true;

  final List<String> _categories = [
    'Academic', 'Career', 'Social', 'Technical', 'Cultural', 'Sports'
  ];
  
  final List<String> _eventTypes = [
    'Workshop', 'Seminar', 'Conference', 'Networking', 'Competition', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      // Load all events
      final allEvents = await EventAPI.getAllEvents();
      
      // Load my created events
      final myEvents = await EventAPI.getMyEvents();
      
      // Load registered events
      final registeredEvents = await EventAPI.getRegisteredEvents();
      
      setState(() {
        _events = List<Map<String, dynamic>>.from(allEvents);
        _myEvents = List<Map<String, dynamic>>.from(myEvents);
        _registeredEvents = List<Map<String, dynamic>>.from(registeredEvents);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createEvent() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'capacity': int.tryParse(_capacityController.text) ?? 50,
        'dateTime': eventDateTime.toIso8601String(),
        'category': _selectedCategory,
        'type': _selectedType,
        'requiresApproval': _requiresApproval,
      };

      await EventAPI.createEvent(eventData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form and reload events
      _clearForm();
      _loadEvents();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registerForEvent(String eventId) async {
    try {
      await EventAPI.registerForEvent(eventId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registered for event successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering for event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _unregisterFromEvent(String eventId) async {
    try {
      await EventAPI.unregisterFromEvent(eventId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unregistered from event successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error unregistering from event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _capacityController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedCategory = 'Academic';
      _selectedType = 'Workshop';
      _requiresApproval = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'My Events'),
            Tab(text: 'Registered'),
            Tab(text: 'Create'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllEventsTab(),
                _buildMyEventsTab(),
                _buildRegisteredEventsTab(),
                _buildCreateEventTab(),
              ],
            ),
    );
  }

  Widget _buildAllEventsTab() {
    if (_events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No events available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return _buildEventCard(event, showRegisterButton: true);
        },
      ),
    );
  }

  Widget _buildMyEventsTab() {
    if (_myEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'You haven\'t created any events yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the Create tab to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myEvents.length,
        itemBuilder: (context, index) {
          final event = _myEvents[index];
          return _buildEventCard(event, showEditButton: true);
        },
      ),
    );
  }

  Widget _buildRegisteredEventsTab() {
    if (_registeredEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'You\'re not registered for any events',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check out available events and register',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _registeredEvents.length,
        itemBuilder: (context, index) {
          final event = _registeredEvents[index];
          return _buildEventCard(event, showUnregisterButton: true);
        },
      ),
    );
  }

  Widget _buildEventCard(
    Map<String, dynamic> event, {
    bool showRegisterButton = false,
    bool showUnregisterButton = false,
    bool showEditButton = false,
  }) {
    final eventDateTime = DateTime.tryParse(event['dateTime'] ?? '');
    final isUpcoming = eventDateTime?.isAfter(DateTime.now()) ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUpcoming ? const Color(0xFF1565C0) : Colors.grey[600],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] ?? 'Event Title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event['category'] ?? 'Category',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event['type'] ?? 'Type',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  isUpcoming ? Icons.schedule : Icons.history,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['description'] ?? 'No description available',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Event Info
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'] ?? 'Location TBD',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      eventDateTime != null
                          ? '${eventDateTime.day}/${eventDateTime.month}/${eventDateTime.year} at ${eventDateTime.hour.toString().padLeft(2, '0')}:${eventDateTime.minute.toString().padLeft(2, '0')}'
                          : 'Date TBD',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${event['attendees']?.length ?? 0}/${event['capacity'] ?? 'Unlimited'} attendees',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

                // Action Buttons
                if (showRegisterButton || showUnregisterButton || showEditButton) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (showRegisterButton)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isUpcoming
                                ? () => _registerForEvent(event['_id'] ?? '')
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Register'),
                          ),
                        ),
                      
                      if (showUnregisterButton)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _unregisterFromEvent(event['_id'] ?? ''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Unregister'),
                          ),
                        ),
                      
                      if (showEditButton) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showEditEventDialog(event),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1565C0),
                              side: const BorderSide(color: Color(0xFF1565C0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showEventDetails(event),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Details'),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateEventTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Create New Event',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Organize workshops, seminars, and networking events',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Event Form
          _buildFormField(
            label: 'Event Title',
            controller: _titleController,
            icon: Icons.title,
            hint: 'Enter event title',
          ),

          const SizedBox(height: 16),

          _buildFormField(
            label: 'Description',
            controller: _descriptionController,
            icon: Icons.description,
            hint: 'Describe your event',
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          _buildFormField(
            label: 'Location',
            controller: _locationController,
            icon: Icons.location_on,
            hint: 'Event location',
          ),

          const SizedBox(height: 16),

          _buildFormField(
            label: 'Capacity',
            controller: _capacityController,
            icon: Icons.people,
            hint: 'Maximum attendees',
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          // Date and Time Selection
          Row(
            children: [
              Expanded(
                child: _buildDateTimeSelector(
                  label: 'Date',
                  value: _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                  icon: Icons.calendar_today,
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateTimeSelector(
                  label: 'Time',
                  value: _selectedTime != null
                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'Select time',
                  icon: Icons.access_time,
                  onTap: _selectTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category and Type Selection
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Type',
                  value: _selectedType,
                  items: _eventTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Approval Requirement
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF1565C0)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Require Approval',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Attendees need approval to join',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _requiresApproval,
                  onChanged: (value) {
                    setState(() {
                      _requiresApproval = value;
                    });
                  },
                  activeColor: const Color(0xFF1565C0),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Create Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Create Event',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1565C0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xFF1565C0)),
                    const SizedBox(width: 12),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: value.contains('Select') ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['title'] ?? 'Event Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${event['description'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Location: ${event['location'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Capacity: ${event['capacity'] ?? 'Unlimited'}'),
            const SizedBox(height: 8),
            Text('Attendees: ${event['attendees']?.length ?? 0}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    // For now, just show a placeholder dialog
    // In a real app, you'd implement a full edit form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: const Text('Event editing feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
