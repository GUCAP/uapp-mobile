import 'package:flutter/material.dart';

class Course {
  final String id;
  final String title;
  final String university;
  final String location;
  final String code;
  final List<String> intakes;   // e.g. ['Jan 2026', 'Sep 2026']
  final bool scholarshipAvailable;
  final bool loanAvailable;
  final String duration;
  final String level;
  final String fieldId;
  final Color universityColor;

  const Course({
    required this.id,
    required this.title,
    required this.university,
    required this.location,
    required this.code,
    required this.intakes,
    this.scholarshipAvailable = false,
    this.loanAvailable = false,
    required this.duration,
    required this.level,
    required this.fieldId,
    required this.universityColor,
  });
}

class StudyField {
  final String id;
  final String label;
  final IconData icon;

  const StudyField({required this.id, required this.label, required this.icon});
}

const kStudyFields = [
  StudyField(id: 'all',         label: 'All',                    icon: Icons.apps_rounded),
  StudyField(id: 'medical',     label: 'Medical',                icon: Icons.medical_services_rounded),
  StudyField(id: 'arts',        label: 'Arts',                   icon: Icons.palette_rounded),
  StudyField(id: 'engineering', label: 'Engineering & Tech',     icon: Icons.engineering_rounded),
  StudyField(id: 'business',    label: 'Business',               icon: Icons.business_center_rounded),
  StudyField(id: 'law',         label: 'Law',                    icon: Icons.gavel_rounded),
  StudyField(id: 'computing',   label: 'Computing',              icon: Icons.computer_rounded),
  StudyField(id: 'science',     label: 'Science',                icon: Icons.science_rounded),
];

final kCourses = [
  const Course(
    id: 'c1',
    title: 'BSc (Hons) Business, Hospitality and Events Management',
    university: 'Anglia Ruskin University',
    location: 'London',
    code: 'ARU',
    intakes: ['Jan 2026', 'Mar 2026', 'Aug 2026'],
    scholarshipAvailable: true,
    loanAvailable: true,
    duration: '3 Years',
    level: 'Undergraduate',
    fieldId: 'business',
    universityColor: Color(0xFF0A6E6F),
  ),
  const Course(
    id: 'c2',
    title: 'BSc (Hons) Computing and Information Technology',
    university: 'University of Hertfordshire',
    location: 'Hatfield',
    code: 'UH',
    intakes: ['Jan 2026', 'Sep 2026'],
    scholarshipAvailable: true,
    loanAvailable: true,
    duration: '3 Years',
    level: 'Undergraduate',
    fieldId: 'computing',
    universityColor: Color(0xFF7C3AED),
  ),
  const Course(
    id: 'c3',
    title: 'MBA Business Administration (Global)',
    university: 'University of East London',
    location: 'London',
    code: 'UEL',
    intakes: ['Jan 2026', 'May 2026', 'Sep 2026'],
    scholarshipAvailable: false,
    loanAvailable: true,
    duration: '1 Year',
    level: 'Postgraduate',
    fieldId: 'business',
    universityColor: Color(0xFF0EA5E9),
  ),
  const Course(
    id: 'c4',
    title: 'BSc (Hons) Nursing (Adult)',
    university: 'Middlesex University',
    location: 'London',
    code: 'MDX',
    intakes: ['Sep 2026'],
    scholarshipAvailable: true,
    loanAvailable: true,
    duration: '3 Years',
    level: 'Undergraduate',
    fieldId: 'medical',
    universityColor: Color(0xFFDC2626),
  ),
  const Course(
    id: 'c5',
    title: 'LLB (Hons) Law',
    university: 'University of Westminster',
    location: 'London',
    code: 'UOW',
    intakes: ['Sep 2026'],
    scholarshipAvailable: false,
    loanAvailable: true,
    duration: '3 Years',
    level: 'Undergraduate',
    fieldId: 'law',
    universityColor: Color(0xFFD97706),
  ),
  const Course(
    id: 'c6',
    title: 'MSc Artificial Intelligence and Machine Learning',
    university: 'Coventry University',
    location: 'London',
    code: 'CU',
    intakes: ['Jan 2026', 'Sep 2026'],
    scholarshipAvailable: true,
    loanAvailable: true,
    duration: '1.5 Years',
    level: 'Postgraduate',
    fieldId: 'computing',
    universityColor: Color(0xFF16A34A),
  ),
  const Course(
    id: 'c7',
    title: 'BA (Hons) Fashion Design and Technology',
    university: 'London Metropolitan University',
    location: 'London',
    code: 'LMU',
    intakes: ['Sep 2026'],
    scholarshipAvailable: false,
    loanAvailable: true,
    duration: '3 Years',
    level: 'Undergraduate',
    fieldId: 'arts',
    universityColor: Color(0xFFEC4899),
  ),
  const Course(
    id: 'c8',
    title: 'BEng (Hons) Civil Engineering',
    university: 'Kingston University',
    location: 'London',
    code: 'KU',
    intakes: ['Jan 2026', 'Sep 2026'],
    scholarshipAvailable: true,
    loanAvailable: true,
    duration: '3 Years',
    level: 'Undergraduate',
    fieldId: 'engineering',
    universityColor: Color(0xFF0891B2),
  ),
];

class StudentApplication {
  final String id;
  final String appNumber;
  final String courseId;
  final String status;
  final Color statusColor;
  final DateTime appliedAt;
  final String? consultantId;

  const StudentApplication({
    required this.id,
    required this.appNumber,
    required this.courseId,
    required this.status,
    required this.statusColor,
    required this.appliedAt,
    this.consultantId,
  });
}

final kStudentApplications = [
  StudentApplication(
    id: 'a1', appNumber: 'APP117452',
    courseId: 'c1', status: 'Conditional Offer',
    statusColor: Color(0xFF16A34A),
    appliedAt: DateTime(2026, 3, 10),
    consultantId: 'u-tousif',
  ),
  StudentApplication(
    id: 'a2', appNumber: 'APP117453',
    courseId: 'c3', status: 'Documents Required',
    statusColor: Color(0xFFF59E0B),
    appliedAt: DateTime(2026, 4, 2),
    consultantId: 'u-tousif',
  ),
  StudentApplication(
    id: 'a3', appNumber: 'APP117454',
    courseId: 'c6', status: 'Under Review',
    statusColor: Color(0xFF0EA5E9),
    appliedAt: DateTime(2026, 5, 15),
    consultantId: 'u-riad',
  ),
];
