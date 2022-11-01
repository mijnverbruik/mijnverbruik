import {animate, spring} from "motion"

const AnimatedValue = {
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

export default AnimatedValue
