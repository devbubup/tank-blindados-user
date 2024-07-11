import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sobre Nós",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white, // Define o fundo branco
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/logo.jpeg",
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Bem-vindo à Nossa Empresa",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Sobre Nós",
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Somos uma empresa especializada em oferecer diferentes serviços de carros blindados no Rio de Janeiro. Nossa missão é garantir exclusividade, conforto e segurança para nossos usuários. Com uma frota de veículos de alta qualidade e motoristas treinados, estamos comprometidos em proporcionar a melhor experiência de transporte para nossos clientes.",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Nossos Serviços",
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "• Transporte Executivo: Para viagens de negócios com total conforto e segurança.\n\n"
                      "• Transporte Pessoal: Serviço personalizado para suas necessidades diárias.\n\n"
                      "• Transporte de Eventos: Para casamentos, festas e eventos corporativos.\n\n"
                      "• Transporte Turístico: Para turistas que desejam explorar o Rio de Janeiro com segurança.",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Opções de Serviço do App",
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "1. Pedida Instantânea: Peça no momento que quiser e o motorista mais próximo te levará ao seu destino.\n\n"
                      "2. Agendamento de Corrida: Tem uma corrida importante que já quer deixar marcada? Marque antes com este serviço.",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Contato",
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Em caso de dúvidas, sugestões ou relatos de mau uso, entre em contato conosco pelo email: contato@nossaempresa.com",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
