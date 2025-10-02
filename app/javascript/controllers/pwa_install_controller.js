import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { autoPrompt: { type: Boolean, default: true } }
  static targets = ["installButton"]

  connect() {
    this.deferredPrompt = null
    this.setupInstallPrompt()
    this.checkIfInstalled()
  }

  setupInstallPrompt() {
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault()
      this.deferredPrompt = e

      if (this.autoPromptValue) {
        console.log('PWA: Auto prompt habilitado')
        setTimeout(() => {
          this.showInstallPrompt()
        }, 3000)
      } else {
        console.log('PWA: Auto prompt desabilitado, mostrando botão')
        this.showInstallButton()
      }
    })

    window.addEventListener('appinstalled', (e) => {
      console.log('PWA: App foi instalada', e)
      this.deferredPrompt = null
      this.hideInstallButton()
    })
  }

  showInstallPrompt() {
    if (this.deferredPrompt) {
      this.deferredPrompt.prompt()

      this.deferredPrompt.userChoice.then((choiceResult) => {
        if (choiceResult.outcome === 'accepted') {
          console.log('PWA: Usuário aceitou a instalação')
        } else {
          console.log('PWA: Usuário recusou a instalação')
        }
        this.deferredPrompt = null
        this.hideInstallButton()
      })
    }
  }

  install() {
    console.log('PWA: Tentativa de instalação manual')

    if (this.deferredPrompt) {
      this.showInstallPrompt()
    } else {
      console.log('PWA: deferredPrompt não disponível. Talvez o navegador não suporte ou a app já esteja instalada.')
      if (confirm('Parece que sua aplicação já está instalada ou seu navegador não suporta instalação automática. Deseja tentar acessar via configurações do navegador?')) {
        console.log('PWA: Usuário optou por instalação manual via navegador')
      }
    }
  }

  checkIfInstalled() {
    if (window.matchMedia && window.matchMedia('(display-mode: standalone)').matches) {
      console.log('PWA: App já está instalada e rodando como PWA')
      this.hideInstallButton()
      return true
    }

    if (window.navigator.standalone === true) {
      console.log('PWA: App já está instalada no iOS')
      this.hideInstallButton()
      return true
    }

    return false
  }

  showInstallButton() {
    if (this.hasInstallButtonTarget) {
      this.installButtonTarget.style.display = 'flex'
    } else {
      const installButton = document.querySelector('[data-pwa-install-target="installButton"]')
      if (installButton) {
        installButton.style.display = 'flex'
      } else {
        console.log('PWA: Botão de instalação não encontrado no DOM')
      }
    }
  }

  hideInstallButton() {
    if (this.hasInstallButtonTarget) {
      this.installButtonTarget.style.display = 'none'
    } else {
      const installButton = document.querySelector('[data-pwa-install-target="installButton"]')
      if (installButton) {
        installButton.style.display = 'none'
      }
    }
  }

  registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('/service-worker')
        .then((registration) => {
        })
        .catch((error) => {
          console.log('PWA: Falha ao registrar Service Worker:', error)
        })
    }
  }

  disconnect() {
    // Limpa os event listeners se necessário
  }
}