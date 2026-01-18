import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/symptom/symptom_intensity_slider.dart';

/// Registerkarte für das Erfassen eines Symptomtagebuch‑Eintrags.
///
/// Diese StatefulWidget zeigt Eingabefelder und Schieberegler an, über die der
/// Nutzer seine Symptome, Stimmung und mögliche Auslöser erfassen kann.
/// Beim Speichern wird die gesammelte Datenstruktur über den [onSave]‑Callback
/// an den übergeordneten Widget zurückgegeben.
class SymptomEntryTab extends StatefulWidget {
  /// Callback, der aufgerufen wird, wenn der Nutzer den Eintrag speichert.
  ///
  /// Erwartet eine Map mit den Schlüsseln `date`, `time`, `symptoms`, `trigger`
  /// und `notes`.
  final Function(Map<String, dynamic>) onSave;

  /// Erstellt eine neue [SymptomEntryTab].
  const SymptomEntryTab({super.key, required this.onSave});

  @override
  State<SymptomEntryTab> createState() => _SymptomEntryTabState();
}

class _SymptomEntryTabState extends State<SymptomEntryTab> {
  /// Aktuelle Stimmung des Nutzers (`good`, `medium` oder `bad`).
  String? _mood;

  /// Intensität des Symptoms „Atemnot“ (0–3).
  int _atemnot = 0;

  /// Intensität des Symptoms „Husten“ (0–3).
  int _husten = 0;

  /// Intensität des Symptoms „Pfeifende Atmung“ (0–3).
  int _pfeifend = 0;

  /// Gibt an, ob nächtliche Beschwerden vorhanden sind.
  bool _nightSymptoms = false;

  /// Gibt an, ob ein Notfallspray verwendet wurde.
  bool _emergencySpray = false;

  /// Mögliche Auslöser und ihr aktueller Auswahlzustand.
  final Map<String, bool> _triggers = {
    'Sport': false,
    'Kälte': false,
    'Infekt': false,
    'Allergene': false,
    'Stress': false,
  };

  /// Textcontroller für zusätzliche Notizen.
  final TextEditingController _notesController = TextEditingController();

  /// Liste der zusätzlich erfassten Symptome.
  ///
  /// Jedes Listenelement ist eine Map mit `name` und `intensity`.
  final List<Map<String, dynamic>> _additionalSymptoms = [];

  /// Textcontroller für die Eingabe eines neuen Symptoms.
  final TextEditingController _newSymptomCtrl = TextEditingController();

  /// Häufigkeit eines neu eingegebenen Symptoms (`Selten`, `Gelegentlich`, `Häufig`).
  String _newSymptomFrequency = 'Gelegentlich';

