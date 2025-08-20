import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
  static values = { 
    alert: String,
    notice: String,
    type: String,
    redirectOnSuccess: Boolean
  }

  connect() {
    if (this.hasAlertValue && this.alertValue) {
      this.showAlert(this.alertValue, 'error')
    }
    
    if (this.hasNoticeValue && this.noticeValue) {
      this.showAlert(this.noticeValue, 'success')
    }
  }

  showAlert(message, type) {
    const isError = type === 'error'
    const shouldRedirectOnSuccess = this.hasRedirectOnSuccessValue && this.redirectOnSuccessValue
    
    Swal.fire({
      title: isError ? 'Atenção!' : 'Sucesso!',
      text: message,
      icon: type,
      showCancelButton: isError,
      confirmButtonText: isError ? 'Ir para página inicial' : 'OK',
      cancelButtonText: 'Fechar',
      confirmButtonColor: isError ? '#d33' : '#3085d6',
      cancelButtonColor: '#6c757d'
    }).then((result) => {
      if (result.isConfirmed && isError) {
        window.location.href = "/"
      }
      if (result.isConfirmed && !isError && shouldRedirectOnSuccess) {
        window.location.href = "/"
      }
    })
  }
}
