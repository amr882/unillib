import 'package:cloud_firestore/cloud_firestore.dart';

enum BorrowStatus {
  pendingPickup,   // User requested — awaiting admin scan #1
  activeBorrow,    // Admin confirmed pickup — 14-day clock running
  returned,        // Admin confirmed return — record archived
}

extension BorrowStatusExt on BorrowStatus {
  String get firestoreValue {
    switch (this) {
      case BorrowStatus.pendingPickup:
        return 'pending_pickup';
      case BorrowStatus.activeBorrow:
        return 'active_borrow';
      case BorrowStatus.returned:
        return 'returned';
    }
  }

  static BorrowStatus fromString(String? value) {
    switch (value) {
      case 'active_borrow':
        return BorrowStatus.activeBorrow;
      case 'returned':
        return BorrowStatus.returned;
      default:
        return BorrowStatus.pendingPickup;
    }
  }
}

class BorrowRecord {
  final String borrowId;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCoverUrl;
  final BorrowStatus status;

  /// When the user initiated the borrow request
  final DateTime createdAt;

  /// 48 hours after createdAt — auto-expiry window ends here
  final DateTime pickupDeadline;

  /// Set when admin scans QR #1 (confirms pickup)
  final DateTime? pickupConfirmedAt;

  /// pickupConfirmedAt + 14 days — when book must be returned
  final DateTime? returnDeadline;

  /// Set when admin scans QR #2 (confirms return)
  final DateTime? returnConfirmedAt;

  const BorrowRecord({
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
    this.returnDeadline,
    this.returnConfirmedAt,
  });

  /// Whether the user can still cancel this borrow (only while pending_pickup)
  bool get canUserCancel => status == BorrowStatus.pendingPickup;

  /// Remaining time until pickup deadline (only relevant for pending_pickup)
  Duration get pickupTimeRemaining {
    final remaining = pickupDeadline.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Remaining time until return deadline (only relevant for active_borrow)
  Duration? get returnTimeRemaining {
    if (returnDeadline == null) return null;
    final remaining = returnDeadline!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory BorrowRecord.fromMap(Map<String, dynamic> map) {
    return BorrowRecord(
      borrowId: map['borrowId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      bookId: map['bookId'] as String? ?? '',
      bookTitle: map['bookTitle'] as String? ?? 'Unknown Book',
      bookAuthor: map['bookAuthor'] as String? ?? 'Unknown Author',
      bookCoverUrl: map['bookCoverUrl'] as String? ?? '',
      status: BorrowStatusExt.fromString(map['status'] as String?),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickupDeadline:
          (map['pickupDeadline'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(hours: 48)),
      pickupConfirmedAt:
          (map['pickupConfirmedAt'] as Timestamp?)?.toDate(),
      returnDeadline: (map['returnDeadline'] as Timestamp?)?.toDate(),
      returnConfirmedAt: (map['returnConfirmedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory BorrowRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return BorrowRecord.fromMap(doc.data() ?? {});
  }

  Map<String, dynamic> toMap() {
    return {
      'borrowId': borrowId,
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverUrl': bookCoverUrl,
      'status': status.firestoreValue,
      'createdAt': Timestamp.fromDate(createdAt),
      'pickupDeadline': Timestamp.fromDate(pickupDeadline),
      if (pickupConfirmedAt != null)
        'pickupConfirmedAt': Timestamp.fromDate(pickupConfirmedAt!),
      if (returnDeadline != null)
        'returnDeadline': Timestamp.fromDate(returnDeadline!),
      if (returnConfirmedAt != null)
        'returnConfirmedAt': Timestamp.fromDate(returnConfirmedAt!),
    };
  }

  BorrowRecord copyWith({
    String? borrowId,
    String? userId,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookCoverUrl,
    BorrowStatus? status,
    DateTime? createdAt,
    DateTime? pickupDeadline,
    DateTime? pickupConfirmedAt,
    DateTime? returnDeadline,
    DateTime? returnConfirmedAt,
  }) {
    return BorrowRecord(
      borrowId: borrowId ?? this.borrowId,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookCoverUrl: bookCoverUrl ?? this.bookCoverUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pickupDeadline: pickupDeadline ?? this.pickupDeadline,
      pickupConfirmedAt: pickupConfirmedAt ?? this.pickupConfirmedAt,
      returnDeadline: returnDeadline ?? this.returnDeadline,
      returnConfirmedAt: returnConfirmedAt ?? this.returnConfirmedAt,
    );
  }

  @override
  String toString() =>
      'BorrowRecord(id: $borrowId, book: $bookTitle, status: ${status.firestoreValue})';
}
