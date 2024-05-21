// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Therapist _$TherapistFromJson(Map<String, dynamic> json) => Therapist(
      name: json['Full name'] as String? ?? '',
      jobTitle: json['Job Title'] as String? ?? '',
      hospitalClinic: json['Hospital/Clinic'] as String? ?? '',
      email: json['Email'] as String? ?? '',
      password: json['Password'] as String? ?? '',
    );

Map<String, dynamic> _$TherapistToJson(Therapist instance) => <String, dynamic>{
      'Full name': instance.name,
      'Job Title': instance.jobTitle,
      'Hospital/Clinic': instance.hospitalClinic,
      'Email': instance.email,
      'Password': instance.password,
    };

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
      name: json['Patient Name'] as String? ?? '',
      phone: json['Phone Number'] as String? ?? '',
      email: json['Email'] as String? ?? '',
      patientNum: json['Patient Number'] as String? ?? '',
      gender: json['Gender'] as String? ?? '',
      id: json['TheraID'] as String? ?? '',
      performance: json['overall_performance'] as int,
    );

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
      'Patient Name': instance.name,
      'Phone Number': instance.phone,
      'Email': instance.email,
      'Patient Number': instance.patientNum,
      'Gender': instance.gender,
      'TheraID': instance.id,
      'overall_performance': instance.performance,
    };

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
      id: json['ID'] as String,
      Content: json['Content'] as String,
      autherID: json['AutherID'] as String,
      KeyWords: json['KeyWords'] as String,
      publishTime: json['PublishTime'],
      Title: json['Title'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      pdfUrl: json['pdfUrl'] != null ? json['pdfUrl'] as String : '',
    );

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'ID': instance.id,
      'Content': instance.Content,
      'AutherID': instance.autherID,
      'KeyWords': instance.KeyWords,
      'PublishTime': instance.publishTime,
      'Title': instance.Title,
      'name': instance.name,
      'image': instance.image,
       'pdfUrl' : instance.pdfUrl,
    };

FAQss _$FAQssFromJson(Map<String, dynamic> json) => FAQss(
      faqId: json['FAQ ID'] as String,
      question: json['Question'] as String,
      answer: json['Answer'] as String,
    );

Map<String, dynamic> _$FAQssToJson(FAQss instance) => <String, dynamic>{
      'FAQ ID': instance.faqId,
      'Question': instance.question,
      'Answer': instance.answer,
    };

Quizz _$QuizzFromJson(Map<String, dynamic> json) => Quizz(
      questionId: json['Question ID'] as String,
      question: json['Question'] as String,
      correctAns: json['Correct Answer'] as String,
      options:
          (json['Options'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$QuizzToJson(Quizz instance) => <String, dynamic>{
      'Question ID': instance.questionId,
      'Question': instance.question,
      'Options': instance.options,
      'Correct Answer': instance.correctAns,
    };

Program _$ProgramFromJson(Map<String, dynamic> json) => Program(
      pid: json['Program ID'] as String,
      numofAct: json['NumberOfActivities'] as int,
      startDate: json['Start Date'],
      endDate: json['End Date'],
      patientNum: json['Patient Number'],
      activities:
          Program._activityListFromJson(json['Activities'] as List<dynamic>),
    );

Map<String, dynamic> _$ProgramToJson(Program instance) => <String, dynamic>{
      'Program ID': instance.pid,
      'NumberOfActivities': instance.numofAct,
      'Start Date': instance.startDate,
      'End Date': instance.endDate,
      'Patient Number': instance.patientNum,
      'Activities': instance.activities,
    };

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      activityName: json['Activity Name'] as String,
      frequency: json['Frequency'] as int,
      TimesPerWeek: json['TimesPerWeek'] as int,
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'Activity Name': instance.activityName,
      'Frequency': instance.frequency,
      'TimesPerWeek' : instance.TimesPerWeek,
    };


Report _$ReportFromJson(Map<String, dynamic> json) {
  return Report(
    Rid: json['Report ID'] as String,
    PatientNumber: json['Patient Number'] as String,
    ProgramID: json['Program ID'] as String,
    OverallPerformance: json['Overall Performance'],
    NumberOfWeeks: json['Number of weeks'] as int,
     NumberOfMonths: json['Number of months'] as int,
    NumberOfIterations: json['Number of iterations'],
    NumberOfActivities: json['Number of activities'],
    weeksPercentages: (json['Weeks Percentages'] as List<dynamic>)
        .map((e) => WeeksPercentages.fromJson(e as Map<String, dynamic>))
        .toList(),
    monthsPercentages: (json['Months Percentages'] as List<dynamic>)
        .map((e) => MonthsPercentages.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'Report ID': instance.Rid,
      'Patient Number': instance.PatientNumber,
      'Program ID': instance.ProgramID,
      'Overall Performance': instance.OverallPerformance,
      'Number of weeks': instance.NumberOfWeeks,
      'Number of months':instance.NumberOfMonths,
      'Number of iterations': instance.NumberOfIterations,
      'Number of activities': instance.NumberOfActivities,
      'Weeks Percentages':
          instance.weeksPercentages.map((e) => e.toJson()).toList(),
      'Months Percentages':
          instance.monthsPercentages.map((e) => e.toJson()).toList(),
    };

WeeksPercentages _$WeeksPercentagesFromJson(Map<String, dynamic> json) {
  return WeeksPercentages(
    R_activity: (json['Activities'] as List<dynamic>)
        .map((e) => R_Activity.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}


Map<String, dynamic> _$WeeksPercentagesToJson(WeeksPercentages instance) =>
    <String, dynamic>{
      'Activities': instance.R_activity.map((e) => e.toJson()).toList(),
    };

R_Activity _$R_ActivityFromJson(Map<String, dynamic> json) {
  return R_Activity(
    activityName: json['Activity Name'] as String,
    percentage: (json['Percentage'] as num).toDouble(),
  );
}

Map<String, dynamic> _$R_ActivityToJson(R_Activity instance) =>
    <String, dynamic>{
      'activity Name': instance.activityName,
      'percentage': instance.percentage,
    };

MonthsPercentages _$MonthsPercentagesFromJson(Map<String, dynamic> json) {
  return MonthsPercentages(
    R_activity: (json['Activities'] as List<dynamic>)
        .map((e) => R_Activity.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$MonthsPercentagesToJson(MonthsPercentages instance) =>
    <String,dynamic>{};