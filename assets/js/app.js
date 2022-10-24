import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "topbar"
import {animate, spring} from "motion"

let Hooks = {}

Hooks.AnimatedValue = {
  mounted() {
    this.value = this.el.dataset.animatedValue
  },

  updated() {
    let diff = this.value - this.el.dataset.animatedValue,
      prev = this.value

    this.value = this.el.dataset.animatedValue

    animate(
      (progress) => {
        this.el.innerText = Math.round(prev - diff * progress)
      },
      {duration: 0.5, easing: spring()}
    )
  },
}

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: {_csrf_token: csrfToken},
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", () => topbar.show())
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
