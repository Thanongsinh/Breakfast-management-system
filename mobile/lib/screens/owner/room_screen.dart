import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../widgets/empty_state.dart';
import '../../providers/building_provider.dart';
import '../../providers/room_provider.dart';
import '../../app/constants.dart';
import '../../models/building.dart';
import '../../models/room.dart';

class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key});

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  Building? _selectedBuilding;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(buildingProvider.notifier).loadBuildings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final buildingState = ref.watch(buildingProvider);
    final roomState = ref.watch(roomProvider);

    return RoleAwareScaffold(
      title: 'Room Management',
      body: Column(
        children: [
          _buildBuildingSelector(buildingState),
          const SizedBox(height: AppConstants.spacingSm),
          Expanded(
            child: _buildRoomsList(roomState),
          ),
        ],
      ),
      floatingActionButton: _selectedBuilding != null
          ? FloatingActionButton.extended(
              onPressed: _showAddRoomDialog,
              backgroundColor: AppConstants.ownerPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Add Room'),
            )
          : null,
    );
  }

  Widget _buildBuildingSelector(BuildingState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppConstants.spacingMd),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.buildings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppConstants.warningColor),
                const SizedBox(width: AppConstants.spacingMd),
                const Expanded(
                  child: Text('No buildings found. Please add a building first.'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Building',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppConstants.textSecondary,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.borderColor),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Building>(
                isExpanded: true,
                value: _selectedBuilding,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
                  child: Text('Choose a building'),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                items: state.buildings.map((building) {
                  return DropdownMenuItem<Building>(
                    value: building,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          building.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${building.occupiedRooms}/${building.totalRooms} occupied',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppConstants.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (building) {
                  setState(() {
                    _selectedBuilding = building;
                  });
                  if (building != null) {
                    ref.read(roomProvider.notifier).loadRoomsByBuilding(building.id);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList(RoomState state) {
    if (_selectedBuilding == null) {
      return const EmptyState(
        icon: Icons.apartment,
        title: 'Select a Building',
        message: 'Please select a building to view its rooms',
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppConstants.errorColor,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppConstants.textSecondary),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ElevatedButton(
              onPressed: () {
                if (_selectedBuilding != null) {
                  ref.read(roomProvider.notifier).loadRoomsByBuilding(_selectedBuilding!.id);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final rooms = state.rooms;
    if (rooms.isEmpty) {
      return EmptyState(
        icon: Icons.meeting_room,
        title: 'No Rooms',
        message: 'No rooms found in ${_selectedBuilding!.name}',
        actionLabel: 'Add Room',
        onAction: _showAddRoomDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedBuilding != null) {
          await ref.read(roomProvider.notifier).loadRoomsByBuilding(_selectedBuilding!.id);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingMd),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return _buildRoomCard(room);
        },
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    final statusColor = _getRoomStatusColor(room.status);
    final statusIcon = _getRoomStatusIcon(room.status);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showRoomDetails(room),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppConstants.spacingMd),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          ),
                          child: Icon(
                            statusIcon,
                            color: statusColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room ${room.roomNumber}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppConstants.spacingXs),
                              Text(
                                room.buildingName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppConstants.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                      vertical: AppConstants.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _formatStatus(room.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: AppConstants.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Rate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        AppConstants.formatCurrency(room.monthlyRate),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppConstants.ownerPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  if (room.isOccupied && room.tenantName != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Tenant',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppConstants.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        Text(
                          room.tenantName!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoomStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppConstants.successColor;
      case 'occupied':
        return AppConstants.infoColor;
      case 'maintenance':
        return AppConstants.warningColor;
      default:
        return AppConstants.textSecondary;
    }
  }

  IconData _getRoomStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle;
      case 'occupied':
        return Icons.person;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.meeting_room;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'occupied':
        return 'Occupied';
      case 'maintenance':
        return 'Maintenance';
      default:
        return status.toUpperCase();
    }
  }

  void _showRoomDetails(Room room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: AppConstants.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Room ${room.roomNumber}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem('Building', room.buildingName),
                        _buildDetailItem('Room Number', room.roomNumber),
                        _buildDetailItem('Status', _formatStatus(room.status)),
                        _buildDetailItem('Monthly Rate', AppConstants.formatCurrency(room.monthlyRate)),
                        if (room.tenantName != null)
                          _buildDetailItem('Tenant', room.tenantName!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                if (room.status != 'occupied')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateRoomStatus(room);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.ownerPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spacingMd,
                        ),
                      ),
                      child: const Text('Update Status'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _updateRoomStatus(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Room Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Available'),
              leading: Radio<String>(
                value: 'available',
                groupValue: room.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  _processStatusUpdate(room, value!);
                },
              ),
            ),
            ListTile(
              title: const Text('Maintenance'),
              leading: Radio<String>(
                value: 'maintenance',
                groupValue: room.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  _processStatusUpdate(room, value!);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _processStatusUpdate(Room room, String newStatus) async {
    try {
      await ref.read(roomProvider.notifier).updateRoomStatus(
            id: room.id,
            buildingId: room.buildingId,
            status: newStatus,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room status updated to ${_formatStatus(newStatus)}'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _showAddRoomDialog() {
    final roomNumberController = TextEditingController();
    final monthlyRateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roomNumberController,
              decoration: const InputDecoration(
                labelText: 'Room Number',
                hintText: 'e.g., 101',
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: monthlyRateController,
              decoration: const InputDecoration(
                labelText: 'Monthly Rate',
                hintText: 'e.g., 5000',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addRoom(
                roomNumberController.text,
                monthlyRateController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.ownerPrimary,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addRoom(String roomNumber, String monthlyRate) async {
    if (_selectedBuilding == null) return;

    if (roomNumber.isEmpty || monthlyRate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    try {
      final rate = double.parse(monthlyRate);
      await ref.read(roomProvider.notifier).createRoom(
            buildingId: _selectedBuilding!.id,
            roomNumber: roomNumber,
            monthlyRate: rate,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room added successfully'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding room: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }
}
