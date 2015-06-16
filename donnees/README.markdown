Une réponse pour relancer la discussion :

Les outils qu'on a actuellement en rest permettent partiellement de couvrir les besoins techniques de validation et de publication de contrat d'interface au niveau de l'application, mais même à ce niveau, les outils n'ont pas la maturité des outils SOAP :
- on peut faire de la validation, mais pas avec le niveau de détail de XSD
- on peut publier des contrats d'interfaces, mais sans modélisation avancée (héritage, composition avancée)
Le partage et de capitalisation entre application n'est pas beaucoup adressé.

Chez les GdW, l'approche est plutôt "chacun pour soi" : tu peux réinventer la roue dans ton modèle chez toi: il n'y a pas d'urbanisation.

Or je vois certains de nos clients qui à l'heure actuelle :
- veulent gérer des modèles de données partagés
- se sont vu promettre la lune lorsqu'ils ont signé pour du SOAP
- ont un certain nombre de services, mais pas un SI "SOA"
- ont déjà beaucoup de douleurs de ce côté, principalement causé par des soucis d'organisation

Le but c'est pas de faire du MDA, mais de faire en sorte que les modèles métiers aient une cohérences entre les applis.

Et de ce point de vue, de passer en API en interne va augmenter les problèmes:
- plus de services
- s'ils passent dans un vrai modèles Rest, plus de modèles exposés
- plus de problèmes de versionning

Je pense que l'approche GdW va être difficile à entendre pour eux, et que si on veut leur vendre du SOA version Rest dans leur SI il faut qu'on puisse leur proposer des patterns de gestion de projet et d'orga en plus des outils.

J'aime bien l'approche de donner de la responsabilité aux responsables tech des projets et de nommer des chief data officer, il faut qu'on itère la dessus.
