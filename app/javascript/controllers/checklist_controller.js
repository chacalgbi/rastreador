import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "obs", "submitButton"]

  connect() {
    this.updateObsRequirement()
  }

  checkboxChanged() {
    this.updateObsRequirement()
  }

  updateObsRequirement() {
    const checkboxes = this.checkboxTargets
    const obsField = this.obsTarget
    const obsContainer = obsField.closest('.obs-container')
    const anyUnchecked = checkboxes.some(checkbox => !checkbox.checked)
    
    if (anyUnchecked) {
      obsField.setAttribute("required", "required")
      obsField.style.borderColor = "#f59e0b"
      this.showObsContainer(obsContainer)
      this.showObsWarning()
    } else {
      obsField.removeAttribute("required")
      obsField.style.borderColor = ""
      obsField.value = "" // Limpa o campo quando não é mais necessário
      this.hideObsContainer(obsContainer)
      this.hideObsWarning()
    }
  }

  showObsContainer(container) {
    if (container) {
      container.style.display = "block"
      container.style.opacity = "1"
      container.style.maxHeight = "300px"
    }
  }

  hideObsContainer(container) {
    if (container) {
      container.style.opacity = "0"
      container.style.maxHeight = "0"
      // Aguarda a transição antes de ocultar completamente
      setTimeout(() => {
        if (container.style.opacity === "0") {
          container.style.display = "none"
        }
      }, 300)
    }
  }

  showObsWarning() {
    let warning = this.element.querySelector(".obs-warning")
    if (!warning) {
      warning = document.createElement("div")
      warning.className = "obs-warning text-sm text-yellow-600 mt-1"
      warning.textContent = "⚠️ Campo obrigatório SE algum item não foi verificado"
      this.obsTarget.parentNode.appendChild(warning)
    }
  }

  hideObsWarning() {
    const warning = this.element.querySelector(".obs-warning")
    if (warning) {
      warning.remove()
    }
  }
}
