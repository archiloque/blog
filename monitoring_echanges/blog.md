# Présent et avenir du monitoring de flux 

Nous allons vous présenter les pratiques actuelles et les évolutions en cours du monitoring de flux.
Cela devrait vous permettre de comparer votre système actuel avec les pratiques généralement observées et de vos donner des idées pour la suite.

# Monitoring de flux ?

On appelle un *flux* un **ensemble d'appels de services et d'envois de messages qui ensemble forment un service métier**. Dans un système d'information complexe, un tel flux traverse souvent plusieurs applications et utilise parfois plusieurs technologie: par exemple le traitement d'un appel de service SOAP provoquera l'envoi de messages JMS qui eux-mêmes pourront déclencher d'autres traitements.

Monitorer ces flux veut donc dire mettre en place un monitoring des activités métier *(Business Activity Monitor)* qui consiste à collecter des données à différents niveaux et de les corréler pour présenter **une vision transverse agrégée**. Ce monitoring doit fournir à tout moment **l'état de santé et la performance des fonctions métiers importantes** *(Key Performance Indicator)*.

## Pour avoir un bon monitoring de flux

### Fonctionnalités

La fonctionnalité essentielle est d'être capable d'**identifier les flux métier** dans les messages atomiques. Généralement cela passe par l'utilisation d'un identifiant unique (*correlation id*), qui doit être porté par tous les messages d'un même flux, identifiant qui se retrouvera dans les messages d'audit. Pour gérer cet identifiant il est donc nécessaire de mettre en place une brique spécifique dans les différents applicatifs pour générer l'identifiant en début de chaîne et le propager dans les traitements.

Le système doit être capable d'**intégrer des évènements hétérogènes**: si les messages envoyés par les différents composants comportent des éléments communs (horodatage par exemple) ils comportent aussi des informations spécifiques liées au métier du service (nom du service métier, type d'objet traité). Être capable d'intégrer facilement ces différentes données permettra de construire au plus juste des métriques métiers qui évolueront en même temps que les services.

Ensuite il faut disposer d'un système de **dashboarding configurable**: il ne s'agit pas seulement de prédéfinir un ensemble d'écrans de monitoring fixes, mais aussi de pouvoir s'en servir pour investiguer des comportements en s'appuyant sur les informations métier. Cela signifie qu'une fois mis en place il doit être configurable dynamiquement pour modifier des écrans ou en créer de nouveaux à la volée. Les systèmes de monitoring utilisés habituellement pour les systèmes de production sont donc généralement mal adaptés à ce type d'usage.

La base de donnée doit fournir des fonctionnalités d'**indexation** avec une couverture maximum, l'idéal étant d'indexer l'intégralité des données. Cela permet de simplifier considérablement les investigations en cas d'erreur en pouvant chercher tous les messages liés à un certain identifiant métier, par exemple tous les messages qui concernent un certain numéro de compte. Pour des questions de volume on pourra limiter l'indexation dans le temps (48 heures par exemple), en gardant la possibilité de réindexer des messages passés.

### Contraintes:

#### Ne jamais interférer avec le métier

Tout d'abord un échec dans la piste d'audit ne doit pas entrainer de conséquences sur le fonctionnel, il faut donc bien isoler techniquement les deux.

Ensuite le monitoring ne doit **pas entrainer de baisse de performances**, les informations de monitoring doivent être envoyées sous forme d'évènements asynchrones (pattern *[wiretap](http://www.enterpriseintegrationpatterns.com/WireTap.html)*) à l'aide d'un middleware de messages. Il est souhaitable d'avoir une infrastructure de message dédiée, car on évite ainsi tout risque de surcharge.

#### Limiter les développements spécifiques

Pour finir il faut **limiter les développement métier dans les briques de monitoring**: si de la configuration ou un peu de développement spécifique lié au métier est inévitable, surtout pout les métriques les plus précises, il faut éviter de recoder des comportement fonctionnels. Cela se produit souvent quand on veut s'appuyer sur les messages de monitoring pour reproduire l'état des échanges dans le système monitoré pour mettre en place des stratégies de rejeu partiel. Le résultat est souvent fragile et va rendre plus difficile les évolutions du métier.

### Briques logicielles nécessaires

