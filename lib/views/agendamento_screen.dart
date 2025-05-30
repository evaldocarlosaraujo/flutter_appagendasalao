import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AgendamentoScreen extends StatefulWidget {
  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  String? servicoSelecionadoId;
  String? profissionalSelecionadoId;
  String? profissionalNome;
  String? servicoNome;
  DateTime? dataSelecionada;
  TimeOfDay? horarioSelecionado;

  void salvarAgendamento() async {
    if (servicoSelecionadoId == null ||
        profissionalSelecionadoId == null ||
        dataSelecionada == null ||
        horarioSelecionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Preencha todos os campos.")));
      return;
    }

    DateTime dataHora = DateTime(
      dataSelecionada!.year,
      dataSelecionada!.month,
      dataSelecionada!.day,
      horarioSelecionado!.hour,
      horarioSelecionado!.minute,
    );

    final id = Uuid().v4();
    final usuarioId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('agendamentos').doc(id).set({
      'id': id,
      'usuarioId': usuarioId,
      'profissionalId': profissionalSelecionadoId,
      'profissionalNome': profissionalNome,
      'servicoId': servicoSelecionadoId,
      'servicoNome': servicoNome,
      'dataHora': dataHora.toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Agendamento realizado com sucesso!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agendar Horário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Lista de Serviços
            Text('Serviço:', style: TextStyle(fontWeight: FontWeight.bold)),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('servicos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final servicos = snapshot.data!.docs;
                return DropdownButton<String>(
                  value: servicoSelecionadoId,
                  hint: Text('Selecione um serviço'),
                  isExpanded: true,
                  items:
                      servicos.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc['id'],
                          child: Text(doc['nome']),
                          onTap: () {
                            setState(() {
                              servicoNome = doc['nome'];
                            });
                          },
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() => servicoSelecionadoId = value);
                  },
                );
              },
            ),
            SizedBox(height: 20),

            // Lista de Profissionais
            Text(
              'Profissional:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('profissionais')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final profissionais = snapshot.data!.docs;
                return DropdownButton<String>(
                  value: profissionalSelecionadoId,
                  hint: Text('Selecione um profissional'),
                  isExpanded: true,
                  items:
                      profissionais.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc['id'],
                          child: Text(doc['nome']),
                          onTap: () {
                            setState(() {
                              profissionalNome = doc['nome'];
                            });
                          },
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() => profissionalSelecionadoId = value);
                  },
                );
              },
            ),
            SizedBox(height: 20),

            // Selecionar Data
            Text('Data:', style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                DateTime? data = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 30)),
                );
                if (data != null) setState(() => dataSelecionada = data);
              },
              child: Text(
                dataSelecionada == null
                    ? 'Escolher Data'
                    : '${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}',
              ),
            ),
            SizedBox(height: 20),

            // Selecionar Horário
            Text('Horário:', style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? hora = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (hora != null) setState(() => horarioSelecionado = hora);
              },
              child: Text(
                horarioSelecionado == null
                    ? 'Escolher Horário'
                    : '${horarioSelecionado!.hour}:${horarioSelecionado!.minute.toString().padLeft(2, '0')}',
              ),
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: salvarAgendamento,
              child: Text('Confirmar Agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
