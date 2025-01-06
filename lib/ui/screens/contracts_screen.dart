import 'package:flutter/material.dart';

class ContractsScreen extends StatelessWidget {
  final List<Contract> contracts = List.generate(
    10,
    (index) => Contract(
      title: 'Contract ${index + 1}',
      expertName: 'Expert ${index + 1}',
      amount: (index + 1) * 100.0,
      status: index % 2 == 0 ? 'Active' : 'Completed',
      description:
          'This is a detailed description of Contract ${index + 1}. It includes the scope of work, deliverables, and payment details agreed upon by both parties.',
    ),
  );

  ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contracts'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(contract.expertName[0]),
              ),
              title: Text(
                contract.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expert: ${contract.expertName}',
                      style: TextStyle(fontSize: 14)),
                  Text('Amount: \$${contract.amount}',
                      style: TextStyle(color: Colors.green, fontSize: 14)),
                  Text('Status: ${contract.status}',
                      style: TextStyle(
                          color: contract.status == 'Active'
                              ? Colors.orange
                              : Colors.grey,
                          fontSize: 14)),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContractDetailScreen(contract: contract),
                    ),
                  );
                },
                child: Text('Details'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ContractDetailScreen extends StatelessWidget {
  final Contract contract;

  const ContractDetailScreen({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approved Contract Details'),
        backgroundColor: Colors.blue,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Center(
                child: Text(
                  contract.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),

              // Expert Section
              Row(
                children: [
                  Icon(Icons.person, size: 28, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    "Expert: ${contract.expertName}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Amount Section
              Row(
                children: [
                  Icon(Icons.currency_bitcoin, size: 28, color: Colors.orange),
                  SizedBox(width: 10),
                  Text(
                    "Amount: ${contract.amount.toStringAsFixed(4)} BTC",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Status Section
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 28,
                    color: contract.status == 'Active' ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Status: ${contract.status}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: contract.status == 'Active' ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Divider
              Divider(thickness: 1, color: Colors.grey[300]),
              SizedBox(height: 16),

              // Description Section
              Text(
                "Description:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                contract.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.6,
                ),
              ),
              SizedBox(height: 24),

              // Additional Information Section
              Text(
                "Additional Details:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "The contract has been approved by the client. Payment will be released upon successful completion of the agreed milestones. For any disputes, contact support.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
              SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.chat, color: Colors.white),
                    label: Text("Contact Expert", style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.report_problem, color: Colors.white),
                    label: Text("Report Issue", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Contact Support Section
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Need Help? Contact Support",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Contract {
  final String title;
  final String expertName;
  final double amount;
  final String status;
  final String description;

  Contract({
    required this.title,
    required this.expertName,
    required this.amount,
    required this.status,
    required this.description,
  });
}
