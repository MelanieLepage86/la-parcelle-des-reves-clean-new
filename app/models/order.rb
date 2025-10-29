class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  has_many :artworks, through: :order_items

  encrypts :first_name
  encrypts :last_name
  encrypts :phone
  encrypts :email
  encrypts :address_line
  encrypts :postal_code
  encrypts :city
  encrypts :country

  enum status: {
    pending: 'pending',
    payment_confirmed: 'payment_confirmed',
    valide: 'valide',
    en_cours: 'en_cours',
    expedie: 'expedie',
    recue: 'recue',
    retour: 'retour',
    remboursee: 'remboursee',
    termine: 'termine'
  }

  def status_label
    {
      "pending" => "En attente",
      "payment_confirmed" => "Paiement confirmé",
      "valide" => "Validée",
      "en_cours" => "En cours",
      "expedie" => "Expédiée",
      "recue" => "Reçue",
      "retour" => "Retour",
      "remboursee" => "Remboursée",
      "termine" => "Terminé"
    }[status] || status.humanize
  end

  enum delivery_method: {
    livraison: "livraison",
    remise_en_main_propre: "remise_en_main_propre"
  }

  validates :delivery_method, presence: true

  def delivery_method_label
    case delivery_method
    when 'livraison'
      'Livraison'
    when 'remise_en_main_propre'
      'Remise en main propre'
    else
      'Non défini'
    end
  end
end
