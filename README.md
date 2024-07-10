Tank Blindados Driver App

Este repositório contém o código-fonte do aplicativo Tank Blindados Driver, desenvolvido em Flutter. O aplicativo é uma solução de rideshare para carros blindados no Rio de Janeiro, focado em fornecer um serviço seguro e eficiente para motoristas e passageiros.

Estrutura do Projeto

Abaixo está a estrutura principal das pastas e arquivos do projeto:

Diretórios Principais
lib/

Contém o código Dart principal do aplicativo.
assets/

Contém imagens e outros recursos estáticos usados no aplicativo.
android/

Contém o código específico do Android e arquivos de configuração.
ios/

Contém o código específico do iOS e arquivos de configuração.
Diretórios Dentro de lib/
appInfo/

Contém classes relacionadas ao estado do aplicativo.
authentication/

Contém telas de autenticação, como login e registro.
global/

Contém variáveis globais usadas em todo o aplicativo.
methods/

Contém métodos comuns e serviços utilizados no aplicativo.
models/

Contém modelos de dados usados no aplicativo.
pages/

Contém as principais telas do aplicativo.
widgets/

Contém widgets personalizados usados em várias partes do aplicativo.
Descrição de Cada Arquivo

lib/appInfo/app_info.dart
Contém a classe AppInfo, que gerencia o estado do aplicativo, incluindo as localizações de partida e destino. A classe utiliza o ChangeNotifier para notificar ouvintes sobre mudanças no estado.

lib/authentication/login_screen.dart
Implementa a tela de login do usuário. Permite ao usuário fazer login com email e senha, valida os campos de entrada e integra-se ao Firebase Authentication e Firebase Realtime Database para verificar as informações do usuário.

lib/authentication/signup_screen.dart
Implementa a tela de registro de usuário. Permite ao usuário criar uma nova conta, com validação dos campos de entrada e integração ao Firebase Authentication e Firebase Realtime Database para salvar as informações do usuário.

lib/global/global_var.dart
Contém variáveis globais utilizadas no aplicativo, incluindo informações do usuário (nome, telefone, ID), a chave da API do Google Maps e a posição inicial da câmera no Google Maps.

lib/global/trip_var.dart
Contém variáveis relacionadas à viagem, incluindo informações do motorista (nome, foto, telefone), status da viagem e detalhes do carro.

lib/main.dart
Configura a inicialização principal do aplicativo, incluindo a inicialização do Firebase, a configuração de permissões de localização e a definição da tela inicial com base na autenticação do usuário.

lib/methods/common_methods.dart
Contém métodos comuns utilizados no aplicativo, incluindo verificação de conectividade, exibição de Snackbar, envio de solicitações para APIs (como Places, Directions e Geocoding do Google), conversão de coordenadas geográficas em endereços legíveis, obtenção de detalhes de direções e cálculo de tarifas com base na distância e duração da viagem.

lib/methods/manage_drivers_methods.dart
Contém métodos para gerenciar informações de motoristas próximos, incluindo adicionar, remover e atualizar a localização de motoristas na lista de motoristas próximos online.

lib/methods/push_notification_service.dart
Gerencia o serviço de notificações push, incluindo a obtenção de token de acesso para autenticação e envio de notificações para os motoristas via Firebase Cloud Messaging.

lib/models/address_model.dart
Define a classe AddressModel com atributos para identificação de locais, incluindo humanReadableAddress, latitudePosition, longitudePosition, placeID e placeName.

lib/models/direction_details.dart
Define a classe DirectionDetails com atributos para detalhes de direções, incluindo distanceTextString, durationTextString, distanceValueDigits, durationValueDigits e encodedPoints.

lib/models/online_nearby_drivers.dart
Define a classe OnlineNearbyDrivers com atributos para identificação do motorista, latitude e longitude de sua localização.

lib/models/prediction_model.dart
Define a classe PredictionModel com atributos para identificação de locais, incluindo place_id, main_text, e secondary_text, derivados de uma estrutura JSON.

lib/pages/destination_search_page.dart
Implementa uma tela de busca de endereços de partida e destino utilizando a API Places do Google. A tela permite ao usuário digitar endereços e valida em tempo real para sugerir localizações.

lib/pages/home_page.dart
Implementa a tela inicial do aplicativo, com múltiplas funcionalidades como interação com o mapa Google Maps, gerenciamento de estados de UI, integração com Firebase para autenticação e base de dados, uso de Geolocator para localização em tempo real, e manipulação de polilinhas e marcadores para rotas e locais no mapa.

lib/pages/profile_page.dart
Implementa a tela de perfil do usuário, permitindo a visualização e edição do perfil. A tela permite ao usuário atualizar seu nome, telefone e email, com integração ao Firebase Authentication e Firebase Realtime Database.

lib/pages/trip_configuration_page.dart
Implementa a tela de configuração de viagem agendada, permitindo ao usuário selecionar a data, hora e tipo de serviço para a viagem. Gerencia as seleções e salva os detalhes da viagem no Firebase Realtime Database quando o agendamento é confirmado.

lib/widgets/info_dialog.dart
Implementa um diálogo de informações, exibindo um título e uma descrição centralizados, com estilo personalizado para fonte e cor, e um botão "OK" para fechar o diálogo.

lib/widgets/loading_dialog.dart
Implementa um diálogo de carregamento, exibindo uma mensagem de texto e um indicador circular de progresso, com estilo personalizado para cor e fonte, dentro de um container com bordas arredondadas.

lib/widgets/prediction_place_ui.dart
Implementa um widget para exibir os resultados de predições de locais buscados. Inclui funções para buscar os detalhes do local clicado usando a API Places do Google e verificar se o local está na Zona Oeste.

lib/widgets/prediction_place_ui_for_schedule.dart
Implementa um widget similar ao PredictionPlaceUI, mas com estilo ajustado para ser usado no contexto de agendamento de corridas. Exibe os resultados de predições de locais buscados e inclui verificações para a Zona Oeste
