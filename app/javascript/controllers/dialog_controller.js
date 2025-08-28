import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "menu" ]

  show() {
    this.menuTarget.show()
  }

  showModal() {
    this.menuTarget.showModal()
    try {
      const scripts = this.menuTarget.querySelectorAll('script:not([data-evaluated])')
      scripts.forEach((s) => {
        const newScript = document.createElement('script')
        if (s.src) {
          newScript.src = s.src
        } else {
          newScript.text = s.textContent
        }
        newScript.dataset.evaluated = 'true'
        document.body.appendChild(newScript)

        newScript.parentNode.removeChild(newScript)
        s.dataset.evaluated = 'true'
      })
    } catch (e) { /* noop */ }

    try {
      const containers = this.menuTarget.querySelectorAll('[id^="rails_charts_"]')
      containers.forEach((el) => {
        const fnName = `init_${el.id}`
        const fn = window[fnName]
        if (typeof fn === 'function') {
          try { fn() } catch (e) { /* noop */ }
        }
      })
    } catch (e) { /* noop */ }

    setTimeout(() => {
      window.dispatchEvent(new Event('resize'))
    }, 100)
  }

  close() {
    this.menuTarget.close()
  }

  closeOnClickOutside({ target }) {
    target.nodeName === "DIALOG" && this.close()
  }
}
