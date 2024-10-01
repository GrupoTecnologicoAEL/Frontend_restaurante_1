import 'package:flutter/material.dart';

class OrderInformationScreen extends StatelessWidget {
  final double totalPrice; // El total a pagar

  OrderInformationScreen({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Información de la Orden',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de la orden:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20),
            // Mostrar la información de pago y orden
            Text(
              'Total a pagar: \Q${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            ),
            SizedBox(height: 30),
            // Puedes agregar campos para que el usuario ingrese dirección, método de pago, etc.
            ElevatedButton(
              onPressed: () {
                // Lógica para confirmar la orden
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Center(
                child: Text(
                  'Confirmar Orden',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
