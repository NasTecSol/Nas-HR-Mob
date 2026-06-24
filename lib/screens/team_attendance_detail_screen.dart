import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/request_controller/team_attendance_model.dart';
import 'package:nashr/request_controller/user_activity_detail_model.dart';
import 'package:nashr/screens/user_activity_detail_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'dart:math' as math;

import 'package:nashr/widgets/loader.dart';

class TeamAttendanceDetailScreen extends StatefulWidget {
  final TeamAttendanceData? attendanceData;

  const TeamAttendanceDetailScreen({super.key, this.attendanceData});

  @override
  State<TeamAttendanceDetailScreen> createState() =>
      _TeamAttendanceDetailScreenState();
}

class _TeamAttendanceDetailScreenState
    extends State<TeamAttendanceDetailScreen> with TickerProviderStateMixin {
  final SingletonClass singletonClass = SingletonClass();

  bool _expanded = false;
  bool _leaveExpanded = false;
  bool _penalitiesExpanded = false;
  bool _slotsExpanded = false;

  // activity timeline states
  bool _isLoadingActivity = true;
  List<UserActivityDetailModel> _activityRecords = [];

  void _toggleExpand() => setState(() => _expanded = !_expanded);
  void _toggleLeaveExpand() => setState(() => _leaveExpanded = !_leaveExpanded);
  void _togglePenalitiesExpand() =>
      setState(() => _penalitiesExpanded = !_penalitiesExpanded);
  void _toggleSlotsExpand() => setState(() => _slotsExpanded = !_slotsExpanded);

  @override
  void initState() {
    super.initState();
    _fetchActivity();
  }

  Future<void> _fetchActivity() async {
    final data = widget.attendanceData;
    if (data == null || data.empId == null) {
      if (mounted) {
        setState(() {
          _isLoadingActivity = false;
        });
      }
      return;
    }

    final dateStr = (data.date != null && data.date.toString().isNotEmpty)
        ? data.date.toString().split('T').first
        : (data.createdAt != null)
            ? data.createdAt.toString().split('T').first
            : null;

    if (dateStr == null) {
      if (mounted) {
        setState(() {
          _isLoadingActivity = false;
        });
      }
      return;
    }

    try {
      final uri = Uri.parse(
        '${singletonClass.baseURL}/activity-session/fulldetails/$dateStr/$dateStr',
      );

      log('📡 Attendance Detail POST Activity $uri | empId: ${data.empId}');

      final response = await http.post(
        uri,
        body: json.encode({'empIds': [data.empId.toString()]}),
        headers: singletonClass.getHeaders(),
      );

      log('📥 Attendance Detail Activity Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final List<UserActivityDetailModel> records = decoded is List
            ? decoded
                .map((e) => UserActivityDetailModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : [UserActivityDetailModel.fromJson(decoded as Map<String, dynamic>)];

        if (mounted) {
          setState(() {
            _activityRecords = records;
            _isLoadingActivity = false;
          });
        }
      } else {
        log('❌ Attendance Detail Activity API error: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoadingActivity = false;
          });
        }
      }
    } catch (e, s) {
      log('🚨 Attendance Detail Activity Exception: $e\n$s');
      if (mounted) {
        setState(() {
          _isLoadingActivity = false;
        });
      }
    }
  }

  /// ── Helpers ────────────────────────────────────────────────────────

  DateTime? _parseTime(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.parse(s).toUtc();
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return DateFormat("hh:mm a").format(dt.toLocal());
  }

  String _formatMinutes(dynamic minutes) {
    if (minutes == null) return '---';
    try {
      final total =
      (minutes is int) ? minutes : int.parse(minutes.toString());
      final h = total ~/ 60;
      final m = total % 60;
      final l = AppLocalizations.of(context)!;
      return h > 0 ? '$h${l.h} $m${l.m}' : '$m ${l.m}';
    } catch (e) {
      if (kDebugMode) print('Error formatting minutes: $e');
      return '---';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'ontime-in':
      case 'ontime-out':
        return NasColors.green;
      case 'absent':
        return NasColors.reds;
      case 'absent with approval':
      case 'pending':
        return NasColors.yellow;
      case 'early checkout':
        return NasColors.purple;
      case 'late':
        return NasColors.amber;
      case 'check-in':
        return NasColors.violet;
      case 'check-out':
        return NasColors.fuchsia;
      case 'oos-in':
      case 'oos-out':
        return NasColors.amber;
      case 'early-in':
      case 'early-out':
        return NasColors.rose;
      case 'late-in':
      case 'late-out':
        return NasColors.brightRed;
      case 'sm-in':
      case 'sm-out':
        return NasColors.indigo;
      case 'break-in':
      case 'break-out':
        return NasColors.zinc;
      case 'slot':
        return NasColors.warmGray;
      case 'no-checkin':
        return NasColors.darkGray;
      case 'on-leave':
      case 'casual leave':
        return NasColors.blue;
      default:
        return NasColors.orange;
    }
  }

  String _translateStatus(String? status, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (status == null || status.isEmpty) return l.noData;
    switch (status) {
      case 'Absent': return l.absent;
      case 'Present': return l.present;
      case 'Quarterly': return l.quarterly;
      case 'Missing CheckIn/Out': return l.missingCheckInOut;
      case 'On-Leave': return l.annualLeave;
      default: return status;
    }
  }

  String _translateSecondaryStatus(String? status, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (status == null || status.isEmpty) return l.noData;
    switch (status) {
      case 'Absent': return l.absent;
      case 'Present': return l.present;
      case 'late': case 'Late': return l.late;
      case 'leave': return l.leave;
      case 'holiday': return l.holiday;
      case 'dayOFF': return l.dayOff;
      case 'training': return l.training;
      case 'absent with approval': return l.absentWithApproval;
      case 'Missing CheckIn/Out': return l.missingCheckInOut;
      case 'Pending': return l.pending;
      case 'No-CheckIn': return l.noCheckIn;
      case 'Late-Penality': return l.latePenality;
      case 'Short-Hours': return l.shortHours;
      case 'Missing-CheckIn': return l.missingCheckIn;
      case 'Missing-CheckOut': return l.missingCheckOut;
      case 'Check-In': return l.checkIn;
      case 'Check-Out': return l.checkOut;
      case 'OOS-In': return l.oosIn;
      case 'OOS-Out': return l.oosOut;
      case 'Early-In': return l.earlyIn;
      case 'Early-Left': return l.earlyLeft;
      case 'OnTime-In': return l.onTimeIn;
      case 'OnTime-Out': return l.onTimeOut;
      case 'Late-In': return l.lateIn;
      case 'Late-Out': return l.lateOut;
      case 'SM-In': return l.smIn;
      case 'SM-Out': return l.smOut;
      case 'Break-In': return l.breakIn;
      case 'Break-Out': return l.breakOut;
      case 'slot': return l.slot;
      case 'Out-Off-Shift': return l.outOffShift;
      case 'Full-Day': return l.fullDay;
      case 'annualLeave': return l.annualLeave;
      default: return status;
    }
  }

  /// ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final data = widget.attendanceData!;
    final l = AppLocalizations.of(context)!;

    final lateMinutes = _formatMinutes(data.lateMinutes);
    final earlyMinutes = _formatMinutes(data.earlyCheckOut);
    final totalBreakMinutes = data.breaksTaken!.isEmpty
        ? 0.0
        : data.breaksTaken!
        .map((b) => b['durationMinutes'] ?? 0.0)
        .reduce((a, b) => a + b);
    final totalBreakString = _formatMinutes(totalBreakMinutes);
    final workedMinutes = data.totalHoursWorked ?? 0;

    final leaveDetails = data.leaveDetails;
    final requestInfo = leaveDetails?.requestInfo;
    final requestData = requestInfo?.requestData;
    final approvers = requestInfo?.approvers;
    final hasLeaveData = requestData != null && requestData.isNotEmpty;

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: SafeArea(
        child: Column(
          children: [
            /// ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.attendanceDetail,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      Text(
                        singletonClass.formatDate2(data.createdAt!, context),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ── Employee Header Card ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipOval(
                        child: Image.asset('images/DP.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name + EmpId
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name ?? '---',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: NasColors.darkBlue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data.empId ?? '---',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: NasColors.darkBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badges
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (data.status != null)
                          _statusBadge(
                            _translateStatus(data.status!, context),
                            _statusColor(data.status!),
                            tall: data.status == "Missing CheckIn/Out",
                          ),
                        if (data.secondaryStatus != null) ...[
                          const SizedBox(height: 4),
                          _statusBadge(
                            _translateSecondaryStatus(
                                data.secondaryStatus!, context),
                            _statusColor(data.secondaryStatus!),
                            tall: data.secondaryStatus == "Missing-CheckOut",
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// ── Scrollable Content ───────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  /// Clock In / Out Card
                  _sectionCard(
                    child: Column(
                      children: [
                        /// Clock In row
                        Row(
                          children: [
                            Transform(
                              transform: Matrix4.rotationY(math.pi),
                              alignment: Alignment.center,
                              child: Icon(Icons.exit_to_app_outlined,
                                  size: 20, color: NasColors.darkBlue),
                            ),
                            const SizedBox(width: 6),
                            Text(l.clockIn,
                                style: _bodyStyle(color: Colors.grey.shade600)),
                            const SizedBox(width: 8),
                            Text(
                              singletonClass.formatCheckInTime(
                                  data.clockInTime, context),
                              style: _bodyStyle(weight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Icon(Icons.error,
                                size: 16, color: NasColors.pending),
                            const SizedBox(width: 4),
                            Text('${l.late}: ',
                                style:
                                _bodyStyle(color: NasColors.pending, size: 12)),
                            Text(lateMinutes,
                                style: _bodyStyle(
                                    weight: FontWeight.w700, size: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 12),
                        // Clock Out row
                        Row(
                          children: [
                            Icon(Icons.exit_to_app_outlined,
                                size: 20, color: NasColors.darkBlue),
                            const SizedBox(width: 6),
                            Text(l.clockOut,
                                style: _bodyStyle(color: Colors.grey.shade600)),
                            const SizedBox(width: 8),
                            Text(
                              singletonClass.formatCheckInTime(
                                  data.clockOutTime, context),
                              style: _bodyStyle(weight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Icon(Icons.directions_run_outlined,
                                size: 16, color: NasColors.onTime),
                            const SizedBox(width: 4),
                            Text('${l.earlyLeft}: ',
                                style:
                                _bodyStyle(color: NasColors.onTime, size: 12)),
                            Text(earlyMinutes,
                                style: _bodyStyle(
                                    weight: FontWeight.w700, size: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Worked row
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: NasColors.darkBlue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${l.worked}: ',
                                  style: _bodyStyle(
                                      color: Colors.grey.shade600, size: 13)),
                              Text(
                                '${workedMinutes ~/ 60}${l.h} ${workedMinutes % 60}${l.m}',
                                style: _bodyStyle(
                                    weight: FontWeight.w700,
                                    color: NasColors.darkBlue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Activity Timeline ─────────────────────────────
                  if (_isLoadingActivity)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Loader(),
                      ),
                    )
                  else if (_activityRecords.isNotEmpty) ...[
                    ActivityTimelineBar(
                      records: _activityRecords,
                      onDetailPressed: () {
                        final dateStr = (data.date != null && data.date.toString().isNotEmpty)
                            ? data.date.toString().split('T').first
                            : (data.createdAt != null)
                                ? data.createdAt.toString().split('T').first
                                : null;
                        final attendanceDate = dateStr != null
                            ? (DateTime.tryParse(dateStr) ?? DateTime.now())
                            : DateTime.now();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserActivityDetailScreen(
                              empId: data.empId ?? '',
                              empName: data.name ?? '',
                              designation: '',
                              startDate: attendanceDate,
                              endDate: attendanceDate,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Break Taken ──────────────────────────────────
                  _expandableCard(
                    icon: Icons.coffee_rounded,
                    iconColor: Colors.brown.shade400,
                    title: l.breakTaken,
                    count: data.breaksTaken!.length,
                    expanded: _expanded,
                    onToggle: _toggleExpand,
                    child: _expanded
                        ? _buildBreaksContent(
                        data, totalBreakString, context, l)
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Penalties ────────────────────────────────────
                  _expandableCard(
                    icon: Icons.warning_rounded,
                    iconColor: Colors.red.shade400,
                    title: l.penalties,
                    count: data.penalties!.length,
                    expanded: _penalitiesExpanded,
                    onToggle: _togglePenalitiesExpand,
                    child: _penalitiesExpanded
                        ? _buildPenaltiesContent(data, context, l)
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Slots (timeTableShift only) ──────────────────
                  if (data.shiftInfo?.shiftType == 'timeTableShift') ...[
                    _expandableCard(
                      customIcon: Image.asset('images/slots.png',
                          width: 22, height: 22),
                      title: l.slots,
                      count: data.slots!.length,
                      expanded: _slotsExpanded,
                      onToggle: _toggleSlotsExpand,
                      child:
                      _slotsExpanded ? _buildSlotsContent(data, context, l) : null,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Leave Information ────────────────────────────
                  _expandableCard(
                    customIcon: Image.asset('images/time.png',
                        width: 22, height: 22),
                    title: l.leaveInfo,
                    count: null,
                    expanded: _leaveExpanded,
                    onToggle: _toggleLeaveExpand,
                    child: _leaveExpanded
                        ? _buildLeaveContent(
                        data, hasLeaveData, requestInfo, requestData,
                        approvers, context, l)
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Remarks ──────────────────────────────────────
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('images/Comments.png',
                                width: 22, height: 22),
                            const SizedBox(width: 8),
                            Text(l.remarks,
                                style: _bodyStyle(
                                    weight: FontWeight.w700,
                                    color: NasColors.darkBlue,
                                    size: 15)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.shade200),
                          ),
                          child: Text(
                            data.remarks ==
                                'Check-out time is missing Auto updated by system'
                                ? l.missingCheckInAndCheckOut
                                : (data.remarks ?? ''),
                            style: _bodyStyle(
                                color: Colors.black87, size: 13),
                            maxLines: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ── Section builders ───────────────────────────────────────────────

  Widget _buildBreaksContent(TeamAttendanceData data, String totalBreakString,
      BuildContext context, AppLocalizations l) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Table header
        _tableHeader([l.breakNo, l.startTime, l.endTime, l.duration]),
        const SizedBox(height: 8),
        data.breaksTaken!.isNotEmpty
            ? SizedBox(
          height: 220,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.breaksTaken!.length,
            itemBuilder: (_, index) {
              final b = data.breaksTaken![index];
              final start =
              _parseTime(b['startTime'].toString())?.toLocal();
              final end = _parseTime(b['endTime'].toString())?.toLocal();
              final dur = _formatMinutes(b['durationMinutes']);
              return _tableRow([
                '${index + 1}',
                _formatDateTime(start),
                _formatDateTime(end),
                dur,
              ]);
            },
          ),
        )
            : _emptyState(context),
        const SizedBox(height: 8),
        // Total row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('${l.totalDuration}: ',
                style: _bodyStyle(color: Colors.grey.shade600, size: 13)),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: NasColors.darkBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(totalBreakString,
                  style: _bodyStyle(
                      weight: FontWeight.w700,
                      color: NasColors.darkBlue,
                      size: 13)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPenaltiesContent(TeamAttendanceData data, BuildContext context,
      AppLocalizations l) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _tableHeader([l.category, l.details, l.value]),
        const SizedBox(height: 8),
        data.penalties!.isNotEmpty
            ? SizedBox(
          height: 220,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.penalties!.length,
            itemBuilder: (_, index) {
              final p = data.penalties![index];
              return _tableRow([
                (p.action?.isNotEmpty ?? false) ? p.action! : '---',
                p.lateMinute != null
                    ? singletonClass.formatMinutes(
                    p.lateMinute!, context)
                    : '---',
                p.percentage != null
                    ? '${p.percentage} SAR'
                    : '---',
              ]);
            },
          ),
        )
            : _emptyState(context),
      ],
    );
  }

  Widget _buildSlotsContent(TeamAttendanceData data, BuildContext context,
      AppLocalizations l) {
    return Column(
      children: [
        const SizedBox(height: 8),
        data.slots!.isNotEmpty
            ? SizedBox(
          height: 220,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.slots!.length,
            itemBuilder: (_, index) {
              final slot = data.slots![index];
              final checkIn =
              _parseTime(slot.checkInTime?.toString() ?? '')?.toLocal();
              final checkOut =
              _parseTime(slot.checkOutTime?.toString() ?? '')?.toLocal();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Check-in row
                        Row(
                          children: [
                            Icon(Icons.exit_to_app_outlined,
                                size: 16, color: Colors.black54),
                            const SizedBox(width: 4),
                            Text('${l.clockIn}: ',
                                style:
                                _bodyStyle(size: 12, color: Colors.black54)),
                            Text(
                              checkIn != null
                                  ? singletonClass.formatCheckInTime(
                                  slot.checkInTime, context)
                                  : '___',
                              style: _bodyStyle(
                                  size: 12, weight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Icon(Icons.error,
                                size: 14, color: NasColors.pending),
                            const SizedBox(width: 3),
                            Text('${l.late}: ',
                                style: _bodyStyle(
                                    size: 11, color: NasColors.pending)),
                            Text(
                              (slot.lateMinutes?.toString().isNotEmpty ??
                                  false)
                                  ? '${slot.lateMinutes}'
                                  : '___',
                              style: _bodyStyle(
                                  size: 12, weight: FontWeight.w600),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(slot.status ?? ''),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _translateStatus(slot.status ?? '', context),
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                            height: 16,
                            color: Colors.grey.shade200),
                        // Check-out row
                        Row(
                          children: [
                            Transform(
                              transform: Matrix4.rotationY(math.pi),
                              alignment: Alignment.center,
                              child: Icon(Icons.exit_to_app_outlined,
                                  size: 16, color: Colors.black54),
                            ),
                            const SizedBox(width: 4),
                            Text('${l.clockOut}: ',
                                style:
                                _bodyStyle(size: 12, color: Colors.black54)),
                            Text(
                              checkOut != null
                                  ? singletonClass.formatCheckInTime(
                                  slot.checkOutTime, context)
                                  : '___',
                              style: _bodyStyle(
                                  size: 12, weight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Icon(Icons.directions_run_outlined,
                                size: 14, color: NasColors.onTime),
                            const SizedBox(width: 3),
                            Text('${l.earlyLeft}: ',
                                style: _bodyStyle(
                                    size: 11, color: NasColors.onTime)),
                            Text(
                              (slot.earlyCheckOut?.toString().isNotEmpty ??
                                  false)
                                  ? '${slot.earlyCheckOut}'
                                  : '___',
                              style: _bodyStyle(
                                  size: 12, weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
            : _emptyState(context),
      ],
    );
  }

  Widget _buildLeaveContent(
      TeamAttendanceData data,
      bool hasLeaveData,
      dynamic requestInfo,
      dynamic requestData,
      dynamic approvers,
      BuildContext context,
      AppLocalizations l,
      ) {
    final hasData = hasLeaveData &&
        data.leaveDetails != null &&
        data.leaveDetails!.requestInfo!.requestData!.isNotEmpty;

    String safeLeaveValue(String value) => hasData ? value : '---';
    String safeStatus() {
      if (!hasData) return '---';
      final s = data.leaveDetails!.requestInfo!.status;
      if (s == 'approved') return l.approved;
      if (s == 'rejected') return l.rejected;
      return l.pending;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          _leaveRow(l.leaveType,
              safeLeaveValue('${requestData?.first.leaveType}')),
          _leaveRow(
              l.reason,
              hasData
                  ? '${data.leaveDetails!.requestInfo!.reason}'
                  : '---'),
          _leaveRow(l.status, safeStatus()),
          _leaveRow(
            l.duration,
            hasData
                ? '${requestData!.first.startDate} - ${requestData.first.endDate}'
                : '---',
          ),
          // Approvers
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.approver,
                  style: _bodyStyle(
                      color: Colors.grey.shade500,
                      weight: FontWeight.w600,
                      size: 13)),
              const Spacer(),
              if (approvers != null && approvers.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: approvers.map<Widget>((approver) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(approver.approverName ?? '---',
                                  style: _bodyStyle(
                                      weight: FontWeight.w700, size: 13)),
                              const SizedBox(width: 4),
                              Text(approver.status == 'approved'
                                  ? '✅'
                                  : approver.status == 'rejected'
                                  ? '❌'
                                  : '⏳'),
                            ],
                          ),
                          if (approver.comments?.isNotEmpty == true)
                            Text(
                              '${l.comments}: ${approver.comments}',
                              style: _bodyStyle(
                                  size: 12, color: Colors.black87),
                            ),
                          if (approver.timeStamps != null)
                            Text(
                              '${l.timeStamp}: ${singletonClass.formatDateTime(approver.timeStamps!)}',
                              style: _bodyStyle(
                                  size: 11, color: Colors.grey.shade500),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Text('---',
                    style: _bodyStyle(weight: FontWeight.w700, size: 13)),
            ],
          ),
        ],
      ),
    );
  }

  /// ── Reusable building blocks (not extra widget classes) ────────────

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _expandableCard({
    IconData? icon,
    Color? iconColor,
    Widget? customIcon,
    required String title,
    required int? count,
    required bool expanded,
    required VoidCallback onToggle,
    Widget? child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                if (customIcon != null) customIcon,
                if (icon != null)
                  Icon(icon, size: 22, color: iconColor ?? NasColors.darkBlue),
                const SizedBox(width: 8),
                Text(title,
                    style: _bodyStyle(
                        weight: FontWeight.w700,
                        color: NasColors.darkBlue,
                        size: 15)),
                const SizedBox(width: 8),
                if (count != null)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: NasColors.darkBlue.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: NasColors.darkBlue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expandable body
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: Colors.grey.shade100),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: child ?? const SizedBox.shrink(),
                ),
              ],
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color, {bool tall = false}) {
    return Container(
      height: tall ? 48 : 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _tableHeader(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map((l) => Text(l,
          style: _bodyStyle(
              color: Colors.grey.shade500,
              weight: FontWeight.w600,
              size: 12)))
          .toList(),
    );
  }

  Widget _tableRow(List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: values
              .map((v) => Text(v,
              style: _bodyStyle(weight: FontWeight.w600, size: 13),
              textAlign: TextAlign.center))
              .toList(),
        ),
      ),
    );
  }

  Widget _leaveRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label,
              style: _bodyStyle(
                  color: Colors.grey.shade500,
                  weight: FontWeight.w600,
                  size: 13)),
          const Spacer(),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: _bodyStyle(weight: FontWeight.w700, size: 13)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Lottie.asset('images/empty.json'),
          ),
          Text(AppLocalizations.of(context)!.noData,
              style: _bodyStyle(
                  weight: FontWeight.w500,
                  color: NasColors.darkBlue,
                  size: 15)),
        ],
      ),
    );
  }

  Widget _circleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: NasColors.darkBlue, size: 20),
      ),
    );
  }

  TextStyle _bodyStyle({
    FontWeight weight = FontWeight.normal,
    Color? color,
    double size = 14,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? Colors.black87,
    );
  }
}