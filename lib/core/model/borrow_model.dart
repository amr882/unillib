import 'package:cloud_firestore/cloud_firestore.dart';

enum BorrowStatus { pendingPickup, activeBorrow, returned, cancelled }

class BorrowRecord {
  final String borrowId;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCoverUrl;
  final BorrowStatus status;
  final DateTime createdAt;
  final DateTime pickupDeadline;
  final DateTime? pickupConfirmedAt;
  final DateTime? returnConfirmedAt;

  BorrowRecord({
    required this.borrowId,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCoverUrl,
    required this.status,
    required this.createdAt,
    required this.pickupDeadline,
    this.pickupConfirmedAt,
    this.returnConfirmedAt,
  });

  factory BorrowRecord.fromMap(Map<String, dynamic> map) {
    BorrowStatus parsedStatus = BorrowStatus.pendingPickup;
    final statusStr = map['status'] as String?;
    if (statusStr == 'active_borrow') {
      parsedStatus = BorrowStatus.activeBorrow;
    } else if (statusStr == 'returned') {
      parsedStatus = BorrowStatus.returned;
    } else if (statusStr == 'cancelled') {
      parsedStatus = BorrowStatus.cancelled;
    }

    return BorrowRecord(
      borrowId: map['borrowId'] ?? '',
      userId: map['userId'] ?? '',
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      bookAuthor: map['bookAuthor'] ?? '',
      bookCoverUrl: map['bookCoverUrl'] ?? '',
      status: parsedStatus,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickupDeadline:
          (map['pickupDeadline'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(hours: 48)),
      pickupConfirmedAt: (map['pickupConfirmedAt'] as Timestamp?)?.toDate(),
      returnConfirmedAt: (map['returnConfirmedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    String statusStr = 'pending_pickup';
    if (status == BorrowStatus.activeBorrow) {
      statusStr = 'active_borrow';
    } else if (status == BorrowStatus.returned) {
      statusStr = 'returned';
    } else if (status == BorrowStatus.cancelled) {
      statusStr = 'cancelled';
    }

    return {
      'borrowId': borrowId,
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverUrl': bookCoverUrl,
      'status': statusStr,
      'createdAt': Timestamp.fromDate(createdAt),
      'pickupDeadline': Timestamp.fromDate(pickupDeadline),
      'pickupConfirmedAt': pickupConfirmedAt != null
          ? Timestamp.fromDate(pickupConfirmedAt!)
          : null,
      'returnConfirmedAt': returnConfirmedAt != null
          ? Timestamp.fromDate(returnConfirmedAt!)
          : null,
    };
  }

  bool get canUserCancel => status == BorrowStatus.pendingPickup;

  Duration get pickupTimeRemaining => pickupDeadline.difference(DateTime.now());

  Duration? get returnTimeRemaining {
    if (status != BorrowStatus.activeBorrow || pickupConfirmedAt == null) {
      return null;
    }
    final deadline = pickupConfirmedAt!.add(const Duration(days: 14));
    return deadline.difference(DateTime.now());
  }
}
