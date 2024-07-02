import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";

import "../methods/common_methods.dart";
import "../pages/home_page.dart";
import "../widgets/loading_dialog.dart";
import "login_screen.dart";

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  // Controlers
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();

  // Verificar Internet
  checkIfNetworkIsAvailable()
  {
    //cMethods.checkConnectivity(context);
    signUpFormValidation();
  }

  signUpFormValidation() {
    if(userNameTextEditingController.text.trim().length < 3)
    {
      cMethods.displaySnackBar("O seu username deve ser maior que 3 caracteres.", context);
    }
    else if(userPhoneTextEditingController.text.trim().length < 7)
    {
      cMethods.displaySnackBar("Insira um número de telefone válido.", context);
    }
    else if(!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Insira um email válido.", context);
    }
    else if(passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("Sua senha deve ter ao menos 6 caracteres.", context);
    }
    else{
      registerNewUser();
    }
  }

  registerNewUser() async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registrando sua conta..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg)
        {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);

    Map userDataMap =
    {
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };

    usersRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              const Text(
                "",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Logo
              Image.asset(
                "assets/images/logo.jpeg"
              ),

              // Introdução => Crie Conta
              const Text(
                "Crie uma conta",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Campos de Texto + SignUp
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    // Campo de Texto => UserName
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      )
                    ),

                    const SizedBox(height: 18,),

                    // Campo de Texto => Telefone
                    TextField(
                        controller: userPhoneTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "Telefone",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        )
                    ),

                    const SizedBox(height: 18,),

                    // Campo de Texto => Email
                    TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "User Email",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        )
                    ),

                    const SizedBox(height: 18,),

                    // Campo de Texto => Senha
                    TextField(
                        controller: passwordTextEditingController,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "User Password",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        )
                    ),

                    const SizedBox(height: 18,),

                    // Botão => SignUp
                    ElevatedButton(

                        onPressed: (){
                          checkIfNetworkIsAvailable();
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                        ),

                        child: const Text(
                          "Registrar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),

              ],
          ),
        ),

              // Botão Conta Existente
              TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
                child: const Text(
                  "Já possui uma conta? Clique aqui!",
                  style: TextStyle(
                    color: Colors.grey,
                  )
                )
              )

            ],
          )
        ),
      ),
    );
  }
}
