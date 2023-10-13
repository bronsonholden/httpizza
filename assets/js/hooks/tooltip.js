export default {
  mounted() {
    this.bubble = this.el.querySelector("[data-tooltip-bubble]")
    this.bubbleAnchor = this.el.querySelector("[data-tooltip-bubble-anchor]")

    this.observer = new IntersectionObserver((entries, _observer) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          this.nudgeTooltip(entry)
        } else {
          this.resetTooltipOffset()
        }
      })
    })

    this.observer.observe(this.bubble)
  },
  destroyed() {
    this.observer.disconnect()
  },
  nudgeTooltip(entry) {
    switch (this.getTooltipDirection()) {
      case "top":
        break
      case "left":
        break
      case "right":
        break
      default:
        const rightOverlap = entry.intersectionRect.right - entry.boundingClientRect.right
        const leftOverlap = entry.boundingClientRect.left - entry.intersectionRect.left

        if (rightOverlap < -0.1) this.bubbleAnchor.style["right"] = `${-rightOverlap}px`
        else this.bubbleAnchor.style["right"] = null

        if (leftOverlap < -0.1) this.bubbleAnchor.style["left"] = `${-leftOverlap}px`
        else this.bubbleAnchor.style["left"] = null
    }
  },
  resetTooltipOffset() {
    this.bubbleAnchor.style["right"] = null
    this.bubbleAnchor.style["left"] = null
    this.bubbleAnchor.style["bottom"] = null
    this.bubbleAnchor.style["top"] = null
  },
  getTooltipDirection() {
    // default to bottom
    if (this.el.classList.contains("tooltip-top")) {
      return "top"
    } else if (this.el.classList.contains("tooltip-right")) {
      return "right"
    } else if (this.el.classList.contains("tooltip-left")) {
      return "left"
    } else {
      return "bottom"
    }
  }
}
