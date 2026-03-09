class AppRoutes {
  // Authentification
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String createPassword = '/create-password'; 

  // Client - Pages principales
  static const String clientHome = '/client-home';
  static const String clientDemandes = '/client-demandes';
  static const String clientBanques = '/client-banques';
  static const String clientFormulaires = '/client-formulaires';
  static const String clientMethode = '/client-methode';
  static const String clientProfil = '/client-profil';
  static const String clientEditProfil = '/client-edit-profil';

  // Client - Nouvelles routes (home screen)
  static const String clientCompleteProfile = '/client-complete-profile';
  static const String clientDemandeDetail = '/client-demande-detail';

  // Nouvelle demande (12 étapes)
  static const String nouvelleDemandeStep1 = '/nouvelle-demande-step-1';
  static const String nouvelleDemandeStep2 = '/nouvelle-demande-step-2';
  static const String nouvelleDemandeStep3 = '/nouvelle-demande-step-3';
  static const String nouvelleDemandeStep4 = '/nouvelle-demande-step-4';
  static const String nouvelleDemandeStep5 = '/nouvelle-demande-step-5';
  static const String nouvelleDemandeStep6 = '/nouvelle-demande-step-6';
  static const String nouvelleDemandeStep7 = '/nouvelle-demande-step-7';
  static const String nouvelleDemandeStep8 = '/nouvelle-demande-step-8';
  static const String nouvelleDemandeStep9 = '/nouvelle-demande-step-9';
  static const String nouvelleDemandeStep10 = '/nouvelle-demande-step-10';
  static const String nouvelleDemandeStep11 = '/nouvelle-demande-step-11';
  static const String nouvelleDemandeStep12 = '/nouvelle-demande-step-12';

  // Détails demande (différents statuts)
  static const String detailDemande = '/detail-demande';
  static const String detailVirement = '/detail-virement';
  static const String detailActeVente = '/detail-acte-vente';
  static const String detailPret = '/detail-pret';
  static const String detailOuvertureCompte = '/detail-ouverture-compte';
  static const String detailOuvertureCompteBrouillon = '/detail-ouverture-compte-brouillon';
  static const String detailDemandeRejet = '/detail-demande-rejet';
  static const String detailDemandeAttente = '/detail-demande-attente';
  static const String detailDemandeEnCours = '/detail-demande-en-cours';
  static const String detailDemandeValide = '/detail-demande-valide';
  static const String detailDemandeBrouillon = '/detail-demande-brouillon';
}