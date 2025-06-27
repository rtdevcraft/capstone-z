import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenigo/src/core/models/report.dart';
import 'package:zenigo/src/features/reports/presentation/report_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:zenigo/src/shared/constants/app_icons.dart';

class ReportEditorScreen extends ConsumerStatefulWidget {
  final Report? report;

  const ReportEditorScreen({super.key, this.report});

  @override
  ConsumerState<ReportEditorScreen> createState() => _ReportEditorScreenState();
}

class _ReportEditorScreenState extends ConsumerState<ReportEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DateTimeRange _dateRange;
  late List<UserSessionRow> _rows;

  @override
  void initState() {
    super.initState();
    _title = widget.report?.title ?? '';
    _dateRange = widget.report?.dateRange ??
        DateTimeRange(start: DateTime.now(), end: DateTime.now());
    _rows = widget.report?.rows ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null ? 'Create Report' : 'Edit Report'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.save),
            onPressed: _saveReport,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 16),
            _buildDateRangePicker(),
            const SizedBox(height: 16),
            _buildColumnHeaders(),
            const SizedBox(height: 8),
            _buildRows(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Date Range: ${MaterialLocalizations.of(context).formatShortDate(_dateRange.start)} - ${MaterialLocalizations.of(context).formatShortDate(_dateRange.end)}',
          ),
        ),
        IconButton(
          icon: const Icon(AppIcons.calendarToday),
          onPressed: () async {
            final newDateRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDateRange: _dateRange,
            );
            if (newDateRange != null) {
              setState(() {
                _dateRange = newDateRange;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildColumnHeaders() {
    return Row(
      children: [
        Expanded(
            child: Text('Routine',
                style: Theme.of(context).textTheme.titleMedium)),
        Expanded(
            child: Text('Completed At',
                style: Theme.of(context).textTheme.titleMedium)),
        Expanded(
            child:
                Text('Duration', style: Theme.of(context).textTheme.titleMedium)),
      ],
    );
  }

  Widget _buildRows() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _rows.length,
      itemBuilder: (context, index) {
        return _buildRow(_rows[index]);
      },
    );
  }

  Widget _buildRow(UserSessionRow row) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Text(row.routineTitle)),
            Expanded(
                child: Text(MaterialLocalizations.of(context)
                    .formatShortDate(row.completedAt))),
            Expanded(child: Text('${row.duration.inMinutes} min')),
          ],
        ),
      ),
    );
  }

  void _saveReport() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final report = Report(
        id: widget.report?.id ?? const Uuid().v4(),
        title: _title,
        dateRange: _dateRange,
        rows: _rows,
      );
      // ref.read(reportControllerProvider.notifier).saveReport(report);
    }
  }
}