On peut donc identifier les différentes briques qui sont nécessaires pour le monitoring de flux:
- les informations sont transmises sous formes d'événements dans un middleware de message dédié
- un système de traitement de messages pour faire des agrégations et de la détection d'évènements
- une base de donnée indexée où ils sont stockés
- une console de monitoring pour les exploiter

<Schema 1>

# Pratiques actuelles

Nous allons voir ici quelles solutions sont actuellement choisies pour mettre en œuvre une infrastructure de monitoring de flux.

Votre système d'informations comporte déjà une partie des blocs techniques nécessaires comme un système de messages ou une base de donnée. Cependant les spécificités du monitoring font qu'il est généralement nécessaire d'utiliser des outils différents de celles utilisées pour le métier.

- Du fait du grand nombre de messages entrant dans le système, les middleware classiques (JMS) n'offrent pas la capacité de traitement dont on a besoin ici, il est donc nécessaire d'utilisé un **système de communication spécialisé** pour ce type de volume: [AMQP](http://www.amqp.org), [SNMP](http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol), [RSYSLOG](http://www.rsyslog.com), [ZeroMQ)](http://zeromq.org.

- Pour le traitement de messages utiliser un système de **[CEP](http://en.wikipedia.org/wiki/Complex_event_processing)** (*complex event processing*) comme [Drool Fusion](http://docs.jboss.org/drools/release/latest/drools-docs/html/DroolsComplexEventProcessingChapter.html) va gérer les aspects techniques pour permettre de se concentrer sur les règles à mettre en place.

- La base doit stocker des messages ayant des formats hétérogènes et qui évoluent avec les applications. On s'orientera donc généralement vers une solution de stockage de type NoSQL permettant d'avoir des schémas de données dynamiques tout en fournissant partitionnement et scalabalité afin d'absorber le volume et le débit de données entrant. Les fonctionnalités d'indexation d'**[Elastic Search](http://www.elasticsearch.org)** en font généralement un bon choix.

- Pour le dashboarding [Kibana](http://www.elasticsearch.org/overview/kibana/) est le produit de référence pour visualiser des données stockées dans Elastic Search: il permet de construire des écrans riches de manière flexibles.

<Schema 2>

# Le futur

Ce type d'architecture reposants sur des briques standard est limité sur deux aspects, le premier est technique et le second fonctionnel. 

## Toujours plus de messages

La première limite est liée à l'augmentation du nombre de messages à traiter. Dans des systèmes basés sur les nouvelles architectures de micro-services et qui intègrent de nouveaux usages (applications mobiles, internet des objets) le nombre de messages est démultiplié. L'objectif du système de monitoring étant de continuer à absorber l'intégralité des messages il doit voir ses capacités augmenter dans les mêmes proportions.

Cela entraine la mise en place de plusieurs solutions:
- Même en choisissant un broker rapide, les solutions de middleware de messages classiques plafonnent à 10 000 messages par seconde. Il faut alors se tourner vers des solutions **«Fast Data»** dont [Kafka](http://kafka.apache.org) semble aujourd'hui devenir la solution de référence.
- L'intégration de messages dans le système de stockage doit passer par une solution d' **« Event Streaming »**. Les solutions envisageables sont [Apache Storm](https://storm.apache.org) et [Apache Spark Streaming](https://spark.apache.org/streaming/).
- Le stockage d'un tel volume de données sera réalisé sur **un système de stockage distribué** comme [HDFS](http://hadoop.apache.org/docs/r1.2.1/hdfs_design.html#Introduction) d'Hadoop. Le stockage dans Elastic Search pourra être conservé pour des besoins de requêtage rapide sur des données récentes.

Ce type d'architecture "big data" permettant un traitement en flux porte le nom de [DataLake](http://www.forbes.com/sites/ciocentral/2011/07/21/big-data-requires-a-big-new-architecture/)

## Des analyses plus poussées

Après les moteurs de règles classiques on commence à se tourner vers des solutions d'analyses plus pointues permettant de mieux mesurer ce qui se passe mais aussi de mieux prévoir. Dans cette optique la composante métier du monitoring prend de plus en plus de poids et la distinction avec la BI s'efface. Notre conviction est qu'on verra bientôt des solutions d'*Online machine learning* enrichir ses systèmes, et que la capacité à mettre en œuvre ce type de solution pourra être un vrai différenciant.

<Schema 3>
