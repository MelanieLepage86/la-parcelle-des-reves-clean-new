import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    publicKey: String,
    orderId: Number,
    redirectUrl: String
  }

  static targets = ["cardElement", "submitButton"]

  connect() {
    console.log("payment controller connected")

    this.stripe = Stripe(this.publicKeyValue)
    this.card = null
    this.clientSecret = null

    const modalEl = this.element.closest(".modal")
    if (modalEl) {
      modalEl.addEventListener("shown.bs.modal", () => {
        this.setupPayment()
      })
    } else {
      this.setupPayment()
    }
  }

  async setupPayment() {
    if (this.card) return

    try {
      const res = await fetch(`/panier/payment_intent/${this.orderIdValue}`)
      if (!res.ok) {
        throw new Error(`Erreur serveur (${res.status})`)
      }

      const data = await res.json()
      this.clientSecret = data.client_secret

      const elements = this.stripe.elements()
      this.card = elements.create("card")
      this.card.mount(this.cardElementTarget)

      this.submitButtonTarget.addEventListener("click", this.submitPayment.bind(this))
    } catch (err) {
      alert("Erreur lors de la préparation du paiement.")
      console.error("❌ Stripe setup error:", err)
    }
  }

  async submitPayment(event) {
    event.preventDefault()

    if (!this.clientSecret) {
      alert("Paiement non prêt. Veuillez réessayer.")
      return
    }

    const { paymentIntent, error } = await this.stripe.confirmCardPayment(this.clientSecret, {
      payment_method: { card: this.card }
    })

    if (error) {
      alert(error.message)
    } else if (paymentIntent.status === "succeeded") {
      alert("Paiement réussi !")

      // 👇 Fermer la modal manuellement
      const modalEl = this.element.closest(".modal")
      const modalInstance = bootstrap.Modal.getInstance(modalEl)
      if (modalInstance) modalInstance.hide()

      // 👇 Rediriger
      window.location.href = this.redirectUrlValue
    }
  }
}
