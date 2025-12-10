class TicketUser {
  final String id;
  final String username;

  TicketUser({required this.id, required this.username});

  factory TicketUser.fromJson(Map<String, dynamic> json) {
    return TicketUser(
      id: json['_id'] ?? json['id'],
      username: json['username'],
    );
  }
}

class Ticket {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String branch;
  final String status;
  final String createdBy; // Keeping as String (username) for now as previously implemented logic seemed to flatten it
  final TicketUser? assignedTo;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.branch,
    required this.status,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? json['_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      branch: json['branch'],
      status: json['status'],
      createdBy: json['createdBy'] is Map ? json['createdBy']['username'] : json['createdBy'], 
      assignedTo: json['assignedTo'] != null && json['assignedTo'] is Map 
          ? TicketUser.fromJson(json['assignedTo']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
