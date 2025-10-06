import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleMaintenanceUser()
    // Também executa quando o dialog é aberto (caso o Turbo Stream atualize)
    setTimeout(() => this.handleMaintenanceUser(), 100)
  }

  handleMaintenanceUser() {
    const isMaintenanceUser = document.body.dataset.userMaintenance === "true"

    if (isMaintenanceUser) {
      // Remove completamente o container do checklist do DOM para evitar validação
      const checklistContainers = this.element.querySelectorAll('.checklist-container')
      checklistContainers.forEach(container => {
        if (container) {
          container.remove()
        }
      })
    }
  }

  beforeSubmit(event) {
    const isMaintenanceUser = document.body.dataset.userMaintenance === "true"

    if (isMaintenanceUser) {
      // Remove o container do checklist antes da validação do formulário
      const form = event.target
      const checklistContainer = form.querySelector('.checklist-container')
      if (checklistContainer) {
        checklistContainer.remove()
      }
    }
  }
}
