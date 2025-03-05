import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.applyPhoneMask();
  }

  applyPhoneMask() {
    const phoneInput = this.element.querySelector("#user_phone");
    if (phoneInput) {
      phoneInput.addEventListener("input", function (e) {
        let value = e.target.value.replace(/\D/g, "");
        value = value.replace(/^(\d{2})(\d)/g, "($1) $2");
        value = value.replace(/(\d)(\d{4})$/, "$1-$2");
        e.target.value = value;
      });
    }
  }
}