Une réponse pour relancer la discussion, en fonction de ma perception et de ce que j’ai vu chez des clients

# Passé:

À l’époque de SOAP et des UDDI (des annuaires de services qui n’a jamais vraiment fonctionné) on avait des besoin d’urbanisation qui étaient très techniques (qui expose quoi) mais pas très métier. « Modèles de données communs » ça voulait dire des architectes de données en tour d'ivoire qui faisaient de l’UML avec des grands plans d’avoir des dictionnaires de données d’entreprises. Les outils étaient fait pour être vendus à des DSI: drivés par des besoins de référencement et de contrôle et pas du tout par les besoin des projets

Pour être honnête, chez certains clients qui avaient déjà une bonne vision de leur métier et de ce que c’était des services ça a pu servir.

On a donc gardé une très mauvaise image de tout ça, même si certain clients s’y essaient encore avec enthousiasme.

# Aujourd'hui

Hypothèses :
- Les géants du web ont un métier assez simple comparés à certains de nos clients dans les domaines banque / assurances / distribution, donc les GdW ne parlent pas trop de ce sujet, et en plus c’est pas glamour 
- Pour ces gros clients-là, dans un SI de services « moderne », on a un besoin en urbanisation (modèles de donnée et définition de services) plus important qu’avant et le besoin de maitriser les services devient central dans leur business.

Les micro-services et autres outils d’API-management sont des solutions à des problèmes tactiques (comment on expose / utilise / monitore des services entre applications), mais les questions de modèles de données communs et d’urbanisation sont des questions métier stratégiques.

Pour poursuivre ce que tu dis, si on laisse chaque équipe autonome, dans quelques cycles projets on a 10 définitions de ce qu’est un client, et chaque élément d’une chaine d’appel exposera une version différente du même object suivant le moment où ils se sont mis à l’utiliser.

La question à beaucoup d’euros c’est comment on va faire pour faire de l’urbanisation :
- qui vit dans le temps, donc gérer les version, le métier qui change
- qui ne fait pas que de « la police » (même si c’est déjà bien) mais qui apporte de la valeur aux projets
- qui s’appuie sur les métiers alors qu’elle est un sujet transverse et que l’IT transverse va essayer de s’en emparer

La piste la moins mauvaise c’est qu’en faisant prendre conscience que les services sont du métier, et que donc la définition du modèle et des services fait partie du produit, on va rendre les PO owner de ce sujet. Et qu’eux pourront avoir le levier pour forcer l’IT centrale à bien faire les choses. 
Du coup ça devient un vrai enjeux de changement et de methodo autant que de tech...
