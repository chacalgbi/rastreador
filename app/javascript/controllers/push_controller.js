import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { userId: String }
  static targets = ["notificationButton"]

  connect() {
    this.checkNotificationPermission();
    //this.startPeriodicPermissionCheck();

    setTimeout(() => {
      this.initializePushNotifications();
    }, 3000);
  }

  checkNotificationPermission() {
    if ("Notification" in window) {
      const permission = Notification.permission;

      if (this.hasNotificationButtonTarget) {
        if (permission === "default") {
          console.log("Permissão ainda não foi solicitada");
          this.notificationButtonTarget.style.display = "block";
        } else if (permission === "granted") {
          //console.log("Permissão já foi concedida");
          this.notificationButtonTarget.style.display = "none";
        } else if (permission === "denied") {
          console.log("Permissão negada");
          this.notificationButtonTarget.style.display = "block";
        }
      }
    }
  }

  initializePushNotifications() {
    if ("Notification" in window) {
      Notification.requestPermission().then((permission) => {
        if (permission === "granted") {
          console.log("Permissão concedida para notificações.");
          this.registerServiceWorker();
          if (this.hasNotificationButtonTarget) {
            this.notificationButtonTarget.style.display = "none";
          }
        } else if (permission === "denied") {
          console.warn("Usuário rejeitou a permissão de notificações.");
          if (this.hasNotificationButtonTarget) {
            this.notificationButtonTarget.style.display = "block";
          }
        } else {
          console.warn("O usuário ainda não deu uma resposta sobre as notificações.");
        }
      });
    } else {
      console.warn("Push notifications não são suportadas.");
    }
  }

  registerServiceWorker() {
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker
        .register('/service_worker.js')
        .then((serviceWorkerRegistration) => {
          console.log("Service Worker registrado com sucesso.");

          // Aguarda o Service Worker estar ativo
          return this.waitForServiceWorkerActivation(serviceWorkerRegistration);
        })
        .then((serviceWorkerRegistration) => {
          return serviceWorkerRegistration.pushManager.getSubscription();
        })
        .then((existingSubscription) => {
          if (!existingSubscription) {
            return navigator.serviceWorker.ready.then((registration) => {
              return registration.pushManager.subscribe({
                userVisibleOnly: true,
                applicationServerKey: this.urlB64ToUint8Array(
                  this.element.getAttribute("data-application-server-key")
                ),
              });
            });
          }
          return existingSubscription;
        })
        .then((subscription) => {
          if (subscription) {
            this.saveSubscription(subscription);
          }
        })
        .catch((error) => {
          console.error("Erro durante o registro ou assinatura do Service Worker:", error);
        });
    }
  }

  waitForServiceWorkerActivation(registration) {
    return new Promise((resolve) => {
      if (registration.active) {
        resolve(registration);
      } else {
        const worker = registration.installing || registration.waiting;
        if (worker) {
          worker.addEventListener('statechange', () => {
            if (worker.state === 'activated') {
              resolve(registration);
            }
          });
        } else {
          resolve(registration);
        }
      }
    });
  }

  urlB64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding)
      .replace(/-/g, '+')
      .replace(/_/g, '/');

    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
  }

  getDeviceInfo() {
    const userAgent = navigator.userAgent;

    let browser = 'Unknown';
    if (userAgent.includes('Chrome') && !userAgent.includes('Edg')) {
      browser = 'Chrome';
    } else if (userAgent.includes('Firefox')) {
      browser = 'Firefox';
    } else if (userAgent.includes('Safari') && !userAgent.includes('Chrome')) {
      browser = 'Safari';
    } else if (userAgent.includes('Edg')) {
      browser = 'Edge';
    } else if (userAgent.includes('Opera') || userAgent.includes('OPR')) {
      browser = 'Opera';
    }

    let deviceType = 'Desktop';
    if (/Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent)) {
      if (/iPad/i.test(userAgent)) {
        deviceType = 'Tablet';
      } else if (/iPhone|iPod|Android.*Mobile/i.test(userAgent)) {
        deviceType = 'Mobile';
      } else {
        deviceType = 'Mobile';
      }
    }

    let os = 'Unknown';
    if (userAgent.includes('Windows')) {
      os = 'Windows';
    } else if (userAgent.includes('Mac OS')) {
      os = 'macOS';
    } else if (userAgent.includes('Linux')) {
      os = 'Linux';
    } else if (userAgent.includes('Android')) {
      os = 'Android';
    } else if (userAgent.includes('iOS') || userAgent.includes('iPhone') || userAgent.includes('iPad')) {
      os = 'iOS';
    }

    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    const language = navigator.language || navigator.userLanguage;
    const screenResolution = `${screen.width}x${screen.height}`;

    return {
      browser,
      device_type: deviceType,
      operating_system: os,
      user_agent: userAgent,
      timezone,
      language,
      screen_resolution: screenResolution,
      timestamp: new Date().toISOString()
    };
  }

  saveSubscription(subscription) {
    const endpoint = subscription.endpoint;
    const p256dh = btoa(
      String.fromCharCode.apply(
        null,
        new Uint8Array(subscription.getKey("p256dh"))
      )
    );
    const auth = btoa(
      String.fromCharCode.apply(
        null,
        new Uint8Array(subscription.getKey("auth"))
      )
    );

    const deviceInfo = this.getDeviceInfo();

    const payload = { 
      endpoint, 
      p256dh, 
      auth,
      ...deviceInfo
    };

    if (this.userIdValue && this.userIdValue !== "") { // Adiciona user_id se estiver disponível
      payload.user_id = this.userIdValue;
      console.log("Enviando inscrição com user_id:", this.userIdValue);
    } else {
      console.log("Enviando inscrição sem user_id (usuário não logado)");
    }

    // Log das informações do dispositivo para debug
    console.log("Informações do dispositivo:", deviceInfo);

    fetch("/admin/push_notifications/subscribe", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
      body: JSON.stringify(payload),
    })
      .then((response) => {
        if (response.ok) {
          console.log("Inscrição salva com sucesso no servidor.");
        } else {
          console.error("Erro ao salvar inscrição no servidor.");
        }
      })
      .catch((error) => {
        console.error("Erro ao enviar inscrição para o servidor:", error);
      });
  }

  updateSubscriptionWithUserId() {
    if (this.userIdValue && this.userIdValue !== "" && "serviceWorker" in navigator) {
      navigator.serviceWorker.ready
        .then((registration) => {
          return registration.pushManager.getSubscription();
        })
        .then((subscription) => {
          if (subscription) {
            console.log("Atualizando assinatura existente com user_id:", this.userIdValue);
            this.saveSubscription(subscription);
          }
        })
        .catch((error) => {
          console.error("Erro ao atualizar assinatura com user_id:", error);
        });
    }
  }

  userIdValueChanged() {
    // Método chamado quando o valor do userId muda
    if (this.userIdValue && this.userIdValue !== "") {
      this.updateSubscriptionWithUserId();
    }
  }

  startPeriodicPermissionCheck() {
    // Método para verificar periodicamente o status das permissões
    // (útil se o usuário mudar as configurações do navegador)

    if (this.permissionCheckInterval) {
      // Evita criar múltiplos intervalos
      clearInterval(this.permissionCheckInterval);
    }

    this.permissionCheckInterval = setInterval(() => {
      this.checkNotificationPermission();
    }, 30000);
  }

  disconnect() {
    // Limpa o interval quando o controller é desconectado
    if (this.permissionCheckInterval) {
      clearInterval(this.permissionCheckInterval);
    }
  }
}