  /// Gibt ein formatiertes Titel‑Widget zurück.
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
      ),
    );
  }

  /// Erstellt eine Schaltfläche für die Stimmungswahl.
  ///
  /// [value] identifiziert die gewählte Stimmung, [emoji] und [label] werden
  /// in der Schaltfläche angezeigt. Bei Auswahl wird [_mood] entsprechend
  /// aktualisiert und das Aussehen angepasst.
  Widget _moodButton(String value, String emoji, String label) {
    final selected = _mood == value;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => _mood = value),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? AppColors.primaryGreen : Colors.white,
          side: BorderSide(color: AppColors.primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Erstellt einen Container mit Ja/Nein‑Toggle.
  ///
  /// [label] beschreibt die Frage, [value] gibt den aktuellen Zustand an.
  /// Beim Tippen auf „Ja“ oder „Nein“ werden die entsprechenden Callbacks
  /// [onYes] bzw. [onNo] ausgeführt. Optional kann ein [icon] vorangestellt werden.
  Widget _yesNoToggle({
    required String label,
    required bool value,
    required VoidCallback onYes,
    required VoidCallback onNo,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: AppColors.primaryGreen, size: 18),
          if (icon != null) const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Row(
            children: [
              _smallToggle('Ja', value, onYes),
              const SizedBox(width: 6),
              _smallToggle('Nein', !value, onNo),
            ],
          ),
        ],
      ),
    );
  }

  /// Erstellt eine kleine Umschaltschaltfläche für [label].
  ///
  /// [active] bestimmt das Aussehen, [onTap] wird beim Tippen ausgelöst.
  Widget _smallToggle(String label, bool active, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? AppColors.primaryGreen : Colors.white,
        foregroundColor: active ? Colors.white : AppColors.primaryGreen,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label),
    );
  }

  /// Sammelt alle Eingabedaten und übergibt sie an den [onSave]‑Callback.
  ///
  /// Erstellt eine Map mit Datum, Uhrzeit, Kernsymptomen, ausgewählten
  /// Auslösern und Notizen. Setzt die Eingabefelder für zusätzliche
  /// Symptome und Notizen zurück und zeigt eine Snackbar als Bestätigung an.
  void _saveEntry() {
    widget.onSave({
      'date': DateFormat('dd.MM.yyyy').format(DateTime.now()),
      'time': DateFormat('HH:mm').format(DateTime.now()),
      'symptoms': {
        'Atemnot': _atemnot,
        'Husten': _husten,
        'Pfeifende Atmung': _pfeifend,
        for (var s in _additionalSymptoms) s['name']: s['intensity'],
      },
      'trigger':
          _triggers.entries.where((e) => e.value).map((e) => e.key).join(', '),
      'notes': _notesController.text,
    });

    _additionalSymptoms.clear();
    _notesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Eintrag gespeichert ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptomtagebuch',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            backgroundColor: AppColors.veryLightGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wie fühlst du dich heute?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _moodButton('good', '😌', 'Gut'),
                    const SizedBox(width: 8),
                    _moodButton('medium', '😐', 'Mittel'),
                    const SizedBox(width: 8),
                    _moodButton('bad', '😣', 'Schlecht'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Kernsymptome'),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                SymptomIntensitySlider(
                  symptomName: 'Atemnot',
                  intensity: _atemnot,
                  icon: Icons.air,
                  onChanged: (v) => setState(() => _atemnot = v),
                ),
                const SizedBox(height: 16),
                SymptomIntensitySlider(
                  symptomName: 'Husten',
                  intensity: _husten,
                  icon: Icons.sick,
                  onChanged: (v) => setState(() => _husten = v),
                ),
                const SizedBox(height: 16),
                SymptomIntensitySlider(
                  symptomName: 'Pfeifende Atmung',
                  intensity: _pfeifend,
                  icon: Icons.graphic_eq,
                  onChanged: (v) => setState(() => _pfeifend = v),
                ),
                const SizedBox(height: 16),
                _yesNoToggle(
                  label: 'Nächtliche Beschwerden',
                  value: _nightSymptoms,
                  icon: Icons.nightlight_round,
                  onYes: () => setState(() => _nightSymptoms = true),
                  onNo: () => setState(() => _nightSymptoms = false),
                ),
                const SizedBox(height: 12),
                _yesNoToggle(
                  label: 'Notfallspray gebraucht?',
                  value: _emergencySpray,
                  icon: Icons.local_fire_department,
                  onYes: () => setState(() => _emergencySpray = true),
                  onNo: () => setState(() => _emergencySpray = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Mögliche Auslöser heute'),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _triggers.keys.map((t) {
                    return ChoiceChip(
                      label: Text(t),
                      selected: _triggers[t]!,
                      selectedColor:
                          AppColors.primaryGreen.withValues(alpha: 0.2),
                      onSelected: (v) => setState(() => _triggers[t] = v),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        "z. B. 'Heute viel gelaufen', 'Wetter sehr kalt' …",
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Weitere Symptome hinzufügen'),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                TextField(
                  controller: _newSymptomCtrl,
                  decoration: const InputDecoration(
                    hintText: 'z. B. Müdigkeit, Kopfschmerzen, Engegefühl …',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Selten', 'Gelegentlich', 'Häufig']
                      .map((f) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton(
                                onPressed: () =>
                                    setState(() => _newSymptomFrequency = f),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _newSymptomFrequency == f
                                      ? AppColors.primaryGreen
                                      : Colors.white,
                                  foregroundColor: _newSymptomFrequency == f
                                      ? Colors.white
                                      : AppColors.primaryGreen,
                                  elevation: 0,
                                ),
                                child: Text(
                                  f,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_newSymptomCtrl.text.isEmpty) return;
                    setState(() {
                      _additionalSymptoms.add({
                        'name': _newSymptomCtrl.text,
                        'intensity': _newSymptomFrequency == 'Selten'
                            ? 1
                            : _newSymptomFrequency == 'Gelegentlich'
                                ? 2
                                : 3,
                      });
                      _newSymptomCtrl.clear();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Hinzufügen'),
                ),
                const SizedBox(height: 8),
                _additionalSymptomsList(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Eintrag speichern'),
            ),
          ),
        ],
      ),
    );
  }

  /// Gibt eine Liste der hinzugefügten weiteren Symptome zurück.
  ///
  /// Wenn keine zusätzlichen Symptome vorhanden sind, wird eine leere
  /// Platzhalterbox (`SizedBox.shrink`) zurückgegeben. Andernfalls wird eine
  /// Spalte mit Zeilen für jedes Symptom erzeugt, einschließlich eines
  /// Entfernen‑Buttons.
  Widget _additionalSymptomsList() {
    if (_additionalSymptoms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: _additionalSymptoms.map((s) {
        final frequency = s['intensity'] == 1
            ? 'Selten'
            : s['intensity'] == 2
                ? 'Gelegentlich'
                : 'Häufig';

        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${s['name']} • $frequency',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  setState(() {
                    _additionalSymptoms.remove(s);
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
