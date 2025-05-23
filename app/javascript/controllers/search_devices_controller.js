import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-devices"
export default class extends Controller {
  search() {
    clearTimeout(this.timeout)
    const inputValue = this.element.querySelector('input').value
    if (inputValue.length >= 3) {
      this.timeout = setTimeout(() => { this.element.requestSubmit() }, 400)
    }else if(inputValue.length == 0){
      this.timeout = setTimeout(() => { this.element.requestSubmit() }, 100)
    }
  }
}
