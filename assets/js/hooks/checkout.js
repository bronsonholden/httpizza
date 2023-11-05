import { loadStripe } from "@stripe/stripe-js/pure"

export default {
  async mounted() {
    console.log(this.el.dataset.returnUrl)
    const stripe = await loadStripe(this.el.dataset.stripeKey)

    const clientSecret = this.el.dataset.clientSecret

    this.mql = window.matchMedia("(prefers-color-scheme: dark)")

    const appearance = { theme: this.mql.matches ? "night" : "stripe" }
    const options = {
      paymentMethodOrder: ["card"]
    }
    const elements = stripe.elements({ clientSecret, appearance })
    const paymentElement = elements.create("payment", options)

    this.changeHandler = (mql) => {
      if (mql.matches) {
        elements.update({ appearance: { theme: "night" } })
      } else {
        elements.update({ appearance: { theme: "stripe" } })
      }
    }

    this.mql.addEventListener("change", this.changeHandler)

    paymentElement.mount(this.el)
    this.el.classList.add("ready")

    this.handleEvent("confirm-payment", async () => {
      // const { error } =
      await stripe.confirmPayment({
        elements,
        confirmParams: {
          return_url: this.el.dataset.returnUrl,
        }
      })
    })
  },

  destroyed() {
    this.mql.removeEventListener("change", this.changeHandler)
  }
}
