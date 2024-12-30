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
                child: Text(contract.expertName[0]),
                backgroundColor: Colors.blue,
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

  ContractDetailScreen({required this.contract});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contract.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contract.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Expert: ${contract.expertName}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Amount: \$${contract.amount}',
                style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 8),
            Text('Status: ${contract.status}',
                style: TextStyle(
                    fontSize: 18,
                    color: contract.status == 'Active'
                        ? Colors.orange
                        : Colors.grey)),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text('Description:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(contract.description, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// Contract Model
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
