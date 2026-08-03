import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/screens/create_hr_letter_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/widgets/loader.dart';
import 'package:nashr/widgets/document_list_tab.dart';
import 'package:nashr/widgets/document_cards_tab.dart';
import 'package:nashr/widgets/document_hr_letters_tab.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await loadLanguage();
      await singletonClass.getEmployeeData();
      await singletonClass.getHRLetter();
    } catch (e) {
      debugPrint("Error initializing documents: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchLatestDocumentData() async {
    try {
      await singletonClass.getEmployeeData();
      await singletonClass.getHRLetter();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> loadLanguage() async {
    final sp = await SharedPreferences.getInstance();
    final lang = sp.getString("Language") ?? "en";
    singletonClass.local = lang;
  }

  @override
  Widget build(BuildContext context) {
    final uiSettings = singletonClass.roleAndAccessModelDataList.isNotEmpty
        ? (singletonClass.roleAndAccessModelDataList.first.data?.uiSettings?.uiModules ?? [])
        : [];
        
    final canCreateHRLetter = uiSettings.any((e) {
      if (e.title == "Document" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
            sub.title == "Manage HR Letters" && sub.accessType?.add == true) ??
            false;
      }
      return false;
    });
    
    final canSeeHRLetter = uiSettings.any((e) {
      if (e.title == "Document" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
            sub.title == "Manage HR Letters" && sub.hidden == false) ??
            false;
      }
      return false;
    });

    int docCount = 0;
    if (singletonClass.employeeDataList.isNotEmpty &&
        singletonClass.employeeDataList.first.data.isNotEmpty) {
      final docInfo = singletonClass.employeeDataList.first.data.first.documentsInfo ?? [];
      docCount = docInfo.where((doc) => doc.type != "Doc_editor_shared").length;
    }

    int hrCount = 0;
    if (singletonClass.documentSharedTemplateDataList.isNotEmpty) {
      final allHR = singletonClass.documentSharedTemplateDataList.first.data?.data ?? [];
      hrCount = allHR.where((doc) {
        final employeeId = singletonClass.getJWTModel()?.employeeId;
        final createdBy = doc.objectDetails?.createdBy;
        final allowedEmployees = doc.objectDetails?.parameters?.employees ?? [];
        return createdBy == employeeId || allowedEmployees.contains(employeeId);
      }).length;
    }

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          _buildHeader(context, canCreateHRLetter),
          const SizedBox(height: 12),
          _buildFilterChips(context, canSeeHRLetter, docCount, hrCount),
          const SizedBox(height: 10),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool canCreateHRLetter) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NasColors.darkBlue, NasColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: NasColors.darkBlue.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                AppLocalizations.of(context)!.myDocuments,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (canCreateHRLetter && _selectedOptionIndex == 2)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateHrLetterScreen()),
                    ).then((_) {
                      fetchLatestDocumentData();
                    });
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, bool canSeeHRLetter, int docCount, int hrCount) {
    final l = AppLocalizations.of(context)!;
    final options = [
      (l.documents, 0, docCount),
      (l.card, 1, 3), // Count is 3 (Iqama/NationalID, Passport, Contract)
      if (canSeeHRLetter)
        (l.hrLetter, 2, hrCount),
    ];

    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: options.length,
        itemBuilder: (ctx, i) {
          final (label, idx, count) = options[i];
          return _FilterChip(
            label: label,
            count: count,
            selected: _selectedOptionIndex == idx,
            accentColor: NasColors.darkBlue,
            onTap: () {
              setState(() => _selectedOptionIndex = idx);
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: Loader());
    }

    final employeeDataList = singletonClass.employeeDataList;
    if (employeeDataList.isEmpty || employeeDataList.first.data.isEmpty) {
      return const Center(child: Loader());
    }

    final documentInfo = employeeDataList.first.data.first.documentsInfo ?? [];
    final filteredDocs = documentInfo.where((doc) => doc.type != "Doc_editor_shared").toList();

    switch (_selectedOptionIndex) {
      case 0:
        return DocumentListTab(
          documentsInfo: filteredDocs,
          onRefresh: fetchLatestDocumentData,
        );
      case 1:
        return DocumentCardsTab(
          singletonClass: singletonClass,
        );
      case 2:
        final allHR = singletonClass.documentSharedTemplateDataList.isNotEmpty
            ? (singletonClass.documentSharedTemplateDataList.first.data?.data ?? [])
            : [];
        final hrLetters = allHR.where((doc) {
          final employeeId = singletonClass.getJWTModel()?.employeeId;
          final createdBy = doc.objectDetails?.createdBy;
          final allowedEmployees = doc.objectDetails?.parameters?.employees ?? [];
          return createdBy == employeeId || allowedEmployees.contains(employeeId);
        }).toList();
        return DocumentHrLettersTab(
          hrLetters: hrLetters,
          onRefresh: fetchLatestDocumentData,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.accentColor,
  });

  Color get _chipBg    => selected ? accentColor : Colors.white;
  Color get _textColor => selected ? Colors.white : accentColor;
  Color get _badgeBg   => selected
      ? Colors.white.withOpacity(0.25)
      : accentColor.withOpacity(0.12);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _chipBg,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: accentColor.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? accentColor.withOpacity(0.35)
                  : Colors.black.withOpacity(0.06),
              blurRadius: selected ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textColor)),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: _badgeBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(count.toString(),
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _textColor)),
            ),
          ],
        ),
      ),
    );
  }
}
