import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "map"]

  toggle() {
    if (this.checkboxTarget.checked) {
      this.mapTarget.style.display = "block"
      this.mapTarget.dispatchEvent(new CustomEvent("map:show"))
    } else {
      this.mapTarget.style.display = "none"
    }
  }
}
